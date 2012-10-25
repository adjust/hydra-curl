#!/bin/bash
MAX_FORKS=100
TODO_FILE=$1
TARGET=$2
DOWNLOAD_FOLDER="/tmp/hydra-curl"
TIME_STAMP=$(date +%s)
let "BLOCK_SIZE = MAX_FORKS/5"
CURRENT_TODO=0
COUNTER=0

function download {
  ANSWER_SIZE=0
  MIN_SIZE=10000
  MAX_RETRIES=5
  DELIMITER="###DELIMITER###"
  ANSWER=""
  TRIES=0
  while [ "$TRIES" -lt "$MAX_RETRIES" ] && [ "$ANSWER_SIZE" -lt "$MIN_SIZE" ]
    do
      ANSWER=$(curl --retry 3 -s "$10$TRIES" --max-time 60)
      if [ "$?" -ne "0" ]; then
        ANSWER=""
      else
        ANSWER_SIZE=${#ANSWER}
      fi
      let "TRIES += 1"
    done
  
  if [ "$ANSWER_SIZE" -ge "$MIN_SIZE" ]; then
    ANSWER=$ANSWER"$DELIMITER"
    echo $ANSWER > $2
  fi
}

mkdir $DOWNLOAD_FOLDER

filecontent=( `cat $TODO_FILE `)

for t in "${filecontent[@]}"
do
  if [ "$CURRENT_TODO" -le 0 ]; then
    while [ $(ps aux | grep curl |wc -l) -ge "$MAX_FORKS" ]
     do
       sleep 0.5
     done
    let "CURRENT_TODO += BLOCK_SIZE"
  fi
  download "$t?$TIME_STAMP" "$DOWNLOAD_FOLDER/$COUNTER" &
  let "COUNTER += 1"    
  let "CURRENT_TODO -= 1"
done

wait

cat $DOWNLOAD_FOLDER/* > $TARGET
rm -rf $DOWNLOAD_FOLDER