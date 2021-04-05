##### [Click for USB WiFi Adapter Information for Linux](https://github.com/morrownr/USB-WiFi)

-----

### 7612u :rocket:

Linux Support for USB WiFi Adapters that are based on the MT7612U/MT7610U Chipsets

USB WiFi adapters based on the mt7612u/mt7610u chipset have been supported in-kernel since
Linux kernel v4.19, therefore, there is no need to post a driver. This repo will
be used to provide information.

The below documents provide instructions for setting up an Access Point using a Raspberry Pi 4b
with `hostapd` and a USB WiFi adapter based on the mt7612u chipset.
```
*Bridged_Wireless_Access_Point-1.md* - 5g only
*Bridged_Wireless_Access_Point-2.md* - 5g and 2g dual band (like a real wifi router)
```
The adapter used in the above documents is an [Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi).
This adapter works very well with the Raspberry Pi hardware.

The mt7612u driver does support one module parameter - disable_usb_sg

This parameter is used turn USB Scatter-Gather support on or off. Pay attention
to the settings in that turning this parameter on disables Scatter-Gather support.

To make it easy to install and manage support for this parameter, I have added some scripts
that you can download and use. To install...
you can install.


### Installation Steps

Step 1: Open a terminal (Ctrl+Alt+T)

Step 2: Install git (select the option for the OS you are using)
```
    Option for Debian compatible Operating Systems

    $ sudo apt install -y git
```
```
    Option for Arch or Manjaro

    $ sudo pacman -S --noconfirm git
```
Step 3: Create a directory to hold the downloaded files

```bash
$ mkdir ~/src
```
Step 4: Move to the newly created directory
```bash
$ cd ~/src
```
Step 5: Download the repo
```bash
$ git clone https://github.com/morrownr/7612u.git
```
Step 6: Move to the newly created directory
```bash
$ cd ~/src/7612u
```
Step 7: Run the installation script
```bash
$ sudo ./install-options.sh
```

Question: What can I do with a mt7612u based adapter that I can't do
with my rtl8812au based adapter?

Answer: A lot...

Run multiple interface combinations on a single adapter at the same time

$ sudo iw dev

phy#0
	Interface mon0
		ifindex 20
		wdev 0x1000000002
		addr 00:13:ef:5f:0c:7c
		type monitor
		txpower 19.00 dBm
	Interface wlan0
		ifindex 19
		wdev 0x1000000001
		addr 00:13:ef:5f:0c:7c
		ssid Bass
		type managed
		channel 149 (5745 MHz), width: 80 MHz, center1: 5775 MHz
		txpower 19.00 dBm
		multicast TXQ:
			qsz-byt	qsz-pkt	flows	drops	marks	overlmt
			0	0	0	0	0	0
