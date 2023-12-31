#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

CHECK_GUESS() {
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    if [[ $1 != $SECRET_NUMBER ]]
    then
      if [[ $1 -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
      ((NUMBER_OF_GUESSES++))
      read USER_GUESS
      CHECK_GUESS $USER_GUESS
    else
      TEMP=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN $NUMBER_OF_GUESSES < best_game OR best_game = -1 THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE username = '$USERNAME'")
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      return
    fi
  else
    echo "That is not an integer, guess again:"
    ((NUMBER_OF_GUESSES++))
    read USER_GUESS
    CHECK_GUESS $USER_GUESS
  fi
}

echo "Enter your username:"
read USERNAME

RESULT=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $RESULT ]]
then
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  read GAMES_PLAYED BAR BEST_GAME <<< $RESULT
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=1

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

CHECK_GUESS $USER_GUESS