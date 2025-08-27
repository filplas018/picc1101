import time
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS

# Konfigurace InfluxDB
bucket = "TulSat"
client = InfluxDBClient(
    url="http://tulsat.linux4space.org:8086",
    token="FpcIONo5m9QLHgEiWR1yi8aL3s4I4DJTT93VdEZfzfqSz_fn878H37LJAiTw3SIP5aVX0zaXt6TjiWHD3YB52Q==",
    org="Linux4Space"
)
write_api = client.write_api(write_options=SYNCHRONOUS)

# -----------------------------
# Funkce pro čtení posledního řádku
# -----------------------------
def get_last_line(filepath):
    """Načte a vrátí poslední řádek ze souboru."""
    try:
        with open(filepath, 'r') as f:
            # Čtení řádků od konce pro efektivitu
            last_line = ""
            for line in reversed(f.readlines()):
                if line.strip(): # Přeskočení prázdných řádků
                    last_line = line.strip()
                    break
            return last_line
    except FileNotFoundError:
        print(f"Chyba: Soubor '{filepath}' nebyl nalezen. Ujistěte se, že bash skript běží a vytváří soubor.")
        return None
    except Exception as e:
        print(f"Došlo k chybě při čtení souboru: {e}")
        return None

# -----------------------------
# Hlavní smyčka
# -----------------------------
def main():
    data_file = "mess.txt"
    
    while True:
        last_line = get_last_line(data_file)
        
        if last_line:
            try:
                # Rozdělení dat na jednotlivé hodnoty
                values = last_line.split()
                # Pořadí dat z bash skriptu: teplota_raw, volne_misto_raw, celkove_misto_raw, vyuziti_ram_raw, celkova_ram_raw
                # Upozornění: Pořadí v tvém původním bash skriptu pro `zprava` je:
                # teplota, volné_místo_disk, celkové_místo_disk, využití_ram, celková_ram
                # V Pythonu musíš dodržet toto pořadí
                if len(values) == 5:
                    cpu_temp = float(values[0]) / 1000.0  # Teplota je v tisícinách, převod na °C
                    disk_free = float(values[1])
                    disk_total = float(values[2])
                    ram_used = float(values[3])
                    ram_total = float(values[4])
                    
                    # Vytvoření a odeslání dat do InfluxDB
                    p = (
                        Point("telemetry")
                        .tag("version", "v0.1")
                        .field("CPU temp", cpu_temp)
                        .field("RAM used", ram_used)
                        .field("RAM total", ram_total)
                        .field("Disk free", disk_free)
                        .field("Disk total", disk_total)
                    )

                    write_api.write(bucket=bucket, record=p)

                    print(
                        f"Odesláno: CPU={cpu_temp:.1f} °C, "
                        f"RAM={ram_used:.1f}/{ram_total:.1f} MB, "
                        f"Disk={disk_free:.1f}/{disk_total:.1f} GB"
                    )
                else:
                    print("Neplatný počet datových bodů na posledním řádku.")
            except (ValueError, IndexError):
                print("Chyba při parsování dat. Neplatný formát.")

        # Pauza na 5 sekund
        time.sleep(5)

if __name__ == "__main__":
    main()