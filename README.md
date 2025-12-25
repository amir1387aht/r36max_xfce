# 🕹️ ArkOS OTG → WiFi & XFCE Setup (Secondary SD Card Only)

This guide explains how to convert an **ArkOS handheld** into a **lightweight XFCE desktop**
using **OTG → WiFi**, **SSH**, and **QJoyPad**.

> ⚠️ **IMPORTANT**
> - **DO NOT use the original SD card**
> - Use **only a secondary SD card**
> - Follow steps in order
> - Installing Arkos on r36max: https://youtu.be/DJipgvK5KkM?si=C3k7taw7BrdpBAeX
---

## 📦 Requirements

- Secondary SD card (ArkOS installed)
- Linux PC (for partition editing)
- USB keyboard (backup input)
- OTG cable
- `StartUSBWiFi.sh`
- `Install-XFCE.sh`
- `Launch-XFCE.sh`

---

## 🧩 Step 1: Prepare the SD Card (PC)

1. Insert the **secondary SD card** into your PC
2. Mount the SD card
3. Copy the script:

```text
StartUSBWiFi.sh → EASYROMS/tools/
````

4. Safely eject the SD card

---

## 🎮 Step 2: Enable Remote Access (Handheld)

1. Insert SD card into the handheld
2. Boot ArkOS
3. Navigate to:

```text
Options Menu -> Tools → StartUSBWiFi.sh
```

4. Run the script
5. Go to **Options Menu**
6. Press **Enable Remote Access**

---

## 🔌 Step 3: OTG Connection & PC Network Setup

1. Connect the handheld to your PC using **OTG**

# PC-Side USB OTG Network Configuration Guide

This section explains how to configure the **computer side** when using the
`OTG2WiFi.sh` USB Network Gadget script on the handheld.

The handheld will act as a **USB Ethernet device** with the following network:

* Device IP: `192.168.137.2`
* Host (PC) IP: `192.168.137.1`
* Netmask: `255.255.255.0`

---

## Overview (How It Works)

1. The handheld exposes itself as a **USB network device (RNDIS)**
2. The PC detects it as a **USB Ethernet adapter**
3. The PC shares its internet connection over USB
4. The handheld routes traffic through the PC

This works on:

* Linux
* Windows
* macOS

---

## Step 1: Physical Connection

1. Power on the handheld
2. Run `OTG2WiFi.sh` on the device
3. Connect the handheld to the PC using an **OTG cable**
4. Wait a few seconds for the USB network interface to appear

---

## Linux PC Configuration

### 1. Identify Interfaces

Find your internet interface:

```
ip route
```

Common examples:

* `eth0` (wired)
* `wlan0` (WiFi)

Find the USB interface:

```
ip link
```

Usually named:

* `usb0`
* or `enxXXXXXXXXXXXX`

---

### 2. Enable IP Forwarding

Temporarily enable forwarding:

```
sudo sysctl -w net.ipv4.ip_forward=1
```

(Optional permanent):

```
sudo nano /etc/sysctl.conf
```

Uncomment or add:

```
net.ipv4.ip_forward=1
```

---

### 3. Configure USB Interface IP

Assign the host IP to the USB interface:

```
sudo ip addr add 192.168.137.1/24 dev usb0
sudo ip link set usb0 up
```

(Replace `usb0` if your interface name is different)

---

### 4. Enable NAT (Internet Sharing)

Replace `eth0` with your real internet interface:

```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o usb0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i usb0 -o eth0 -j ACCEPT
```

At this point, internet should work on the handheld.

---

### 5. Test from Handheld

On the handheld:

```
ping 192.168.137.1
ping 8.8.8.8
ping google.com
```

---

## Windows PC Configuration

### 1. Open Network Settings

1. Press `Win + R`

2. Type:

   ``` ncpa.cpl ```

3. Press Enter

---

### 2. Enable Internet Sharing

1. Right-click your **active internet connection**
   (Wi-Fi or Ethernet)

2. Click **Properties**

3. Open the **Sharing** tab

4. Check:

   Allow other network users to connect through this computer’s Internet connection

5. Select the **USB Ethernet / RNDIS device**

6. Click **OK**

Windows will automatically assign:

* Host IP: `192.168.137.1`

---

### 3. Verify Connection

Open Command Prompt and run:

```
ipconfig
```

You should see a USB network adapter with:

* IPv4 Address: `192.168.137.1`

Test from handheld:

```
ping 8.8.8.8
ping google.com
```

---

## macOS Configuration

### 1. Enable Internet Sharing

1. Open **System Settings**
2. Go to **General → Sharing**
3. Enable **Internet Sharing**

Set:

* Share connection from:
  (Wi-Fi or Ethernet)
* To computers using:
  USB Ethernet (or similar)

---

### 2. Verify USB Interface

Open Terminal:

```
ifconfig
```

Look for:

* `enX` interface with IP `192.168.137.1`

---

### 3. Test Connectivity

From the handheld:

```
ping 192.168.137.1
ping 8.8.8.8
ping google.com
```

---

## Troubleshooting

### USB Interface Not Appearing

* Replug the USB cable
* Run the script again on the handheld
* Try a different OTG cable
* Reboot both devices

---

### Handheld Has No Internet

Check on handheld:

```
ip addr show usb0
ip route
```

Expected:

* IP: `192.168.137.2`
* Default route via `192.168.137.1`

Manually fix if needed:

```
sudo ip addr add 192.168.137.2/24 dev usb0
sudo ip link set usb0 up
sudo ip route add default via 192.168.137.1
```

---

## Notes

* Windows prefers **RNDIS**, which this script uses
* Linux and macOS also work without modification
* This setup is ideal for **headless SSH + XFCE**

---

## 🔐 Step 4: SSH Into the Device

Connect via SSH:

```bash
ssh ark@192.168.137.2
```

> 📌 Password: ``` ark ```

---

## 📁 Step 5: Copy Script to fs_root

Once connected:

```bash
cp /roms/tools/StartUSBWiFi.sh ~/wifi_ssh_service
```

This copies the script into **fs_root (home directory)**.
Also do this for ``` Launch-XFCE.sh ``` and ``` Install-XFCE.sh ``` and ``` files ``` folder from your computer to console using scp in ``` ~\Ixfce ``` folder

---

## 💾 Step 6: Resize SD Card Partitions (Linux PC)

1. Power off the handheld

2. Remove the SD card

3. Insert it into your Linux PC

4. Using **GParted** (or similar):

   * ❌ Delete **third partition** (`easyroms`)
   * 📈 Resize **second partition** (`fs_root`) to **maximum size**

5. Apply changes

## Step 6.1: Update fs_root Auto-Mount Configuration

After deleting **partition 3 (easyroms)** and resizing **partition 2 (fs_root)**, ArkOS will still try to mount the old partition unless its configuration is updated.

This must be fixed manually.

---

### Locate the Mount Configuration File

1. Insert the SD card into your Linux PC
2. Mount the **fs_root** partition (second partition)
3. Navigate to:

   /etc/fstab

This file controls which partitions are mounted automatically at boot.

---

### Edit fstab

Open the file using a text editor:

```
sudo nano /etc/fstab
```

You will see entries similar to this:

```
/dev/mmcblk0p1   /boot     vfat    defaults        0  2
/dev/mmcblk0p2   /         ext4    defaults,noatime 0  1
/dev/mmcblk0p3   /roms     ext4    defaults,noatime 0  0
```

---

### Remove the easyroms Entry

Since **partition 3 no longer exists**, remove or comment out the line that mounts it.

DELETE or COMMENT OUT:

```
/dev/mmcblk0p3   /roms     ext4    defaults,noatime 0  0
```

Corrected example:

```
/dev/mmcblk0p1   /boot     vfat    defaults        0  2
/dev/mmcblk0p2   /         ext4    defaults,noatime 0  1
```

Save and exit:

* Press `CTRL + O`, then `ENTER`
* Press `CTRL + X`

---

### Verify Mount Points (Optional)

If you want to be extra safe, check that `/roms` is not required anymore:

```
ls /
```

If `/roms` exists but is unused, it can be removed later after boot.

---

### Important Notes

* If this step is skipped, ArkOS may:

  * Pause during boot
  * Drop to emergency shell
  * Spam “cannot mount /roms” errors
* This change is **mandatory** after removing partition 3
* This does **not** affect system stability once XFCE is installed

---

7. Safely eject the SD card

---

## 🔄 Step 7: Remove Emulation Software

1. Insert SD card back into the handheld
2. Boot and reconnect via SSH
3. Remove emulation components:

---

### Remove Emulation Software Completely

This section removes emulators **and any leftover files or configs**, leaving your system clean.

---

#### 1. Purge Installed Packages

```bash
sudo apt remove --purge emulationstation ppsspp retroarch -y
sudo apt autoremove -y
```

* `-y` automatically confirms
* `--purge` removes configuration files as well

---

#### 2. Remove Remaining Config Files & Directories

```bash
# Remove user config directories
rm -rf ~/.emulationstation
rm -rf ~/.config/retroarch
rm -rf ~/.config/ppsspp
rm -rf ~/RetroArch
rm -rf ~/PPSSPP
rm -rf ~/EmulationStation

# Remove system-wide configs (if any)
sudo rm -rf /etc/emulationstation
sudo rm -rf /etc/retroarch
sudo rm -rf /etc/ppsspp
```

---

#### 3. Search for Other Related Files (Optional)

```bash
# Search home and fs_root for leftover emulator files
find ~ -iname "*emulationstation*" -exec rm -rf {} \;
find ~ -iname "*ppsspp*" -exec rm -rf {} \;
find ~ -iname "*retroarch*" -exec rm -rf {} \;

# Search system directories (careful with sudo)
sudo find /usr -iname "*emulationstation*" -exec rm -rf {} \;
sudo find /usr -iname "*ppsspp*" -exec rm -rf {} \;
sudo find /usr -iname "*retroarch*" -exec rm -rf {} \;
```

> ⚠️ **Warning:** Be careful with `sudo find ... -exec rm -rf {}` — double-check results first if unsure.

---

#### 5. Optional: Verify Cleanup

```bash
dpkg -l | grep -E "emulationstation|ppsspp|retroarch"
```

* This should return **nothing** if everything is removed
* Also check your home folder for leftover files

---

## 🆘 SSH Recovery (If Connection Is Lost)

If SSH stops working at any point:

1. Connect a **USB keyboard** to the handheld
2. Exit EmulationStation (if still installed)
3. Press:

```text
Alt + F2
```

4. Access the terminal directly

---

## 🖥️ Step 8: Install XFCE

Run:

```bash
sudo ./Install-XFCE.sh
```

⏳ Installation may take several minutes.

---

## ⚙️ Step 9: Enable Auto-Start Services

Create `systemd` services to auto-run:

* `StartUSBWiFi.sh`
* `Launch-XFCE.sh`

Follow Below

---

📌 **Contents**

### 1️⃣ `wifi_ssh.service`

This service will **start your USB WiFi and enable SSH** automatically at boot.

**Service file (`nano /etc/systemd/system/wifi_ssh.service`)**:

```ini
[Unit]
Description=Start USB WiFi and enable SSH
After=network.target

[Service]
Type=oneshot
ExecStart=/home/ark/wifi_ssh_service/StartUSBWiFi.sh
ExecStartPost=/bin/systemctl start ssh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Steps to enable and start it**:

```bash
# 1. Reload systemd to recognize the new service
sudo systemctl daemon-reload

# 2. Enable service at boot
sudo systemctl enable wifi_ssh.service

# 3. Start the service immediately (optional)
sudo systemctl start wifi_ssh.service

# 4. Check status
sudo systemctl status wifi_ssh.service
```

---

### 2️⃣ `launch-xfce.service`

This service will **launch XFCE at boot for user `ark`**.

**Service file (`nano /etc/systemd/system/launch-xfce.service`)**:

```ini
[Unit]
Description=Launch XFCE Script at Boot (User ark)
After=network.target systemd-user-sessions.service
Wants=systemd-user-sessions.service

[Service]
Type=simple
User=ark
Group=ark

# X environment
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/ark/.Xauthority
Environment=HOME=/home/ark

ExecStart=/home/ark/Ixfce/Launch-XFCE.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

**Steps to enable and start it**:

```bash
# 1. Reload systemd
sudo systemctl daemon-reload

# 2. Enable service at boot
sudo systemctl enable launch-xfce.service

# 3. Start the service immediately (optional)
sudo systemctl start launch-xfce.service

# 4. Check status
sudo systemctl status launch-xfce.service
```

> ✅ After reboot, **XFCE should start automatically** for user `ark`, and your USB WiFi & SSH will also be enabled.

---

## 🎮 Step 10: Configure Controls (QJoyPad)

1. Confirm **QJoyPad is already installed**
2. Install joystick utilities:

```bash
sudo apt install joystick
```

3. Run joystick configuration commands

> 📌 **Configuring Joysticks**
Run ``` jstest /dev/input/js0 ``` And follow the questions,
After finishing run ``` sudo jscal-store /dev/input/js0 ```
To save it permanently

4. Open **QJoyPad**
5. Map handheld buttons to:

   * Keyboard keys
   * Mouse movement
   * Mouse clicks / scroll

---

## ✅ Final Result

* OTG → WiFi enabled automatically
* SSH access available
* XFCE desktop launches on boot
* Handheld buttons work as keyboard & mouse
* Clean system without emulation software

---

## 📌 Notes

* This setup is intended for **advanced users**
* Always keep a **backup SD card**
* A USB keyboard can save you if input breaks

---

## 🧠 Credits

* ArkOS community
* R36S / RK3326 contributors
* QJoyPad & XFCE projects

---

## 🕷 Known Bugs

* XFCE Closes after a while automatilly for unknown reason, Its currently temporary fixed in ``` Launch-XFCE.sh ```, No need to do anything
