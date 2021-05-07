Warning: Do not use this document until this warning is gone. Testing.

## Bridged Wireless Access Point - Ubuntu 21.04

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend
the network to WiFi capable computers and devices in areas where the
WiFi signal is weak or otherwise does not meet expectations.

#### Single Band

This document outlines a single band setup with a USB3 WiFi adapter for 5g.

#### Information

WPA3-SAE will not work if a Realtek chipset based USB WiFi adapter is used.

-----

2021-05-07

#### Tested Setup

	Desktop system based on an AMD64 processor

	Ubuntu 21.04

	AC1200 USB WiFi Adapter

	Ethernet connection providing internet


#### Setup Steps
-----

USB WiFi adapter driver installation, if required, should be performed and
tested prior to continuing.
-----

Update and reboot system.

```
$ sudo apt update

$ sudo apt full-upgrade

$ sudo reboot
```
-----

Determine the names of the network interfaces.
```
$ ip link show
```
Note: If the interface names are not `eth0` and `wlan0`,
then the interface names used in your system will have to replace
`eth0` and `wlan0` for the remainder of this document.

-----

Install hostapd. Website - [hostapd](https://w1.fi/hostapd/)
```
$ sudo apt install hostapd
```
-----

Enable hostapd service and set it to start on boot.
```
$ sudo systemctl unmask hostapd

$ sudo systemctl enable hostapd
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
# 2021-05-07

# Defaults:
# SSID: myAP
# PASSPHRASE: myPW2021
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
ssid=myAP

# change as required
country_code=US

# enable DFS channels
ieee80211d=1
ieee80211h=1

# a = 5g (a/n/ac)
# g = 2g (b/g/n)
hw_mode=a
channel=36
# channel=149

beacon_int=100
dtim_period=2
max_num_sta=32
macaddr_acl=0
rts_threshold=2347
fragm_threshold=2346
#send_probe_response=1

# security
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
rsn_pairwise=CCMP
# Change as desired
wpa_passphrase=myPW2021
# WPA-2 AES
wpa_key_mgmt=WPA-PSK
# WPA3-AES Transitional
#wpa_key_mgmt=SAE WPA-PSK
# WPA-3 SAE
#wpa_key_mgmt=SAE
#wpa_group_rekey=1800
# ieee80211w=1 is required for WPA-3 SAE Transitional
# ieee80211w=2 is required for WPA-3 SAE
#ieee80211w=1
# if parameter is not set, 19 is the default value.
#sae_groups=19 20 21 25 26
# required for WPA-3 SAETransitional
#sae_require_mfp=1
# if parameter is not 9 set, 5 is the default value.
#sae_anti_clogging_threshold=10

# IEEE 802.11n
ieee80211n=1
wmm_enabled=1
#
# Note: Capabilities can vary even between adapters with the same chipset
#
# rtl8812au - rtl8811au -  rtl8812bu - rtl8811cu - rtl8814au
# band 1 - 2g - 20 MHz channel width
#ht_capab=[SHORT-GI-20][MAX-AMSDU-7935]
# band 2 - 5g - 40 MHz channel width
ht_capab=[HT40+][HT40-][SHORT-GI-20][SHORT-GI-40][MAX-AMSDU-7935]

# IEEE 802.11ac
ieee80211ac=1
#
# rtl8812au - rtl8811au -  rtl8812bu - rtl8811cu - rtl8814au
# band 2 - 5g - 80 MHz channel width
vht_capab=[MAX-MPDU-11454][SHORT-GI-80][HTC-VHT]
# Note: [TX-STBC-2BY1] causes problems

# Required for 80 MHz width channel operation on band 2 - 5g
vht_oper_chwidth=1
#
# Use the next line with channel 36  (36 + 6 = 42) band 2 - 5g
vht_oper_centr_freq_seg0_idx=42
#
# Use the next line with channel 149 (149 + 6 = 155) band 2 - 5g
#vht_oper_centr_freq_seg0_idx=155


# end of hostapd.conf
```
-----

Establish hostapd conf file and log file locations.
```
$ sudo nano /etc/default/hostapd
```
Add to bottom of file
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
DAEMON_OPTS="-d -K -f /home/pi/hostapd.log"
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
when your system boots.
```
$ sudo systemctl enable systemd-networkd
```
-----

Block the eth0 and wlan0 interfaces from being processed, and let dhcpcd
configure only br0 via DHCP.
```
$ sudo nano /etc/dhcpcd.conf
```
Add the following line above the first `interface xxx` line, if any
```
denyinterfaces eth0 wlan0
```
Go to the end of the file and add the following line
```
interface br0
```
-----

Ensure WiFi radio is not blocked.
```
$ sudo rfkill unblock wlan
```
-----

Reboot system.
```
$ sudo reboot
```
-----
