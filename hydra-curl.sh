#!/bin/bash
MAX_FORKS=100
TODO_FILE=$1
TARGET=$2
DOWNLOAD_FOLDER="/tmp/hydra-curl"

function curl_download {
  ANSWER_SIZE=0
  MIN_SIZE=10000
  MAX_RETRIES=5
  DELIMITER="###DELIMITER###"
  ANSWER=""
  TRIES=0
  while [ "$TRIES" -lt "$MAX_RETRIES" ] && [ "$ANSWER_SIZE" -lt "$MIN_SIZE" ]
    do
      ANSWER=$(curl --retry 3 -s "$2?$1$TRIES" --max-time 60)
      if [ "$?" -ne "0" ]; then
        ANSWER=""
      else
        ANSWER_SIZE=${#ANSWER}
      fi
      let "TRIES += 1"
    done
  
  if [ "$ANSWER_SIZE" -ge "$MIN_SIZE" ]; then
    ANSWER=$ANSWER"$DELIMITER"
    echo $ANSWER > $3/$1
  fi
}

export -f curl_download

mkdir $DOWNLOAD_FOLDER

cat -n $TODO_FILE | xargs -P $MAX_FORKS -n 3 -I{} bash -c curl_download\ \{\}\ $DOWNLOAD_FOLDER

cat $DOWNLOAD_FOLDER/* > $TARGET
rm -rf $DOWNLOAD_FOLDER