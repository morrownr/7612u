##### [Click for USB WiFi Adapter Information for Linux](https://github.com/morrownr/USB-WiFi)

-----

### 7612u :rocket:

Linux Support for USB WiFi Adapters that are based on the MT7612U chipset.

USB WiFi adapters based on the mt7612u chipset have been supported in-kernel
since Linux kernel v4.19, therefore, there is no need to post a driver. This repo will be
used to provide information and utilities.

-----
The below documents provide instructions for setting up an Access Point using a Raspberry Pi 4b
with the Raspberry Pi OS, `hostapd` and a USB WiFi adapter based on the mt7612u chipset.

[Bridged_Wireless_Access_Point-1.md - 5g single band](https://github.com/morrownr/7612u/blob/main/Bridged_Wireless_Access_Point-1.md)

[Bridged_Wireless_Access_Point-2.md - 5g and 2g dual band ( it works really well )](https://github.com/morrownr/7612u/blob/main/Bridged_Wireless_Access_Point-2.md)

The adapter used in the above documents is an [Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi).
This adapter works very well with the Raspberry Pi hardware.

-----
The below document provides instructions for testing monitor mode with the Raspberry Pi OS (arm32) and Kali Linux (amd64) and a USB WiFi adapter based on the mt7612u chipset.

[Monitor_Mode.md](https://github.com/morrownr/7612u/blob/main/Monitor_Mode.md)

-----
The mt7612u driver does support one module parameter - disable_usb_sg

This parameter is used to turn USB Scatter-Gather support on or off. Documentation
is the file mt76_usb.conf.

Information about the Scatter-Gather module parameter:

Background: Scatter and Gather (Vectored I/O) is a concept that was primarily used in hard disks
and it enhances large I/O request performance.

Problem reports seem to be rare and limited to situations where the user is running an AP
with a USB3 capable adapter in a USB3 port while operating on the 5Ghz band. Symtoms include
dramatically reduced throughput. Research tends to indicate that this could be a hardware
specific problem and is not caused by the driver or USB WiFi adapter. The issue causing
the reported problems may be fixed because I certainly have not seen the problem with
the AP setups I have outlined above. However, if you experience dramatically reduced
throughput, try disable_usb_sg=1. The Installation Steps below can help make this change.

-----
To make it easy to install and manage support for this parameter, I have added some scripts
that you can download and use. To install...


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

-----

The script called `edit-options.sh` makes it easy to edit the 
module paramter:

Step 1: Open a terminal (Ctrl+Alt+T)

Step 2: Move to the driver directory
```
$ cd ~/src/7612u
```

Step 3: Run the following script
```
$ sudo ./edit-options.sh
```
-----
