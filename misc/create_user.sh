#!/bin/bash
#Allow user to automate user creation task by providing flexibility to enter file with list of username or just enter username directly to script
function user_create() {
  id $1 &> /dev/null
    if [ $? -eq 0 ]; then
        EXIST=$(grep -w ^"$1" /etc/passwd | cut -d: -f1)
        echo "USERNAME $EXIST ALREADY EXIST"
    else
        useradd $1
        if [ $? -eq 0 ]; then
            echo "USER CREATED SUCCESSFULLY"
        else
            echo "PLEASE TRY AGAIN"
        fi
    fi
}

while true; do
  trap "echo Please choose an option" INT TERM TSTP
  echo 'Select option: '
  select TASK in 'enter file' 'enter username' 'logout'
  do
    case $REPLY in
          1)
            read -p "Please enter file: " FILENAME
            for i in $(cat $FILENAME); do
            user_create $i
            done
            break
            ;;
          2)
            read -p "Please enter target user: " USERNAME
            user_create $USERNAME
            break
            ;;
          3)
            exit
            ;;
          *)
            echo "Please enter either file, username, or logout, sir!"
            break
            ;;
    esac
  done
done
