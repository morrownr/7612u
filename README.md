-----

##### [Click for USB WiFi Adapter Information and Links for Linux](https://github.com/morrownr/USB-WiFi)

-----

### 7612u :rocket:

### Linux Support for USB WiFi Adapters that are based on the MT7612U chipset.

USB WiFi adapters based on the mt7612u chipset have been supported
in-kernel since Linux kernel v4.19 (2018), therefore, there is no need
to install a driver if using a modern release of Ubuntu, Raspberry Pi
OS, Linux Mint, Kali, Fedora or Manjaro. (and others)

The MT76 series of drivers support managed mode, master mode and monitor
modes in accordance with current Linux Wireless standards. Numerous
additional capabilities, including WPA3, are supported as well. 

-----

### Driver information

For Linux users that like to work on driver code, here is the location
of the MT76 driver in the Linux kernel repo:

[MT76](https://github.com/torvalds/linux/tree/master/drivers/net/wireless/mediatek/mt76)

If you want to report a bug or submit a fix:

[Reporting bugs and submitting fixes](https://wireless.wiki.kernel.org/en/users/documentation/reporting_bugs)

If you want to see the Linux Wireless Mediatek team site:

[Linux Wireless Mediatek](https://wireless.wiki.kernel.org/en/users/drivers/mediatek)

-----

### Setting up an access point

The below document provides instructions for setting up an Access Point
using a Raspberry Pi 4B with the Raspberry Pi OS, `hostapd` and a USB
WiFi adapter based on the mt7612u chipset.

[Bridged_Wireless_Access_Point.md](https://github.com/morrownr/7612u/blob/main/Bridged_Wireless_Access_Point.md)

The adapter used in the above documents is an [Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi).

The Alfa AWUS036ACM works very well with the Raspberry Pi hardware. I
have tested the Alfa AWUS036ACM with many different computer systems and
Linux distros. In my opinion, it is an outstanding USB WiFi adapter.

[ALFA Network Linux support for MT7612U based products](https://docs.alfa.com.tw/Support/Linux/MT7612U/)

-----

### OpenWRT

Driver package: kmod-mt76x2u

Note: If your router has a USB port and supports OpenWRT, you can use
adapters based on the mt7612u to add another 2.4 GHz or 5 GHz network.
It works well.

-----

### Known Issues

Known Issue 1. If your mt7612u based adapter is built with an LED, the
LED does not come on automatically when the system is turned on. In
looking at the source code, it appears this behavior is intentional and
I understand that because one of the first things I do is disable the
LED, if possible, when I install a new adapter. There is a way to turn
the LED on if you so desire.

To turn on the LED, please follow instructions below: (does not work
with Secure Mode)

Step 1: Open Terminal (Ctrl + Alt + t)

Step 2: Change to root user

```
$ sudo -i
```

Step 3: Run both of the following commands

```
PHY_PATH=$(ls /sys/kernel/debug/ieee80211/phy*/mt76 -d)
echo 0x770 > ${PHY_PATH}/regidx
```
Step 4: Run one of the following commands

```
# echo 0x800000 > ${PHY_PATH}/regval # Turn LED ON
# echo 0x820000 > ${PHY_PATH}/regval # Turn LED OFF
# echo 0x840000 > ${PHY_PATH}/regval # Make LED BLINK
```

Step 5: Run:

```
exit
```

The above can be automated. The following is one way to do it with
Raspberry Pi OS and Ubuntu:

This method uses `/etc/rc.local`

Open Terminal (Ctrl + Alt + t)

This method is valid for many distros, even systemd-based distros. In
order for this method to work, you must grant execute permissions to
/etc/rc.local as follows:

```
sudo chmod +x /etc/rc.local
```

Edit /etc/rc.local :

```
sudo nano /etc/rc.local
```

add before `exit 0`:

```
# Make LED BLINK
cd /sys/kernel/debug/ieee80211/phy0/mt76
echo 0x770 > regidx
echo 0x840000 > regval
```

Save the file: Ctrl + Alt + o, Enter, Ctrl + Alt + x

```
sudo reboot
```

-----

Known Issue 2. When running in 5 GHz AP mode, some users have reported
the need to use the following parameter to disable Scatter-Gather.

Edit: 2022-03-16 It appears this issue is specific to computers that use
the VL805 for USB3 support. The RasPi4B is likely the most popular
system that uses the VL805. A [patch](https://github.com/raspberrypi/linux/commit/a538fd26f82b101cb6fb963042f3242768e628d4)
was recently merged that hopefully takes care of this issue.

The mt7612u driver currently supports one module parameter -
disable_usb_sg

This parameter is used to turn USB Scatter-Gather support on or off.

Information about the Scatter-Gather module parameter:

Background: Scatter and Gather (Vectored I/O) is a concept that was
primarily used in hard disks and it enhances large I/O request
performance.

Problem reports seem to be limited to situations where the user is
running an AP with a USB3 capable adapter in a USB3 port while operating
on the 5Ghz band. Symtoms include dramatically reduced throughput or
crashing if using two adapters. If you experience either of these
problems, try disable_usb_sg=1.

Method 1:

Note: This is the quick way to set the paramter:

Open a terminal (Ctrl+Alt+t)

```
sudo -i
echo "options mt76_usb disable_usb_sg=1" >> /etc/modprobe.d/mt76_usb.conf
exit
sudo reboot
```

Method 2:

Open a terminal (Ctrl + Alt + t)

```
sudo nano /etc/modprobe.d/mt76_usb.conf
```

add:

```
options mt76_usb disable_usb_sg=1
```

Save the file: Ctrl + Alt + o, Enter, Ctrl + Alt + x

-----

Known Issue 3. Running Kali Linux in VirtualBox with mt7612u based adapters such as the Alfa ACM yield an adapter that cannot be found.

One solution:

https://forums.kali.org/showthread.php?128646-SOLVED-Alfa-AWUS036ACM-amp-Kali-2022-4-on-VB

-----

Known Issue 4. DFS channels are currently not supported in 5 GHz AP
mode. The following PR shows a proposed fix.

https://github.com/openwrt/mt76/pull/428

-----

Wishlist for the MT7612u driver:

1. AP mode DFS support
2. LED on by default (keep the ability to turn it off)

-----
```
Alfa AWUS036ACM Technical Information

$ iw list
Wiphy phy0
	max # scan SSIDs: 4
	max scan IEs length: 2243 bytes
	max # sched scan SSIDs: 0
	max # match sets: 0
	Retry short limit: 7
	Retry long limit: 4
	Coverage class: 0 (up to 0m)
	Device supports RSN-IBSS
	Device supports AP-side u-APSD.
	Device supports T-DLS.
	Supported Ciphers:
		* WEP40 (00-0f-ac:1)
		* WEP104 (00-0f-ac:5)
		* TKIP (00-0f-ac:2)
		* CCMP-128 (00-0f-ac:4)
		* CCMP-256 (00-0f-ac:10)
		* GCMP-128 (00-0f-ac:8)
		* GCMP-256 (00-0f-ac:9)
		* CMAC (00-0f-ac:6)
		* CMAC-256 (00-0f-ac:13)
		* GMAC-128 (00-0f-ac:11)
		* GMAC-256 (00-0f-ac:12)
	Available Antennas: TX 0x3 RX 0x3
   	Configured Antennas: TX 0x3 RX 0x3
	Supported interface modes:
		 * IBSS
		 * managed
		 * AP
		 * AP/VLAN
		 * monitor
		 * mesh point
     		 * P2P-client
		 * P2P-GO
	Band 1:
		Capabilities: 0x1ff
			RX LDPC
			HT20/HT40
			SM Power Save disabled
			RX Greenfield
			RX HT20 SGI
			RX HT40 SGI
			TX STBC
			RX STBC 1-stream
			Max AMSDU length: 3839 bytes
			No DSSS/CCK HT40
		Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
		Minimum RX AMPDU time spacing: No restriction (0x00)
		HT TX/RX MCS rate indexes supported: 0-15
		Bitrates (non-HT):
			* 1.0 Mbps (short preamble supported)
			* 2.0 Mbps (short preamble supported)
			* 5.5 Mbps (short preamble supported)
			* 11.0 Mbps (short preamble supported)
			* 6.0 Mbps
			* 9.0 Mbps
			* 12.0 Mbps
			* 18.0 Mbps
			* 24.0 Mbps
			* 36.0 Mbps
			* 48.0 Mbps
			* 54.0 Mbps
		Frequencies:
			* 2412 MHz [1] (23.0 dBm)
			* 2417 MHz [2] (23.0 dBm)
			* 2422 MHz [3] (23.0 dBm)
			* 2427 MHz [4] (23.0 dBm)
			* 2432 MHz [5] (23.0 dBm)
			* 2437 MHz [6] (23.0 dBm)
			* 2442 MHz [7] (23.0 dBm)
			* 2447 MHz [8] (23.0 dBm)
			* 2452 MHz [9] (23.0 dBm)
			* 2457 MHz [10] (23.0 dBm)
			* 2462 MHz [11] (23.0 dBm)
			* 2467 MHz [12] (disabled)
			* 2472 MHz [13] (disabled)
			* 2484 MHz [14] (disabled)
	Band 2:
		Capabilities: 0x1ff
			RX LDPC
			HT20/HT40
			SM Power Save disabled
			RX Greenfield
			RX HT20 SGI
			RX HT40 SGI
			TX STBC
			RX STBC 1-stream
			Max AMSDU length: 3839 bytes
			No DSSS/CCK HT40
		Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
		Minimum RX AMPDU time spacing: No restriction (0x00)
		HT TX/RX MCS rate indexes supported: 0-15
		VHT Capabilities (0x318001b0):
			Max MPDU length: 3895
			Supported Channel Width: neither 160 nor 80+80
			RX LDPC
			short GI (80 MHz)
			TX STBC
			RX antenna pattern consistency
			TX antenna pattern consistency
		VHT RX MCS set:
			1 streams: MCS 0-9
			2 streams: MCS 0-9
			3 streams: not supported
			4 streams: not supported
			5 streams: not supported
			6 streams: not supported
			7 streams: not supported
			8 streams: not supported
		VHT RX highest supported: 0 Mbps
		VHT TX MCS set:
			1 streams: MCS 0-9
			2 streams: MCS 0-9
			3 streams: not supported
			4 streams: not supported
			5 streams: not supported
			6 streams: not supported
			7 streams: not supported
			8 streams: not supported
		VHT TX highest supported: 0 Mbps
		Bitrates (non-HT):
			* 6.0 Mbps
			* 9.0 Mbps
			* 12.0 Mbps
			* 18.0 Mbps
			* 24.0 Mbps
			* 36.0 Mbps
			* 48.0 Mbps
			* 54.0 Mbps
		Frequencies:
			* 5180 MHz [36] (20.0 dBm)
			* 5200 MHz [40] (20.0 dBm)
			* 5220 MHz [44] (20.0 dBm)
			* 5240 MHz [48] (20.0 dBm)
			* 5260 MHz [52] (20.0 dBm) (radar detection)
			* 5280 MHz [56] (20.0 dBm) (radar detection)
			* 5300 MHz [60] (20.0 dBm) (radar detection)
			* 5320 MHz [64] (20.0 dBm) (radar detection)
			* 5500 MHz [100] (20.0 dBm) (radar detection)
			* 5520 MHz [104] (20.0 dBm) (radar detection)
			* 5540 MHz [108] (20.0 dBm) (radar detection)
			* 5560 MHz [112] (20.0 dBm) (radar detection)
			* 5580 MHz [116] (20.0 dBm) (radar detection)
			* 5600 MHz [120] (20.0 dBm) (radar detection)
			* 5620 MHz [124] (20.0 dBm) (radar detection)
			* 5640 MHz [128] (20.0 dBm) (radar detection)
			* 5660 MHz [132] (20.0 dBm) (radar detection)
			* 5680 MHz [136] (20.0 dBm) (radar detection)
			* 5700 MHz [140] (20.0 dBm) (radar detection)
			* 5745 MHz [149] (20.0 dBm)
			* 5765 MHz [153] (20.0 dBm)
			* 5785 MHz [157] (20.0 dBm)
			* 5805 MHz [161] (20.0 dBm)
			* 5825 MHz [165] (20.0 dBm)
	Supported commands:
		 * new_interface
		 * set_interface
		 * new_key
		 * start_ap
		 * new_station
		 * new_mpath
		 * set_mesh_config
		 * set_bss
		 * authenticate
		 * associate
		 * deauthenticate
		 * disassociate
		 * join_ibss
		 * join_mesh
       		 * remain_on_channel
		 * set_tx_bitrate_mask
		 * frame
		 * frame_wait_cancel
		 * set_wiphy_netns
		 * set_channel
		 * set_wds_peer
   		 * tdls_mgmt
		 * tdls_oper
		 * probe_client
		 * set_noack_map
		 * register_beacons
		 * start_p2p_device
		 * set_mcast_rate
		 * connect
		 * disconnect
	         * channel_switch
		 * set_qos_map
		 * set_multicast_to_unicast
	Supported TX frame types:
		 * IBSS: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * managed: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * AP: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * AP/VLAN: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * mesh point: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * P2P-client: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * P2P-GO: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
		 * P2P-device: 0x00 0x10 0x20 0x30 0x40 0x50 0x60 0x70 0x80 0x90 0xa0 0xb0 0xc0 0xd0 0xe0 0xf0
	Supported RX frame types:
		 * IBSS: 0x40 0xb0 0xc0 0xd0
		 * managed: 0x40 0xd0
		 * AP: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
		 * AP/VLAN: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
		 * mesh point: 0xb0 0xc0 0xd0
		 * P2P-client: 0x40 0xd0
		 * P2P-GO: 0x00 0x20 0x40 0xa0 0xb0 0xc0 0xd0
		 * P2P-device: 0x40 0xd0
	software interface modes (can always be added):
		 * AP/VLAN
		 * monitor
	valid interface combinations:
		 * #{ IBSS } <= 1, #{ managed, AP, mesh point } <= 2,
		   total <= 2, #channels <= 1, STA/AP BI must match
	HT Capability overrides:
		 * MCS: ff ff ff ff ff ff ff ff ff ff
		 * maximum A-MSDU length
		 * supported channel width
		 * short GI for 40 MHz
		 * max A-MPDU length exponent
		 * min MPDU start spacing
	Device supports TX status socket option.
	Device supports HT-IBSS.
	Device supports SAE with AUTHENTICATE command
	Device supports low priority scan.
	Device supports scan flush.
	Device supports AP scan.
	Device supports per-vif TX power setting
	Driver supports full state transitions for AP/GO clients
	Driver supports a userspace MPM
	Device supports active monitor (which will ACK incoming frames)
	Device supports configuring vdev MAC-addr on create.
	Supported extended features:
* [ VHT_IBSS ]: VHT-IBSS
* [ RRM ]: RRM
* [ FILS_STA ]: STA FILS (Fast Initial Link Setup)
* [ CQM_RSSI_LIST ]: multiple CQM_RSSI_THOLD records
* [ CONTROL_PORT_OVER_NL80211 ]: control port over nl80211
* [ TXQS ]: FQ-CoDel-enabled intermediate TXQs
* [ AIRTIME_FAIRNESS ]: airtime fairness scheduling
* [ AQL ]: Airtime Queue Limits (AQL)
* [ SCAN_RANDOM_SN ]: use random sequence numbers in scans
* [ SCAN_MIN_PREQ_CONTENT ]: use probe request with only rate IEs in scans
* [ CONTROL_PORT_NO_PREAUTH ]: disable pre-auth over nl80211 control port support
* [ DEL_IBSS_STA ]: deletion of IBSS station support
* [ SCAN_FREQ_KHZ ]: scan on kHz frequency support
* [ CONTROL_PORT_OVER_NL80211_TX_STATUS ]: tx status for nl80211 control port support
```

-----
