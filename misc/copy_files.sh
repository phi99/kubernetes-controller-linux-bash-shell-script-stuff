#!/bin/bash
#copy files which names are provided as arguments on command line to user home dir

USERTARGET=rob
USERHOME=/home/$USERTARGET

echo $USERHOME

if [ -z $1 ]; then
    read -p "Please provide filename " FILENAMES
else
    FILENAMES="$@"
fi

echo
echo "The following filenames have been provided:" $FILENAMES
echo

for i in $FILENAMES; do
  if [ -e "$i" ]; then
      cp $i $USERHOME
  else
      echo "File $i does not exist" 
  fi
done
