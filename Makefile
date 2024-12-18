EXTRA_CFLAGS := -DMAX_VERBOSE_LEVEL=4
CFLAGS += -I/usr/local/include     # Přidává cestu k WiringPi hlavičkám
LDFLAGS += -L/usr/local/lib        # Přidává cestu k WiringPi knihovnám
LIBS := -lm -lwiringPi                 # Definice WiringPi knihovny odděleně

all: picc1101

clean:
	rm -f *.o picc1101

picc1101: main.o serial.o pi_cc_spi.o radio.o kiss.o util.o test.o
	$(CCPREFIX)gcc $(LDFLAGS) -o picc1101 main.o serial.o pi_cc_spi.o radio.o kiss.o util.o test.o $(LIBS)

main.o: main.h main.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o main.o main.c

serial.o: main.h serial.h serial.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o serial.o serial.c

pi_cc_spi.o: main.h pi_cc_spi.h pi_cc_spi.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o pi_cc_spi.o pi_cc_spi.c

radio.o: main.h radio.h radio.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o radio.o radio.c

kiss.o: main.h kiss.h kiss.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o kiss.o kiss.c

test.o: test.h test.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o test.o test.c

util.o: util.h util.c
	$(CCPREFIX)gcc $(CFLAGS) $(EXTRA_CFLAGS) -c -o util.o util.c
