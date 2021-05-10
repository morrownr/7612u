Warning: Do not use this document until this warning is gone. Testing in progress.

## Bridged Wireless Access Point - Ubuntu 21.04

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend
the network to WiFi capable computers and devices in areas where the
WiFi signal is weak or otherwise does not meet expectations.

This guide disables Network Manager and makes use of systemd-networkd
so as to provide consistency amoung the various Linux platforms that
are supported.

#### Single Band

This document outlines a single band setup with a USB3 WiFi adapter for 5g.

#### Information

WPA3-SAE will not work if a Realtek 88xx chipset based USB WiFi adapter is used.

WPA3-SAE will work if a Mediatek 761x chipset based USB WiFI adapter is used.

-----

2021-05-10

#### Tested Setup

	Desktop system based on an AMD64 processor

	Ubuntu 21.04

	AC1200/AC1300 USB WiFi Adapter

	Ethernet connection providing internet service


#### Setup Steps

-----

Install and configure USB WiFi adapter and driver prior to continuing.

-----

Update and reboot system.

```
$ sudo apt update

$ sudo apt full-upgrade

$ sudo reboot
```
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
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_pairwise=CCMP
rsn_pairwise=CCMP
# Change as desired
wpa_passphrase=mypw2021
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
DAEMON_OPTS="-d -K -f /home/<your_home>/hostapd.log"
```
-----

Determine the names of the network interfaces.
```
$ ip link show
$ ip a
```
Note: If the interface names are not `eth0` and `wlan0`,
then the interface names used in your system will have to replace
`eth0` and `wlan0` for the remainder of this document.

Note: You may assign a MAC address to your bridge, the same as your
physical device ?, adding the line MACAddress=xx:xx:xx:xx:xx:xx
in the NetDev section below.

-----

Disable Network Manager service.

Note: This guide uses systemd-networkd for consistency with other guides.
```
$ sudo systemctl disable NetworkManager
```
-----

Enable the systemd-networkd service.
```
$ sudo systemctl enable systemd-networkd
```
-----

Enable systemd-resolved service.

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

Configure Network Connections with `systemd-networkd`

To configure network devices with systemd-networkd, you must specify
configuration information in text files with .network extension. These
network configuration files are then stored and loaded from
/etc/systemd/network. When there are multiple files, systemd-networkd
loads and processes them one by one in lexical order.

-----

Create folder `/etc/systemd/network`, if it does not exist.
```
$ sudo mkdir /etc/systemd/network
```
-----

Configure DHCP networking. For this, create the following configuration
file. The name of a file can be arbitrary, but remember that files are
processed in lexical order.
```
$ sudo nano /etc/systemd/network/20-dhcp.network
```
File contents
```
[Match]
Name=eth0

[Network]
DHCP=yes
```
-----

Assign a static IP address to the eth0 network interface [optional].
```
$ sudo nano /etc/systemd/network/10-static-ether.network
```
File contents
```
[Match]
Name=eth0

[Network]
Address=192.168.01.50/24
Gateway=192.168.01.1
DNS=8.8.8.8
```
Note: the interface eth0 will be assigned an address 192.168.10.50/24,
a default gateway 192.168.10.1, and a DNS server 8.8.8.8. One subtlety
here is that the name of an interface eth0 matches the pattern rule
defined in the earlier DHCP configuration as well. However, since the
file 10-static-enp3s0.network is processed before 20-dhcp.network
according to lexical order, the static configuration takes priority
over DHCP configuration in case of eth0 interface.

-----

Restart systemd-networkd service or reboot.
```
$ sudo systemctl restart systemd-networkd
```
-----
Check the status of the service.
```
$ systemctl status systemd-networkd

$ systemctl status systemd-resolved
```
-----

Configure Virtual Network Devices with `systemd-networkd`

systemd-networkd also allows you to configure virtual network devices
such as bridges, VLANs, tunnel, VXLAN, bonding, etc. You must configure
these virtual devices in files with .netdev extension.

-----

Create a bridge interface (br0) and add a physical interface (eth0) to
the bridge.
```
$ sudo nano /etc/systemd/network/bridge-br0.netdev
```
File contents
```
[NetDev]
Name=br0
Kind=bridge
```

Optionally, you may add the below to the above if you need to set the
MAC address of the bridge.
```
MACAddress=xx:xx:xx:xx:xx:xx
```
-----

Configure the bridge interface.
```
$ sudo nano /etc/systemd/network/bridge-br0-ethernet.network
```
File contents
```
[Match]
Name=eth0

[Network]
Bridge=br0
```
```
$ sudo nano /etc/systemd/network/bridge-br0.network
```
File contents
```
[Match]
Name=br0

[Network]
Address=192.168.01.100/24
Gateway=192.168.01.1
DNS=8.8.8.8
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




Notes:


-----


-----
