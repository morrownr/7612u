## Monitor Mode

2021-03-12

Tested with Linux Mint 20.1

-----
### Test Packet Injection


Install the aircrack-ng package
```
$ sudo apt-get install aircrack-ng
```

Ensure Network Manager doesn't cause problems
```
$ sudo nano /etc/NetworkManager/NetworkManager.conf
```
add
```
[keyfile]
unmanaged-devices=interface-name:mon0
```


Determine the phy interface name
```
$ sudo iw dev
```
Note: Replace phy0 with your interface name.
```
$ sudo iw phy phy0 interface add mon0 type monitor

$ sudo ip link set mon0 up

$ sudo ip link show dev mon0
```


Test Packet Injection

$ sudo aireplay-ng --test mon0


Search for networks

$ sudo airodump-ng mon0 --band ag

-----
### Enter Monitor Mode

Start by making sure the system recognizes the WiFi interface
```
$ iw dev
```
Note: The output shows the WiFi interface name and the current
mode among other things. The interface name may be something like
`wlx00c0cafre8ba` and is required for many of the below commands.


Take the interface down
```
$ sudo ip link set <your interface name here> down
```

Set monitor mode
```
$ sudo iw <your interface name here> set monitor control
```

Bring the interface up
```
$ sudo ip link set <your interface name here> up
```

Verify the mode has changed
```
$ iw dev
```
-----

### Revert to Managed Mode

Take the interface down
```
$ sudo ip link set <your interface name here> down
```

Set managed mode
```
$ sudo iw <your interface name here> set type managed
```

Bring the interface up
```
$ sudo ip link set <your interface name here> up
```

Verify the mode has changed
```
$ iw dev
```
-----

### Change the MAC Address before entering Monitor Mode

Take down things that might interfere
```
$ sudo airmon-ng check kill
```
Check the WiFi interface name
```
$ iw dev
```
Take the interface down
```
$ sudo ip link set dev <your interface name here> down
```
Change the MAC address
```
$ sudo ip link set dev <your interface name here> address <your new mac address>
```
Set monitor mode
```
$ sudo iw <your interface name here> set monitor control
```
Bring the interface up
```
$ sudo ip link set dev <your interface name here> up
```
Verify the MAC address and mode has changed
```
$ iw dev
```
