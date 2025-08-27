#!/bin/bash

while true; do
  # Získání teploty CPU
  teplota_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
  
  # Získání volného a celkového místa na disku (v MB, zaokrouhleně)
  # Příkaz 'df -m' zobrazí hodnoty v MB.
  volne_misto_raw=$(df -m / | awk 'NR==2 {print $4}')
  celkove_misto_raw=$(df -m / | awk 'NR==2 {print $2}')

  # Získání využití a celkové kapacity RAM (v MB)
  # Příkaz 'free -m' zobrazí hodnoty v MB.
  vyuziti_ram_raw=$(free -m | awk 'NR==2 {print $3}')
  celkova_ram_raw=$(free -m | awk 'NR==2 {print $2}')

  # Sestavení zprávy - nyní obsahuje 5 hodnot
  zprava="${teplota_raw} ${volne_misto_raw} ${celkove_misto_raw} ${vyuziti_ram_raw} ${celkova_ram_raw}"

  # Odeslání zprávy
  picc1101 -v1 -B 9600 -P 252 -R7 -M4 -W -l15 -t2 -y "$zprava"

  echo "Odeslána zpráva: $zprava"
  echo "(teplota volné místo celkové místo využitá RAM celková RAM)"

  # Pauza na 5 sekund
  sleep 5
done