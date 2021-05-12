Warning: Testing in progress.

## Bridged Wireless Access Point - Ubuntu 21.04

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend
the network to WiFi capable computers and devices in areas where the
WiFi signal is weak or otherwise does not meet expectations.

This guide disables Network Manager and makes use of systemd-networkd
so as to provide consistency among the various Linux platforms that
are supported.

#### Single Band

This document outlines a single band setup with a USB3 WiFi adapter for 5g.

#### Information

This setup supports WPA3-SAE. It is turned off by default.

WPA3-SAE will not work if a Realtek 88xx chipset based USB WiFi adapter is used.

WPA3-SAE will work if a Mediatek 761x chipset based USB WiFI adapter is used.

-----

2021-05-11

#### Tested Setup

	Desktop system based on a x64/AMD64 processor

	Ubuntu 21.04

	AC1200/AC1300 USB WiFi Adapter in AP mode

	Ethernet connection providing internet service


#### Setup Steps

-----

Install and configure USB WiFi adapter.

Note: For full speed operation in AP mode module parameters may be required.
```
Realtek: rtw_vht_enable=2 rtw_switch_usb_mode=1

Mediatek: disable_usb_sg=1
```
-----

Update, upgrade and reboot system.

```
$ sudo apt update

$ sudo apt full-upgrade

$ sudo reboot
```
-----

Determine the names and state of the network interfaces.
```
$ ip a
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
# 2021-05-12

# Defaults:
# SSID: myAP
# PASSPHRASE: myPW2021
# Band: 5g
# Channel: 36
# Country: US

# needs to match wireless interface in your system
interface=<wlan0>

# needs to match bridge interface name in your system
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
# change wpa_passphrase as desired
wpa_passphrase=myPW2021
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
rsn_pairwise=CCMP
# only one wpa_key_mgmt= line should be active.
# wpa_key_mgmt=WPA-PSK is required for WPA2-AES
wpa_key_mgmt=WPA-PSK
# wpa_key_mgmt=SAE WPA-PSK is required for WPA3-AES Transitional
#wpa_key_mgmt=SAE WPA-PSK
# wpa_key_mgmt=SAE is required for WPA3-SAE
#wpa_key_mgmt=SAE
#wpa_group_rekey=1800
# ieee80211w=1 is required for WPA-3 SAE Transitional
# ieee80211w=2 is required for WPA-3 SAE
#ieee80211w=1
# if parameter is not set, 19 is the default value.
#sae_groups=19 20 21 25 26
# sae_require_mfp=1 is required for WPA-3 SAE Transitional
#sae_require_mfp=1
# if parameter is not 9 set, 5 is the default value.
#sae_anti_clogging_threshold=10

# IEEE 802.11n
ieee80211n=1
wmm_enabled=1
#
# Note: Capabilities can vary even between adapters with the same chipset.
#
# Note: Only one ht_capab= line and one vht_capab= should be active. The
# contends of these lines is determined by the capabilities of your adapter.
#
# rtl8812au - rtl8811au -  rtl8812bu - rtl8811cu - rtl8814au
# band 1 - 2g - 20 MHz channel width
#ht_capab=[SHORT-GI-20][MAX-AMSDU-7935]
# band 2 - 5g - 40 MHz channel width
ht_capab=[HT40+][HT40-][SHORT-GI-20][SHORT-GI-40][MAX-AMSDU-7935]
#
# mt7612u
# to support 20 MHz channel width on 11n
#ht_capab=[LDPC][SHORT-GI-20][TX-STBC][RX-STBC1]
# to support 40 MHz channel width on 11n
#ht_capab=[LDPC][HT40+][HT40-][GF][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]
#

# IEEE 802.11ac
ieee80211ac=1
#
# rtl8812au - rtl8811au -  rtl8812bu - rtl8811cu - rtl8814au
# band 2 - 5g - 80 MHz channel width
vht_capab=[MAX-MPDU-11454][SHORT-GI-80][HTC-VHT]
# Note: [TX-STBC-2BY1] causes problems
#
# mt7612u
# band 2 - 5g - 80 MHz channel width on 11ac
#vht_capab=[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][RX-STBC-1][MAX-A-MPDU-LEN-EXP3][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
#

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

Note: Make sure to change <your_home> to your home directory.
```
$ sudo nano /etc/default/hostapd
```
Add to bottom of file
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
DAEMON_OPTS="-d -K -f /home/<your_home>/hostapd.log"
```
-----

Disable and mask Network Manager service.

Note: This guide uses systemd-networkd for network management.
```
$ sudo systemctl disable NetworkManager

$ sudo systemctl mask NetworkManager
```
-----

Enable and start systemd-networkd service. Website - [systemd-network](https://www.freedesktop.org/software/systemd/man/systemd.network.html)
```
$ sudo systemctl enable systemd-networkd

$ sudo systemctl start systemd-networkd
```
-----

Enable and start systemd-resolved service.

Note: This service implements a caching DNS server.
```
$ sudo systemctl enable systemd-resolved

$ sudo systemctl start systemd-resolved
```
Note: Once started, systemd-resolved will create its own resolv.conf
somewhere under /run/systemd directory. However, it is a common
practise to store DNS resolver information in /etc/resolv.conf, and
many applications still rely on /etc/resolv.conf. Thus for compatibility
reasons, create a symlink to /etc/resolv.conf as follows.
```
$ sudo rm /etc/resolv.conf

$ sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
```
-----

Create bridge interface (br0).
```
$ sudo nano /etc/systemd/network/10-bridge-br0-create.netdev
```
File contents
```
[NetDev]
Name=br0
Kind=bridge
```
-----

Bind ethernet interface.
```
$ sudo nano /etc/systemd/network/20-bridge-br0-bind-ethernet.network
```
File contents
```
[Match]
Name=<eth0>

[Network]
Bridge=br0
```
-----

Configure bridge interface.
```
$ sudo nano /etc/systemd/network/21-bridge-br0-config.network
```
Note: The contents of the Network block below should reflect the needs of your network.

File contents
```
[Match]
Name=br0

[Network]
Address=192.168.1.100/24
Gateway=192.168.1.1
DNS=8.8.8.8
```
-----

Ensure WiFi radio not blocked.
```
$ sudo rfkill unblock wlan
```
-----

Reboot system.
```
$ sudo reboot
```
-----
End of installation.



Notes:

-----

Restart systemd-networkd service.
```
$ sudo systemctl restart systemd-networkd
```
-----

Check status of the services.
```
$ systemctl status hostapd

$ systemctl status systemd-networkd

$ systemctl status systemd-resolved
```
-----
