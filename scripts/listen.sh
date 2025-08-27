#!/bin/bash


LOGFILE="mess.txt"


while read line1
do
    if [[ "$line1" =~ \"(.*)\" ]]; then
        message="${BASH_REMATCH[1]}"
        
        echo "$message" >> "$LOGFILE"
        
        
        echo "Nová zpráva '$message' byla uložena do souboru $LOGFILE"
    fi
    
    
    read line2
    
done < <(picc1101 -v1 -B 9600 -P 252 -R7 -M4 -W -l15 -t4)