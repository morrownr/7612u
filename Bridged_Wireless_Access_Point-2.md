## Bridged Wireless Access Point

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend the
network to WiFi capable computers and devices in areas where the WiFi
signal is weak or otherwise does not meet expectations.

#### Dual Band

This document outlines a dual band setup using the Raspberry Pi 4B
onboard WiFi for 2g and a USB 3 WiFi adapter for 5g.

#### Information

Known issues

	WPA3-SAE is not testing good at this time and is disabled.

The [home location](https://github.com/morrownr/7612u) of this document.

This document is for WiFi adapters based on the following chipset -

```
mt7612u
```
Tested WiFi adapter

[Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi)

-----

2021-03-08

#### Tested Setup

	Raspberry Pi 4B (4gb)

	Optional - Powered USB 3 Hub - Transcend TS-HUB3K

	Raspberry Pi OS (2021-01-11) (32 bit) (kernel 5.10.11-v7l+)

	Optional - Raspberry Pi Onboard WiFi disabled

	AC1200 USB WiFi Adapter - Alfa AWUS036ACM

	WiFi Adapter Driver - the driver is in the kernel (PnP)

	Ethernet connection providing internet
		Ethernet cables are CAT 6
		Internet is fiber-optic at 1 Gbps up and 1 Gbps down

Note: Very few Powered USB 3 Hubs will work well with Raspberry Pi
hardware. The primary problem has to do with the backfeeding of
current into the Raspberry Pi. Testing here has shown that the
Transcend TS-HUB3K works well. This hub has a side port that works
well for the Alfa AWUS036ACM adapter while leave the three ports
on the front of the hub available for other peripherals.

Note: The Alfa AWUS036ACM adapter requests a maximum of 400 mA from
the USB subsystem during initialization. Testing with a meter shows
actual usage of 360 mA during heavy load and usage of 180 mA during
light loads. This is much lower power usage than many AC1200 class
adapters which makes this adapter a good choice for a Raspberry Pi 4B
which has an overall limit of 1200 mA power available via the USB
subsystem. This adapter does not require usb-modeswitch.


#### Setup Steps
-----

Update system.

```
$ sudo apt update

$ sudo apt full-upgrade
```
-----

Disable various LEDs, Bluetooth and Overclock the CPU.
```
$ sudo nano /boot/config.txt
```
Add (all items in this step are optional)
```
# turn off Mainboard LEDs
dtoverlay=act-led

# disable Activity LED
dtparam=act_led_trigger=none
dtparam=act_led_activelow=off

# disable Power LED
dtparam=pwr_led_trigger=none
dtparam=pwr_led_activelow=off

# turn off Ethernet port LEDs
dtparam=eth_led0=4
dtparam=eth_led1=4

# turn off Bluetooth
dtoverlay=disable-bt

# overclock CPU
over_voltage=1
arm_freq=1600
```
-----

Install needed package. Website - [hostapd](https://w1.fi/hostapd/)
```
$ sudo apt install hostapd
```
-----

Reboot system.
```
$ sudo reboot
```
-----

Enable the wireless access point service and set it to start when your
Raspberry Pi boots.
```
$ sudo systemctl unmask hostapd

$ sudo systemctl enable hostapd
```
-----

Add a bridge network device named br0 by creating a file using the
following command, with the contents below.
```
$ sudo nano /etc/systemd/network/bridge-br0.netdev
```
File contents
```
[NetDev]
Name=br0
Kind=bridge
```
-----

Determine the names of the network interfaces.
```
$ ip link
```
Note: If the interface names are not eth0, wlan0 and wlan1, then the
interface names used in your system will have to replace eth0 and
wlan0 during the remainder of this document.

-----

Bridge the Ethernet network with the wireless network, first add the
built-in Ethernet interface ( eth0 ) as a bridge member by creating the
following file.
```
$ sudo nano /etc/systemd/network/br0-member-eth0.network
```
File contents
```
[Match]
Name=eth0

[Network]
Bridge=br0
```
-----

Enable the systemd-networkd service to create and populate the bridge
when your Raspberry Pi boots.
```
$ sudo systemctl enable systemd-networkd
```
-----

Block the eth0, wlan0 and wlan1 interfaces from being processed, and let
dhcpcd configure only br0 via DHCP.
```
$ sudo nano /etc/dhcpcd.conf
```
Add the following line above the first ```interface xxx``` line, if any
```
denyinterfaces eth0 wlan0 wlan1
```
Go to the end of the file and add the following line
```
interface br0
```
-----

To ensure WiFi radio is not blocked on your Raspberry Pi, execute the
following command.
```
$ sudo rfkill unblock wlan
```
-----

Create the 5g hostapd configuration file.
```
$ sudo nano /etc/hostapd/hostapd-5g.conf
```
File contents
```
# /etc/hostapd/hostapd-5g.conf
# Documentation: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
# 2021-03-07

# Defaults:
# SSID: pi4-5
# PASSPHRASE: raspberry
# Band: 5g
# Channel: 36
# Country: US

# needs to match your system
interface=wlan1

bridge=br0
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0

# change as desired
ssid=pi4-5

# change as required
country_code=US

# enable DFS channels
ieee80211d=1
ieee80211h=1

# 5g (a/n/ac)
hw_mode=a
channel=36
# channel=149

beacon_int=100
dtim_period=1
max_num_sta=32
macaddr_acl=0
ignore_broadcast_ssid=0
rts_threshold=2347
fragm_threshold=2346
#send_probe_response=1

# security
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_pairwise=CCMP
# Change as desired
wpa_passphrase=raspberry
# WPA-2 AES
wpa_key_mgmt=WPA-PSK
# WPA-3 SAE
#wpa_key_mgmt=SAE
#wpa_group_rekey=1800
rsn_pairwise=CCMP
# ieee80211w=2 is required for WPA-3 SAE
ieee80211w=2
# If parameter is not set, 19 is the default value.
#sae_groups=19 20 21 25 26
#sae_require_mfp=1
# If parameter is not 9 set, 5 is the default value.
#sae_anti_clogging_threshold=10

# IEEE 802.11n
# 2g and 5g
ieee80211n=1
wmm_enabled=1
#
# mt7612u
# band 2 - 5g
ht_capab=[LDPC][HT40+][HT40-][GF][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]

# IEEE 802.11ac
# 5g
ieee80211ac=1
#
# mt7612u
# Band 2 - 5g
vht_capab=[RXLDPC][TX-STBC-2BY1][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]

# Required for 80 MHz width channel operation
# Band 2 - 5g
vht_oper_chwidth=1
#
# Use the next line with channel 36
# Band 2 - 5g
vht_oper_centr_freq_seg0_idx=42
#
# Use the next with channel 149
# Band 2 - 5g
#vht_oper_centr_freq_seg0_idx=155

# End of hostapd.conf
```
-----

Create the 2g hostapd configuration file.
```
$ sudo nano /etc/hostapd/hostapd-2g.conf
```
File contents
```
# /etc/hostapd/hostapd-2g.conf
# Documentation: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
# 2021-03-07

# Defaults:
# SSID: pi4-2
# PASSPHRASE: raspberry
# Band: 2g
# Channel: 6
# Country: US

# needs to match your system
interface=wlan0

bridge=br0
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0

# change as desired
ssid=pi4-2

# change as required
country_code=US

# 2g (b/g/n)
hw_mode=g
channel=6

beacon_int=100
dtim_period=1
max_num_sta=32
macaddr_acl=0
ignore_broadcast_ssid=0
rts_threshold=2347
fragm_threshold=2346
#send_probe_response=1

# security
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_pairwise=CCMP
# Change as desired
wpa_passphrase=raspberry
# WPA-2 AES
wpa_key_mgmt=WPA-PSK
# WPA-3 SAE
#wpa_key_mgmt=SAE
#wpa_group_rekey=1800
rsn_pairwise=CCMP
# ieee80211w=2 is required for WPA-3 SAE
#ieee80211w=2
# If parameter is not set, 19 is the default value.
#sae_groups=19 20 21 25 26
#sae_require_mfp=1
# If parameter is not 9 set, 5 is the default value.
#sae_anti_clogging_threshold=10

# IEEE 802.11n
ieee80211n=1
wmm_enabled=1
#
# # band 1 - 2g - 20 MHz channel width
#ht_capab=[SHORT-GI-20]

# End of hostapd.conf
```
-----

Establish conf file and log file locations.
```
$ sudo nano /etc/default/hostapd
```
Add to bottom of file
```
DAEMON_CONF="/etc/hostapd/hostapd-5g.conf /etc/hostapd/hostapd-2g.conf"
DAEMON_OPTS="-d -K -f /home/pi/hostapd.log"
```
-----

Modify hostapd.service file.
```
$ cp /usr/lib/systemd/system/hostapd.service /etc/systemd/system/hostapd.service
```
```
$ sudo nano /etc/systemd/system/hostapd.service
```
Change contents to the following
```
[Unit]
Description=Advanced IEEE 802.11 AP and IEEE 802.1X/WPA/WPA2/EAP Authenticator
After=network.target

[Service]
Type=forking
PIDFile=/run/hostapd.pid
Restart=on-failure
RestartSec=2
Environment=DAEMON_CONF="/etc/hostapd/hostapd-5g.conf /etc/hostapd/hostapd-2g.conf"
EnvironmentFile=-/etc/default/hostapd
ExecStart=/usr/sbin/hostapd -B -P /run/hostapd.pid -B $DAEMON_OPTS $DAEMON_CONF

[Install]
WantedBy=multi-user.target
```
Note that the 'Environment=' line and 'ExecStart=' line have been modified.

-----

Reboot system.

$ sudo reboot

-----

Enjoy!

-----

iperf3 results - 5g
```
$ iperf3 -c 192.168.1.40
Connecting to host 192.168.1.40, port 5201
[  5] local 192.168.1.83 port 43192 connected to 192.168.1.40 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  47.6 MBytes   400 Mbits/sec    0   1.50 MBytes
[  5]   1.00-2.00   sec  52.5 MBytes   440 Mbits/sec    0   1.91 MBytes
[  5]   2.00-3.00   sec  51.2 MBytes   430 Mbits/sec    0   2.49 MBytes
[  5]   3.00-4.00   sec  52.5 MBytes   440 Mbits/sec    0   2.49 MBytes
[  5]   4.00-5.00   sec  50.0 MBytes   419 Mbits/sec    0   2.49 MBytes
[  5]   5.00-6.00   sec  52.5 MBytes   440 Mbits/sec    0   2.49 MBytes
[  5]   6.00-7.00   sec  51.2 MBytes   430 Mbits/sec    0   2.49 MBytes
[  5]   7.00-8.00   sec  51.2 MBytes   430 Mbits/sec    0   2.49 MBytes
[  5]   8.00-9.00   sec  50.0 MBytes   419 Mbits/sec    0   2.49 MBytes
[  5]   9.00-10.00  sec  55.0 MBytes   461 Mbits/sec    0   2.49 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   514 MBytes   431 Mbits/sec    0   sender
[  5]   0.00-10.01  sec   511 MBytes   428 Mbits/sec        receiver

```