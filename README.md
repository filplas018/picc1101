picc1101
========

Connect Raspberry-Pi to CC1101 RF module and play with AX.25/KISS to transmit TCP/IP over the air.

# Introduction
The aim of this program is to connect a RF module based on the Texas Instruments (Chipcon) chip CC1101 to a Raspberry-Pi host machine. The CC1101 chip is a OOK/2-FSK/4-FSK/MSK/GFSK low power (~10dBm) digital transceiver working in the 315, 433 and 868 MHz ISM bands. The 433 MHz band also happens to cover the 70cm Amateur Radio band and the major drive of this work is to use these modules as a modern better alternative to the legacy [Terminal Node Controllers](http://en.wikipedia.org/wiki/Terminal_node_controller) or TNCs working in 1200 baud FM AFSK or 9600 baud G3RUH true 2-FSK modulation at best. Using the Linux native AX.25 and KISS interface to the TNCs it is then possible to route TCP/IP traffic using these modules offering the possibility to connect to the Amateur Radio private IP network known as [Hamnet](http://hamnetdb.net/).

Another opportunity is the direct transmission of a Transport Stream to carry low rate live video and this will be studied later.

These RF modules are available from a variety of sellers on eBay (search for words 'CC1101' and '433 MHz') and the Raspberry-Pi doesn't need to be introduced any further!

The CC1101 chip implements preamble, sync word, CRC, data whitening and FEC using convolutive coding natively. It is a very nice little cheap chip for our purpose. It has all the necessary features to cover the OSI layer 1 (physical). Its advertised speed ranges from 600 to 500000 Baud (300000 in 4-FSK) but it can go as low as 50 baud however details on performance at this speed have not been investigated. Yet the program offers this possibility.

The CC1101 chip is interfaced using a SPI bus that is implemented natively on the Raspberry-PI and can be accessed through the `spidev` library. In addition two GPIOs must be used to support the handling of the CC1101 Rx and Tx FIFOs. For convenience GPIO-24 and GPIO-25 close to the SPI bus on the Raspberry-Pi are chosen to be connected to the GDO0 and GDO2 lines of the CC1101 respectively. The WiringPi library is used to support the GPIO interrupt handling.

The CC1101 data sheet is available [here](www.ti.com/lit/ds/symlink/cc1101.pdf).

# Disclaimer
You are supposed to use the CC1101 modules and this software sensibly. Please check your local radio spectrum regulations. For Amateur Radio use you should have a valid Amateur Radio licence with a callsign and transmit in the bands and conditions granted by your local regulations also please try to respect the IARU band plan. 

# Installation and basic usage
## Prerequisites
This has been tested on a Raspberry Pi version 1 B with kernel 3.12.36. Raspberry Pi version 2 with 3.18 kernels using dtbs has not been working satifactorily so far. Version 2 is very new (in March 2015) and improvements are expected concerning SPI and GPIO handling and it will probably work one day on the version 2 as well. Anyway version 1 has enough computing power for our purpose.

For best performance you will need the DMA based SPI driver for BCM2708 found [here](https://github.com/notro/spi-bcm2708.git) After successful compilation you will obtain a kernel module that is to be stored as `/lib/modules/$(uname -r)/kernel/drivers/spi/spi-bcm2708.ko` 

You will have to download and install the WiringPi library found [here](http://wiringpi.com/) 

The process relies heavily on interrupts that must be served in a timely manner. You are advised to reduce the interrupts activity by removing USB connected devices as much as possible.

## Obtain the code
Just clone this repository in a local folder of your choice on the Raspberry Pi

## Compilation
You can compile on the Raspberry Pi v.1 as it doesn't take too much time even on the single core BCM2735. You are advised to activate the -O3 optimization:
  - `CFLAGS=-O3; make`

The result is the `picc1101` executable in the same directory

## Run test programs
On the sending side:
  - `sudo ./picc1101 -v1 -B 9600 -P 250 -R7 -M4 -W -l20 -t2 -n5`

On the receiving side:
  - `sudo ./picc1101 -v1 -B 9600 -P 250 -R7 -M4 -W -l20` -t4 -n5`

This will send 5 blocks of 250 bytes at 9600 Baud using GFSK modulation and receive them at the other end.

Note that you have to be super user to execute the program.

## Program options
<pre><code>
  -B, --serial-speed=SERIAL_SPEED
                             TNC Serial speed in Bauds (default : 9600)
  -d, --spi-device=SPI_DEVICE   SPI device, (default : /dev/spidev0.0)
  -D, --serial-device=SERIAL_DEVICE
                             TNC Serial device, (default : /var/ax25/axp2)
  -f, --frequency=FREQUENCY_HZ   Frequency in Hz (default: 433600000)
  -F, --fec                  Activate FEC (default off)
  -H, --long-help            Print a long help and exit
  -l, --packet-delay=DELAY_UNITS   Delay before sending packet on serial or
                             radio in 4 2-FSK symbols approximately. (default
                             30)
  -m, --modulation-index=MODULATION_INDEX
                             Modulation index (default 0.5)
  -M, --modulation=MODULATION_SCHEME
                             Radio modulation scheme, See long help (-H)
                             option
  -n, --repetition=REPETITION   Repetiton factor wherever appropriate, see long
                             Help (-H) option (default : 1 single)
  -P, --packet-length=PACKET_LENGTH
                             Packet length (fixed) or maximum packet length
                             (variable) (default: 250)
  -R, --rate=DATA_RATE_INDEX Data rate index, See long help (-H) option
  -s, --radio-status         Print radio status and exit
  -t, --test-mode=TEST_SCHEME   Test scheme, See long help (-H) option fpr
                             details (default : 0 no test)
  -v, --verbose=VERBOSITY_LEVEL   Verbosiity level: 0 quiet else verbose level
                             (default : quiet)
  -V, --variable-length      Variable packet length. Given packet length
                             becomes maximum length (default off)
  -w, --rate-skew=RATE_MULTIPLIER
                             Data rate skew multiplier. (default 1.0 = no
                             skew)
  -W, --whitening            Activate whitening (default off)
  -y, --test-phrase=TEST_PHRASE   Set a test phrase to be used in test (default
                             : "Hello, World!")
  -?, --help                 Give this help list
      --usage                Give a short usage message
      --version              Print program version
</code></pre>

Note: variable length blocks are not implemented yet.

## Detailed options
### Radio interfece speeds (-R)
<pre><code>
Value:  Rate (Baud):
 0  50
 1  110
 2  300
 3  600
 4  1200
 5  2400
 6  4800
 7  9600
 8  14400
 9  19200
10  28800
11  38400
12  57600
13  76800
14  115200
15  250000
16  500000 (300000 for 4-FSK)
</code></pre>

### Modulations (-M)
<pre><code>
Value:  Scheme:
0   OOK
1   2-FSK
2   4-FSK
3   MSK
4   GFSK
</code></pre>

### Test routines (-t)
<pre><code>
Value:  Scheme:
0   No test (KISS virtual TNC)
1   Simple Tx with polling. Packet smaller than 64 bytes
2   Simple Tx with packet interrupt handling. Packet up to 255 bytes
3   Simple Rx with polling. Packet smaller than 64 bytes
4   Simple Rx with packet interrupt handling. Packet up to 255 bytes
</code></pre>

# AX.25/KISS operation
## Set up the AX.25/KISS environment
### Kernel modules
You will need to activate the proper options in the `make menuconfig` of your kernel compilation in order to get the `ax25` and `mkiss` modules. It comes by default in most pre-compiled kernels.

Load the modules with `modprobe` command:
  - `sudo modprobe ax25`
  - `sudo modprobe mkiss`

Alternatively you can specify these modules to be loaded at boot time by adding their names in the `/etc/modules` file

### Install AX.25 and KISS software
  - `sudo apt-get install ax25-apps ax25-node ax25-tools libax25`

### Create your AX.25 interfaces configuration
In `/etc/ax25/axports` you have to add a line with:
  - `<interface name> <callsign and suffix> <speed> <window size> <comment>`
  - *interface name* is any name you will refer this interface to later
  - *callsign and suffix* is your callsign and a suffix from 0 to 15. Ex: `F4EXB-14`
  - *speed* is the speed in Baud. This has not been found really effective. The speed will be determined by the settings of the CC1101 itself and the TCP/IP flow will adapt to the actual speed.
  - *window size* is a number fron 1 to 7 and is the maximum number of packets before an acknowledgement is required (doesn't really work with KISS)
  - *comment* is any descriptive comment

Example:
<pre><code>
# /etc/ax25/axports
#
# The format of this file is:
#
# name callsign speed paclen window description
#
radio0  F4EXB-14           9600  220     1       Hamnet CC1101
radio1  F4EXB-15           9600  220     1       Hamnet CC1101
#1      OH2BNS-1           1200  255     2       144.675 MHz (1200  bps)
#2      OH2BNS-9          38400  255     7       TNOS/Linux  (38400 bps)
</code></pre>

### Create a virtual serial link
 - `socat d -d pty,link=/var/ax25/axp1,raw,echo=0 pty,link=/var/ax25/axp2,raw,echo=0 &`

Note the `&` at the end that allows the command to run in background.

This creates two serial devices at the end of a virtual serial cable. 
They are accessible via the symlinks specified in the command:
  - /var/ax25/axp1
  - /var/ax25/axp2

### Create the network device using kissattach
  - `sudo kissattach /var/ax25/axp1 radio0 10.0.0.7`
  - `sudo ifconfig ax0 netmask 255.255.255.0`

This will create the ax0 network device as shown by the `/sbin/ifconfig` command:
<pre><code>
ax0       Link encap:AMPR AX.25  HWaddr F4EXB-15  
          inet addr:10.0.1.7  Bcast:10.0.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING  MTU:220  Metric:1
          RX packets:3033 errors:24 dropped:0 overruns:0 frame:0
          TX packets:3427 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:10 
          RX bytes:483956 (472.6 KiB)  TX bytes:446797 (436.3 KiB)
</code></pre>

### Scripts that will run these commands
In the `scripts` directory you will find:
  - `kissdown.sh`: kills all processes and removes the `ax0` network interface from the system
  - `kissup.sh <IP> <Netmask>`: brings up the `ax0` network interface with IP addres <IP> and net mask <Netmask>

Examples:
  - `./kissdown.sh`
  - `./kissup.sh 10.0..1.3 255.255.255.0`

## Run the program
This example will set the CC1101 at 9600 Baud with GFSK modulation:

  - `sudo ./picc1101 -v1 -B 9600 -P 250 -R7 -M4 -W -l20`

Other options are:
  - verbosity level (-v) of 1 will only display basic execution messages, errors and warnings
  - radio block size (-P) is fixed at 250 bytes
  - data whitening is in use (-W)
  - inter-block pause is set for a 20 bytes transmission time approximately (-l) 

Note that you have to be super user to execute the program.