## Bridged Wireless Access Point

A bridged wireless access point setup works within an existing
ethernet network to extend the network to WiFi capable computers
and devices in areas where the WiFi signal is weak or otherwise
does not meet expectations.

This document is for WiFi adapters based on the following chipset
```
mt7612u
```
2021-02-12

##### Tested Setup

- Raspberry Pi 4B (4gb)

- Raspberry Pi OS (2021-01-11) (32 bit) (kernel 5.10.11-v7l+)

- Raspberry Pi Onboard WiFi disabled

- USB WiFi Adapter based on the mt7612u chipset

- WiFi Adapter Driver - the driver is in the kernel (PnP)

- Ethernet connection providing internet
	- Ethernet cables are CAT 6
	- Internet is Fiber-optic at 1 Gbps up and 1 Gbps down

##### Steps

1. Disable Raspberry Pi onboard WiFi.

Note: Disregard this step if not installing to Raspberry Pi hardware.
```
$ sudo nano /boot/config.txt
```
Add
```
dtoverlay=disable-wifi
```
-----

2. Update system.
```
$ sudo apt update

$ sudo apt full-upgrade

$ sudo reboot
```
-----

3. Install needed package.
```
$ sudo apt install hostapd
```
-----

4. Enable the wireless access point service and set it to start
   when your Raspberry Pi boots.
```
$ sudo systemctl unmask hostapd

$ sudo systemctl enable hostapd
```
-----

5. Add a bridge network device named br0 by creating a file using
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

6. Determine the names of the network interfaces.
```
$ ip link show
```
Note: If the interface names are not eth0 and wlan0, then the
interface names used in your system will have to replace eth0
and wlan0 during the remainder of this document.

-----

7. Bridge the Ethernet network with the wireless network, first
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

8. Enable the systemd-networkd service to create and populate
    the bridge when your Raspberry Pi boots.
```
$ sudo systemctl enable systemd-networkd
```
-----

9. Block the eth0 and wlan0 interfaces from being
    processed, and let dhcpcd configure only br0 via DHCP.
```
$ sudo nano /etc/dhcpcd.conf
```
Add the following line above the first interface xxx line, if any
```
denyinterfaces wlan0 eth0
```
Go to the end of the file and add the following line
```
interface br0
```
-----

10. To ensure WiFi radio is not blocked on your Raspberry Pi,
    execute the following command.
```
$ sudo rfkill unblock wlan
```
-----

11. Create the hostapd configuration file.
```
$ sudo nano /etc/hostapd/hostapd.conf
```
File contents
```
# hostapd.conf
# https://w1.fi/hostapd/
# Supports: 2g, 5g, 80211n, 80211ac, WPA2-AES, WPA3-SAE

# change the interface name to match your system, if necessary
interface=wlan0
#
bridge=br0
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0


# IEEE 802.11
#
# change as desired
ssid=pi
#
# 2g (b/g/n)
#hw_mode=g
#channel=6
#
# 5g (a/n/ac)
hw_mode=a
channel=36
#channel=149
#
max_num_sta=128
auth_algs=1


# DFS
#
# change as required by law
country_code=US
#
# activate to enable DFS channels
#ieee80211d=1
#ieee80211h=1


macaddr_acl=0
ignore_broadcast_ssid=0


# IEEE 802.11i
wpa=2
#
# WPA-2 AES only
wpa_key_mgmt=WPA-PSK
#
# WPA-2 AES and WPA-3 SAE
#wpa_key_mgmt=WPA-PSK SAE
#
# change as desired
wpa_passphrase=raspberry
#
rsn_pairwise=CCMP
#
# required for WPA-3 SAE
#ieee80211w=2


# IEEE 802.11n
ieee80211n=1
#
# mt7612u
ht_capab=[LDPC][HT40+][GF][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1]


# IEEE 802.11ac
#ieee80211ac=1
#
# mt7612u
#vht_capab=[RXLDPC][TX-STBC-2BY1][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]
#
# The below line, vht_oper_chwidth=1, is required for 80 MHz width channel operation.
#vht_oper_chwidth=1
#
# if channel 36 is used, this line must be active if vht_oper_chwidth=1 is active
#vht_oper_centr_freq_seg0_idx=42
#
# if channel 149 is used, this line must be active if vht_oper_chwidth=1 is active
# vht_oper_centr_freq_seg0_idx=155


# hostapd event logger
logger_syslog=-1
logger_syslog_level=2
logger_stdout=-1
logger_stdout_level=2


# WMM
wmm_enabled=1
uapsd_advertisement_enabled=1
wmm_ac_bk_cwmin=4
wmm_ac_bk_cwmax=10
wmm_ac_bk_aifs=7
wmm_ac_bk_txop_limit=0
wmm_ac_bk_acm=0
wmm_ac_be_aifs=3
wmm_ac_be_cwmin=4
wmm_ac_be_cwmax=10
wmm_ac_be_txop_limit=0
wmm_ac_be_acm=0
wmm_ac_vi_aifs=2
wmm_ac_vi_cwmin=3
wmm_ac_vi_cwmax=4
wmm_ac_vi_txop_limit=94
wmm_ac_vi_acm=0
wmm_ac_vo_aifs=2
wmm_ac_vo_cwmin=2
wmm_ac_vo_cwmax=3
wmm_ac_vo_txop_limit=47
wmm_ac_vo_acm=0


# TX queue parameters
tx_queue_data3_aifs=7
tx_queue_data3_cwmin=15
tx_queue_data3_cwmax=1023
tx_queue_data3_burst=0
tx_queue_data2_aifs=3
tx_queue_data2_cwmin=15
tx_queue_data2_cwmax=63
tx_queue_data2_burst=0
tx_queue_data1_aifs=1
tx_queue_data1_cwmin=7
tx_queue_data1_cwmax=15
tx_queue_data1_burst=3.0
tx_queue_data0_aifs=1
tx_queue_data0_cwmin=3
tx_queue_data0_cwmax=7
tx_queue_data0_burst=1.5

#
# end of hostapd.conf
```
-----

12. Establish conf file and log file locations.
```
$ sudo nano /etc/default/hostapd
```
Add to bottom of file
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
DAEMON_OPTS="-d -K -f /home/pi/hostapd.log"
```
-----

13. Reboot the system.

$ sudo reboot

-----

14. Enjoy!

-----
