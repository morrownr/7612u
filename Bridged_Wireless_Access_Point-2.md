## Bridged Wireless Access Point

A bridged wireless access point works within an existing ethernet
network to add WiFi capability where it does not exist or to extend
the network to WiFi capable computers and devices in areas where the
WiFi signal is weak or otherwise does not meet expectations.

#### Dual Band

This document outlines a dual band setup using the Raspberry Pi 4B
onboard WiFi for 2g and a USB 3 WiFi adapter for 5g.

#### Information

This setup supports WPA3-SAE personal but it is turned off by dafault.

-----

2021-04-11

#### Tested Setup

```
	Raspberry Pi 4B (4gb)

	Raspberry Pi OS (2021-03-04) (32 bit) (kernel 5.10.17-v7l+)
	
	Ethernet connection providing internet

	AC1200 USB WiFi Adapter with mt7612u chipset such as the Alfa AWUS036ACM
```

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

USB adapter driver installation is not required as the driver is in-kernel.

-----

Update system.

```
$ sudo apt update

$ sudo apt full-upgrade
```
-----

Reduce overall power consumption and overclock the CPU a modest amount.

Note: all items in this step are optional and some items are specific to
the Raspberry Pi 4B. If installing to a Raspberry Pi 3b or 3b+ you will
need to use the appropriate settings for that hardward.
```
$ sudo nano /boot/config.txt
```
Change
```
# turn off onboard audio
dtparam=audio=off

# disable DRM VC4 V3D driver on top of the dispmanx display stack
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
Note: If the interface names are not `eth0`, `wlan0` and `wlan1`,
then the interface names used in your system will have to replace
`eth0`, `wlan0` and `wlan1` for the remainder of this document.

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
Add the following line above the first `interface xxx` line, if any
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
# 2021-04-07

# Defaults:
# SSID: pi4-5g
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
ssid=pi4-5g

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
ignore_broadcast_ssid=0
rts_threshold=2347
fragm_threshold=2346
#send_probe_response=1

# security
# auth_algs=1 works for WPA-2
# auth_algs=3 required for WPA-3 SAE and Transitional
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
rsn_pairwise=CCMP
# Change as desired
wpa_passphrase=raspberry
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
# band 2 - 5g
vht_capab=[RXLDPC][SHORT-GI-80][TX-STBC-2BY1][RX-STBC-1][MAX-A-MPDU-LEN-EXP3][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]

# Required for 80 MHz width channel operation
# band 2 - 5g
vht_oper_chwidth=1
#
# Use the next line with channel 36
# band 2 - 5g
vht_oper_centr_freq_seg0_idx=42
#
# Use the next with channel 149
# band 2 - 5g
#vht_oper_centr_freq_seg0_idx=155

# Event logger - as desired
#logger_syslog=-1
#logger_syslog_level=2
#logger_stdout=-1
#logger_stdout_level=2

# WMM - as desired
#uapsd_advertisement_enabled=1
#wmm_ac_bk_cwmin=4
#wmm_ac_bk_cwmax=10
#wmm_ac_bk_aifs=7
#wmm_ac_bk_txop_limit=0
#wmm_ac_bk_acm=0
#wmm_ac_be_aifs=3
#wmm_ac_be_cwmin=4
#wmm_ac_be_cwmax=10
#wmm_ac_be_txop_limit=0
#wmm_ac_be_acm=0
#wmm_ac_vi_aifs=2
#wmm_ac_vi_cwmin=3
#wmm_ac_vi_cwmax=4
#wmm_ac_vi_txop_limit=94
#wmm_ac_vi_acm=0
#wmm_ac_vo_aifs=2
#wmm_ac_vo_cwmin=2
#wmm_ac_vo_cwmax=3
#wmm_ac_vo_txop_limit=47
#wmm_ac_vo_acm=0

# TX queue parameters - as desired
#tx_queue_data3_aifs=7
#tx_queue_data3_cwmin=15
#tx_queue_data3_cwmax=1023
#tx_queue_data3_burst=0
#tx_queue_data2_aifs=3
#tx_queue_data2_cwmin=15
#tx_queue_data2_cwmax=63
#tx_queue_data2_burst=0
#tx_queue_data1_aifs=1
#tx_queue_data1_cwmin=7
#tx_queue_data1_cwmax=15
#tx_queue_data1_burst=3.0
#tx_queue_data0_aifs=1
#tx_queue_data0_cwmin=3
#tx_queue_data0_cwmax=7
#tx_queue_data0_burst=1.5

# End of hostapd-5g.conf
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
# 2021-04-07

# Defaults:
# SSID: pi4-2g
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
ssid=pi4-2g

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

# End of hostapd-2g.conf
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
$ sudo cp /usr/lib/systemd/system/hostapd.service /etc/systemd/system/hostapd.service
```
```
$ sudo nano /etc/systemd/system/hostapd.service
```
Change the 'Environment=' line and 'ExecStart=' line to the following
```
Environment=DAEMON_CONF="/etc/hostapd/hostapd-5g.conf /etc/hostapd/hostapd-2g.conf"
ExecStart=/usr/sbin/hostapd -B -P /run/hostapd.pid -B $DAEMON_OPTS $DAEMON_CONF
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
