## Bridged Wireless Access Point

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend the
network to WiFi capable computers and devices in areas where the WiFi
signal is weak or otherwise does not meet expectations.

#### Single Band

This document outlines a single band setup using the Raspberry Pi 4B
with a USB 3 WiFi adapter for 5g.

#### Information

This setup supports WPA3-SAE personal.

-----

2021-03-16

#### Tested Setup

	Raspberry Pi 4B (4gb)

	Raspberry Pi OS (2021-01-11) (32 bit) (kernel 5.10.11-v7l+)

	AC1200 USB WiFi Adapter
		[Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi)

	Ethernet connection providing internet

Note: Very few Powered USB 3 Hubs will work well with Raspberry Pi
hardware. The primary problem has to do with the backfeeding of
current into the Raspberry Pi. I have avoided using a powered hub
in this setup to enable a very high degree of stability.

Note: The Alfa AWUS036ACM adapter requests a maximum of 400 mA from
the USB subsystem during initialization. Testing with a meter shows
actual usage of 360 mA during heavy load and usage of 180 mA during
light loads. This is much lower power usage than most AC1200 class
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

Reduce overall power consumption and overclock the CPU a modest amount.

Note: all items in this step are optional
```
$ sudo nano /boot/config.txt
```
Change
```
# turn off onboard audio
dtparam=audio=off

# Enable DRM VC4 V3D driver on top of the dispmanx display stack
#dtoverlay=vc4-fkms-v3d
#max_framebuffers=2
```
Add
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

# turn off WiFi
dtoverlay=disable-wifi

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
Note: If the interface names are not `eth0` and `wlan0`, then
the interface names used in your system will have to replace `eth0` and
`wlan0` for the remainder of this document.

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

Block the eth0 and wlan0 interfaces from being processed, and let dhcpcd
configure only br0 via DHCP.
```
$ sudo nano /etc/dhcpcd.conf
```
Add the following line above the first ```interface xxx``` line, if any
```
denyinterfaces eth0 wlan0
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

Create the hostapd configuration file.
```
$ sudo nano /etc/hostapd/hostapd.conf
```
File contents
```
# /etc/hostapd/hostapd.conf
# Documentation: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
# 2021-03-16

# Defaults:
# SSID: pi
# PASSPHRASE: raspberry
# Band: 5g
# Channel: 36
# Country: US

# needs to match your system
interface=wlan0

bridge=br0
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0

# change as desired
ssid=pi

# change as required
country_code=US

# enable DFS channels
ieee80211d=1
ieee80211h=1

# 2g (b/g/n)
#hw_mode=g
#channel=6
#
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
auth_algs=3
ignore_broadcast_ssid=0
wpa=2
#wpa_pairwise=CCMP
rsn_pairwise=CCMP
# Change as desired
wpa_passphrase=raspberry
# WPA-2 AES
#wpa_key_mgmt=WPA-PSK
# WPA3-AES Transitional
wpa_key_mgmt=SAE WPA-PSK
# WPA-3 SAE
#wpa_key_mgmt=SAE
#wpa_group_rekey=1800
# ieee80211w=1 is required for WPA-3 SAE Transitional
# ieee80211w=2 is required for WPA-3 SAE
ieee80211w=1
# If parameter is not set, 19 is the default value.
#sae_groups=19 20 21 25 26
required for WPA-3 SAE Transitional
sae_require_mfp=1
# If parameter is not 9 set, 5 is the default value.
#sae_anti_clogging_threshold=10

# IEEE 802.11n
# 2g and 5g
ieee80211n=1
wmm_enabled=1
#
# mt7612u
# band 1 - 2g - 20 MHz channel width
#ht_capab=[LDPC][SHORT-GI-20][TX-STBC][RX-STBC1]
# band 2 - 5g - 40 MHz channel width
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

Establish conf file and log file locations.
```
$ sudo nano /etc/default/hostapd
```
Add to bottom of file
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
DAEMON_OPTS="-d -K -f /home/pi/hostapd.log"
```
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
