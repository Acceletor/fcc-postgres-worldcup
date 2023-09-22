#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
DELETE_ROWS="$($PSQL "TRUNCATE TABLE teams, games")"
echo $DELETE_ROWS

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do  
  # WINNER TEAMS
  # check WINNER team is in teams table
  if [[ $WINNER != "winner" ]]
  then
    IS_TEAM_IN_TABLE="$($PSQL "SELECT * FROM teams WHERE name='$WINNER'")"
    if [[ -z $IS_TEAM_IN_TABLE ]]
    then
      INSERT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted $WINNER into teams table
      fi
    fi
  fi

  # OPPONENT TEAMS
  # check teams is in the table
  if [[ $OPPONENT != "opponent" ]]
  then
    IS_TEAM_IN_TABLE="$($PSQL "SELECT * FROM teams where name='$OPPONENT'")"
    if [[ -z $IS_TEAM_IN_TABLE ]]
    then
      INSERT_TEAM_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted $OPPONENT into teams table
      fi
    fi
  fi

  # INSERTING INFO TO games table
  # find winner_id and opponent_id
  WINNER_ID="$($PSQL "SELECT team_id from teams WHERE name='$WINNER'")"
  OPPONENT_ID="$($PSQL "SELECT team_id from teams WHERE name='$OPPONENT'")"

  INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID, $OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")"
  if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
  then 
    echo Game info year $YEAR had been inserted
  fi
done

