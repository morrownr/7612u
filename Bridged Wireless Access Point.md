## Bridged Wireless Access Point

A bridged wireless access point works within an existing
ethernet network to extend the network to WiFi capable computers
and devices in areas where the WiFi signal is weak or otherwise
does not meet expectations.

Known issues

	WPA3-SAE operation is not testing good at this time and is disabled.


This document is for WiFi adapters based on the following chipsets

```
mt7612u
```

Links to adapters that are based on this chipset can be found at this site

```
[https://github.com/morrownr/USB-WiFi](https://github.com/morrownr/USB-WiFi)
```

2021-02-25

#### Tested Setup

	Raspberry Pi 4B (4gb)

	Raspberry Pi OS (2021-01-11) (32 bit) (kernel 5.10.11-v7l+)

	Raspberry Pi Onboard WiFi disabled

	USB WiFi Adapter based on the mt7612u chipset

	WiFi Adapter Driver - the driver is in the kernel (PnP)

	Ethernet connection providing internet
		Ethernet cables are CAT 6
		Internet is fiber-optic at 1 Gbps up and 1 Gbps down


#### Steps
-----

Update system.

```
$ sudo apt update

$ sudo apt dist-upgrade
```
-----

Disable Raspberry Pi onboard WiFi and Overclock the CPU.

Note: This step is specific to Raspberry Pi 4B hardware.
```
$ sudo nano /boot/config.txt
```
Add
```
dtoverlay=disable-wifi
over_voltage=2
arm_freq=1750
```
-----

Install needed package.
```
$ sudo apt install hostapd
```
-----

Reboot system.
```
$ sudo reboot
```
-----

Enable the wireless access point service and set it to start
   when your Raspberry Pi boots.
```
$ sudo systemctl unmask hostapd

$ sudo systemctl enable hostapd
```
-----

Add a bridge network device named br0 by creating a file using
   the following command, with the contents below.
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
Note: If the interface names are not ```eth0``` and ```wlan0```, then the
interface names used in your system will have to replace eth0
and wlan0 during the remainder of this document.

-----

Bridge the Ethernet network with the wireless network, first
   add the built-in Ethernet interface ( eth0 ) as a bridge
   member by creating the following file.
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

Enable the systemd-networkd service to create and populate
    the bridge when your Raspberry Pi boots.
```
$ sudo systemctl enable systemd-networkd
```
-----

Block the eth0 and wlan0 interfaces from being
    processed, and let dhcpcd configure only br0 via DHCP.
```
$ sudo nano /etc/dhcpcd.conf
```
Add the following line above the first ```interface xxx``` line, if any
```
denyinterfaces wlan0 eth0
```
Go to the end of the file and add the following line
```
interface br0
```
-----

To ensure WiFi radio is not blocked on your Raspberry Pi,
    execute the following command.
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
# https://w1.fi/hostapd/
# 2g, 5g, a/b/g/n/ac
# 2021-02-24

# Needs to match your system
interface=wlan0

bridge=br0
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0

# Change as desired
ssid=pi

# Change as required
country_code=US

# Enable DFS channels
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
send_probe_response=1

# Security
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
ieee80211w=1
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
# 20 MHz channel width for band 1 - 2g
#ht_capab=[LDPC][SHORT-GI-20][TX-STBC][RX-STBC1]
# 40 MHz channel width for band 2 - 5g
ht_capab=[LDPC][HT40+][HT40-][GF][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]

# IEEE 802.11ac
# 5g
ieee80211ac=1
#
# mt7612u
vht_capab=[RXLDPC][TX-STBC-2BY1][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
#
# Required for 80 MHz width channel operation
vht_oper_chwidth=1
#
# Use the next line with channel 36
vht_oper_centr_freq_seg0_idx=42
#
# Use the next with channel 149
#vht_oper_centr_freq_seg0_idx=155

# Event logger
#logger_syslog=-1
#logger_syslog_level=2
#logger_stdout=-1
#logger_stdout_level=2

# end of hostapd.conf
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

iperf3
```
$ iperf3 -c 192.168.1.40
Connecting to host 192.168.1.40, port 5201
[  5] local 192.168.1.36 port 51418 connected to 192.168.1.40 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  44.0 MBytes   369 Mbits/sec    0   1007 KBytes       
[  5]   1.00-2.00   sec  48.8 MBytes   409 Mbits/sec    0   1.20 MBytes       
[  5]   2.00-3.00   sec  46.2 MBytes   388 Mbits/sec    0   1.40 MBytes       
[  5]   3.00-4.00   sec  47.5 MBytes   398 Mbits/sec    0   1.40 MBytes       
[  5]   4.00-5.00   sec  46.2 MBytes   388 Mbits/sec    0   1.49 MBytes       
[  5]   5.00-6.00   sec  47.5 MBytes   398 Mbits/sec    0   1.49 MBytes       
[  5]   6.00-7.00   sec  46.2 MBytes   388 Mbits/sec    0   1.60 MBytes       
[  5]   7.00-8.00   sec  47.5 MBytes   398 Mbits/sec    0   1.60 MBytes       
[  5]   8.00-9.00   sec  47.5 MBytes   398 Mbits/sec    0   1.60 MBytes       
[  5]   9.00-10.00  sec  46.2 MBytes   388 Mbits/sec    0   1.66 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec   468 MBytes   392 Mbits/sec    0   sender
[  5]   0.00-10.01  sec   465 MBytes   390 Mbits/sec        receiver

```
