#!/bin/bash

# Nekonečná smyčka
while true; do
    sudo ./picc1101 -v1 -B 9600 -P 252 -R7 -M4 -W -l15 -t4

    sleep 1
done
