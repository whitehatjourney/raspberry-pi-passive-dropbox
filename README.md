# Raspberry-pi-Passive-Dropbox

A hands-on network monitoring lab demonstrating passive traffic capture, PCAP analysis, and log aggregation using a Raspberry Pi for blue-team security practice.
---

## ⚠️ Disclaimer
This project is for **educational and authorized environments only**.  Only monitor networks you own or have explicit permission to observe.  
This lab focuses on **passive visibility**, not exploitation.

---

## What This Project Does

- Passively captures Ethernet traffic using tcpdump
- Saves PCAP files in **10-minute segments**  
- Retains ~**12 hours** of rolling capture history  
- Allows offline analysis with **Wireshark**  
- Provides visibility into:
  - ARP & device discovery  
  - mDNS / multicast traffic  
  - DNS activity  
  - Broadcast traffic  
  - Normal LAN behavior  

---

## Who This Is For

- Beginners learning **Blue Team** concepts  
- Students building a home security lab  
- IT / Security professionals practicing traffic analysis  
- Anyone interested in network visibility & monitoring  

---

## Hardware & Tools Used

### Hardware
- Raspberry Pi Zero 2 W + power cable  
- Mini USB-to-Ethernet adapter  
- MicroSD card  

### Software
- Raspberry Pi OS  
- tcpdump
- ARPWatch  
- SSH / SCP  
- Wireshark (for analysis)  

---

## Project Setup Overview

- Installed Raspberry Pi OS  
- Enabled SSH for remote access during setup
- Connected the Pi to the network via Ethernet  
- Configured `tcpdump` to:
  - Capture all visible traffic  
  - Rotate files every 10 minutes  
  - Retain ~12 hours of data  
- Verified PCAP generation  
- Exported a capture to a main computer  
- Analyzed traffic using Wireshark  

Traffic Capture Details

Each capture file:

- Covers **10 minutes** of traffic  
- Is stored in:
---

## Installation

Update the system:

```bash
sudo apt update && sudo apt upgrade -y
```
Install required tools:
```bash
sudo apt install -y tcpdump tshark arpwatch openssh-server
```
Enable SSH:
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```
Create the project directory:
```bash
sudo mkdir -p /opt/dropbox
sudo chown $USER:$USER /opt/dropbox
```
Install git:
```bash
sudo apt update
sudo apt install git -y
```
## Automation (systemd)

(Optional) Install and enable systemd services so capture starts on boot and reports run automatically.

Copy service/timer files:

```bash
sudo cp systemd/*.service /etc/systemd/system/
sudo cp systemd/*.timer /etc/systemd/system/
```
Reload system:
```bash
sudo systemctl daemon-reload
```
Enable capture on boot:
```bash
sudo systemctl enable --now dropbox-capture.service
```
Enable scheduled reporting:
```bash
sudo systemctl enable --now dropbox-report.timer
```
Verify timers:
```bash
systemctl list-timers --all | grep dropbox
```
Clone the repository to your Raspberry Pi:
```bash
git clone https://github.com/whitehatjourney/raspberry-pi-passive-dropbox.git
cd raspberry-pi-passive-dropbox
```
Navigate to the project directory before copying the scripts:
```bash
cd raspberry-pi-passive-dropbox
```
Verify the scipts exist:
```bash
ls scripts
```
You should see:
```bash
capture.sh
export-all.sh
mast-sumary.sh
report.sh
```
Copy the scripts into /opt/dropbox and make them exectutable:
```bash
sudo cp scripts/*.sh /opt/dropbox/
sudo chmod +x /opt/dropbox/*.sh
```
---

