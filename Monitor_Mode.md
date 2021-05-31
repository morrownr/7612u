## Monitor Mode Operation and Testing

2021-05-15

Tested with Kali Linux (amd64) and an Alfa AWUS036ACM (mt7612u) adapter.

2021-04-23

Tested with Raspberry Pi OS (arm32) and an Alfa AWUS036ACHM (mt7610u) adapter.

2021-05-28

Tested with Linux Mint 20.1 and a USB WiFi adapter based on the rtl8814au chipset.

-----

Update system
```
$ sudo apt update
$ sudo apt full-upgrade
$ sudo reboot
```

-----

Ensure WiFi radio is not blocked
```
$ sudo rfkill unblock wlan
```

-----

Install the aircrack-ng package
```
$ sudo apt install aircrack-ng
```

-----

Determine the name(s) and status of wifi interfaces
```
$ iw dev
```
Note: The output shows the WiFi interface name and the current
mode among other things. The interface name may be something like
`wlx00c0cafre8ba` and is required for many of the below commands.

-----

Disable interfering processes
```
$ sudo airmon-ng start kill
```

Note: Below is an alternate method to disable interfering processes

Ensure Network Manager doesn't cause problems

Note: The Raspberry Pi OS does not use Network Manager so disregard this alternate method for the RasPiOS.
```
$ sudo nano /etc/NetworkManager/NetworkManager.conf
```
add
```
[keyfile]
unmanaged-devices=interface-name:mon0;interface-name:mon1
```

-----

Get status of WiFi interface
```
$ sudo iw dev
```
```
phy#0
	Interface wlan0
		ifindex 4
		wdev 0x1
		addr aa:bb:cc:dd:00:cc
		type managed
		txpower 12.00 dBm
```

-----

Add monitor interface
```
$ sudo iw phy phy0 interface add mon0 type monitor
```

-----

Check that mon0 was added
```
$ sudo iw dev
```
```
phy#0
	Interface mon0
		ifindex 5
		wdev 0x2
		addr aa:bb:cc:dd:00:cc
		type monitor
		channel 1 (2412 MHz), width: 20 MHz (no HT), center1: 2412 MHz
		txpower 23.00 dBm
	Interface wlan0
		ifindex 4
		wdev 0x1
		addr aa:bb:cc:dd:00:cc
		type managed
		txpower 23.00 dBm
```

-----

Test injection
```
$ sudo airodump-ng mon0 --band ag

$ sudo iw dev mon0 set channel 149 (or whatever channel you want)

$ sudo aireplay-ng --test mon0
```

-----

Test deauth
```
$ sudo airodump-ng mon0 --band ag

$ sudo airodump-ng mon0 --bssid <routerMAC> --channel <channel of router>

2 Ghz: $ sudo aireplay-ng --deauth 0 -c <deviceMAC> -a <routerMAC> mon0

5 Ghz: $ sudo aireplay-ng --deauth 0 -c <deviceMAC> -a <routerMAC> mon0 -D
```

-----

Change txpower
```
$ sudo iw dev wlan0 set txpower fixed 1600
```
