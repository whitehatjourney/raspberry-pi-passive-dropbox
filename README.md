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
`/var/log/dropbox/pcap/`

Reports are stored in:
- `/var/log/dropbox/reports/`
---

## Installation

On your Raspberry Pi:

```bash
git clone https://github.com/whitehatjourney/raspberry-pi-passive-dropbox.git
cd raspberry-pi-passive-dropbox
sudo bash install.sh
```
This installer will:

-Install required tools
-Enable SSH
-Create all directories
-Install the scripts
-Configure systemd services
-Start packet capture automatically
```
Script Overview

capture.sh
Runs tcpdump to passively capture Ethernet traffic in 10-minute PCAP files.
Files rotate automatically to prevent disk overuse.

report.sh
Generates a 12-hour summary report showing:
Top protocols
Top source IPs
Top destination IPs
ARP / DNS / DHCP counts

export_all.sh
Creates a single consolidated export file containing:
Capture service status
Restart history
ARPWatch logs
Latest summary report
PCAP time window
Protocol statistics

master_summary.sh (Optional)
Generates a quick dashboard-style summary in one file.
```
Verify the lab is working
```bash
systemctl status dropbox-capture.service --no-pager
ls -lh /var/log/dropbox/pcap | tail
systemctl list-timers --all | grep dropbox
```
Analyzing Captured Traffic
Copy a PCAP file to your main computer:
```bash
scp user@PI_IP:/var/log/dropbox/pcap/capture_YYYY-MM-DD_HH-MM-SS.pcap .
```
Open it in Wireshark and try filters like:

-dns
-arp
-mdns
-ip.addr == 192.168.1.1
