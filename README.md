##### [Click for USB WiFi Adapter Information for Linux](https://github.com/morrownr/USB-WiFi)

-----

### 7612u :rocket:

Linux Support for USB WiFi Adapters that are based on the MT7612U Chipset

USB WiFi adapters based on the mt7612u chipset have been supported in-kernel since
Linux kernel v4.19, therefore, there is no need to post a driver. This repo will
be used to provide information on useage.

The documents *Bridged_Wireless_Access_Point-1.md* and *Bridged_Wireless_Access_Point-2.md*
provide instructions for setting up an Access Point using a Raspberry Pi 4b with `hostapd`
and a USB WiFi adapter based on the mt7612u chipset.

The adapter used in the above documents is an [Alfa AWUS036ACM](https://github.com/morrownr/USB-WiFi).
This adapter works very well with the RasPi 4b.

The mt7610u driver does support one module parameter - disable_usb_sg

This parameter is used turn USB Scatter-Gather support on or off. Pay attention
to the settings in that turning this parameter on disables Scatter-Gather support.

To make it easy to install support for this parameter, I have added some files
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
Step 7: Move to the newly created directory
```bash
$ cd ~/src/7612u
```
Step 9: Run the installation script
```bash
$ sudo ./install-options.sh
```
