##### [Click for USB WiFi Adapter Information and Links for Linux](https://github.com/morrownr/USB-WiFi)

-----

### 7612u :rocket:

Linux Support for USB WiFi Adapters that are based on the MT7612U and MT7612UN chipsets.

USB WiFi adapters based on the mt7612u mt7612un chipsets have been supported in-kernel
since Linux kernel v4.19, therefore, there is no need to install a driver if using a
popular, modern Linux distribution such as Ubuntu, Raspberry Pi OS, Linux Mint, Kali,
Fedora or Manjaro. This repo will be used to provide information and utilities.

-----
For Linux users that like to work on driver code, here is the location of the MT76
driver in the Linux kernel repo:

[MT76](https://github.com/torvalds/linux/tree/master/drivers/net/wireless/mediatek/mt76)

If you want to report a bug or submit a fix:

[Reporting bugs and submitting fixes](https://wireless.wiki.kernel.org/en/users/documentation/reporting_bugs)

If you want to see the Linux Wireless Mediatek team site:

[Linux Wireless Mediatek](https://wireless.wiki.kernel.org/en/users/drivers/mediatek)

-----
The below document provides instructions for setting up an Access Point using a Raspberry Pi 4b
with the Raspberry Pi OS, `hostapd` and a USB WiFi adapter based on the mt7612u chipset.

[Bridged_Wireless_Access_Point.md](https://github.com/morrownr/7612u/blob/main/Bridged_Wireless_Access_Point.md)

The adapter used in the above documents is an [Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi).

The Alfa AWUS036ACM works very well with the Raspberry Pi hardware.

-----
The mt7612u driver currently supports one module parameter - disable_usb_sg

This parameter is used to turn USB Scatter-Gather support on or off. Documentation
is in the file mt76_usb.conf.

Information about the Scatter-Gather module parameter:

Background: Scatter and Gather (Vectored I/O) is a concept that was primarily used in hard disks
and it enhances large I/O request performance.

Problem reports, that would cause a need to use this parameter, seem to be limited to
situations where the user is running an AP with a USB3 capable adapter in a USB3 port
while operating on the 5Ghz band. Symtoms include dramatically reduced throughput. If you
experience dramatically reduced throughput, try disable_usb_sg=1.

The Installation Steps below can help you make this change.

-----
To make it easy to install and manage support for the disable_usb_sg parameter, I
have added some scripts that you can download and use.

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
