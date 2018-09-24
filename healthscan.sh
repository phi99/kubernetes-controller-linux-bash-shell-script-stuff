#!/bin/ash

#ping scan to multiple host listed in target file and analyze error and packet loss 

for i in `cat target`
do 
    OUTPUT=$(ping -c 1 -q $i | grep transmitted)
    ERROR_INDICATOR=$(echo $OUTPUT | grep errors)

        if [ -z "$ERROR_INDICATOR" ]
        then
            LOSS=$(echo $OUTPUT | cut -d ',' -f3)
            echo "$i no error"
        else
            LOSS=$(echo $OUTPUT | cut -d ',' -f4)
            ERROR=$(echo $OUTPUT | cut -d ',' -f3)
            echo "$i ERROR value is $ERROR" 
        fi
       
  	    echo "$i LOSS value is $LOSS"

done
