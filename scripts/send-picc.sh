#!/bin/bash

# Kontrola argumentu
if [ -z "$1" ]; then
  echo "Použití: sudo ./send-picc \"zpráva\""
  exit 1
fi

# Odeslání zprávy přes picc1101
./picc1101 -v1 -B 9600 -P 252 -R7 -M4 -W -l15 -t2 -y "$1"