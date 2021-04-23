## Monitor Mode

2021-04-11

Tested with Kali Linux (amd64) and an Alfa AWUS036ACM (mt7612u) adapter.

2021-04-23

Tested with Raspberry Pi OS (arm32) and an Alfa AWUS036ACHM (mt7610u) adapter.

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
Disable interfering processes
```
$ sudo airmon-ng start kill
```
Note: Alternate method to disable interfering processes

Ensure Network Manager doesn't cause problems

Note: The Raspberry Pi OS does not use Network Manager
```
$ sudo nano /etc/NetworkManager/NetworkManager.conf
```
add
```
[keyfile]
unmanaged-devices=interface-name:mon0;interface-name:mon1
```

-----
Enable monitor mode using iw and ip:
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

$ sudo aireplay-ng --deauth 0 -c <deviceMAC> -a <routerMAC> mon0 -D
```

-----
