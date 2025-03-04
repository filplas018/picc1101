#!/bin/bash

# Nekonečná smyčka
while true; do
    # Vygenerování náhodného čísla (např. 0–9999)
    RANDOM_NUMBER=$((RANDOM % 10000))

    # Odeslání přes picc1101
    sudo ./picc1101 -v1 -B 9600 -P 252 -R7 -M4 -W -l15 -t2 -n5 -y "$RANDOM_NUMBER"

    # Krátká pauza mezi přenosy (možno upravit)
    sleep 1
done
