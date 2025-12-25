# 🕹️ ArkOS OTG → WiFi & XFCE Setup (Secondary SD Card Only)

This guide explains how to convert an **ArkOS handheld** into a **lightweight XFCE desktop**
using **OTG → WiFi**, **SSH**, and **QJoyPad**.

> ⚠️ **IMPORTANT**
> - **DO NOT use the original SD card**
> - Use **only a secondary SD card**
> - Follow steps in order

---

## 📦 Requirements

- Secondary SD card (ArkOS installed)
- Linux PC (for partition editing)
- USB keyboard (backup input)
- OTG cable
- `OTG2WiFi.sh`
- `Install-XFCE.sh`
- `Launch-XFCE.sh`

---

## 🧩 Step 1: Prepare the SD Card (PC)

1. Insert the **secondary SD card** into your PC
2. Mount the SD card
3. Copy the script:

```text
OTG2WiFi.sh → /roms/tools/
````

4. Safely eject the SD card

---

## 🎮 Step 2: Enable Remote Access (Handheld)

1. Insert SD card into the handheld
2. Boot ArkOS
3. Navigate to:

```text
Tools → OTG2WiFi.sh
```

4. Run the script
5. Go to **Advanced**
6. Press **Enable Remote Access**
7. Power off the device

---

## 🔌 Step 3: OTG Connection & PC Network Setup

1. Connect the handheld to your PC using **OTG**
2. Follow PC-side network configuration

> 📌 **TODO:** Add PC OTG network configuration steps here

---

## 🔐 Step 4: SSH Into the Device

Connect via SSH:

```bash
ssh ark@<DEVICE_IP>
```

> 📌 **TODO:** Add IP address details here

---

## 📁 Step 5: Copy Script to fs_root

Once connected:

```bash
cp /roms/tools/OTG2WiFi.sh ~/
```

This copies the script into **fs_root (home directory)**.

---

## 💾 Step 6: Resize SD Card Partitions (Linux PC)

1. Power off the handheld

2. Remove the SD card

3. Insert it into your Linux PC

4. Using **GParted** (or similar):

   * ❌ Delete **third partition** (`easyroms`)
   * 📈 Resize **second partition** (`fs_root`) to **maximum size**

5. Apply changes

6. Update the **fs partition config file**

> 📌 **TODO:** Add exact config file edits here

7. Safely eject the SD card

---

## 🔄 Step 7: Remove Emulation Software

1. Insert SD card back into the handheld
2. Boot and reconnect via SSH
3. Remove emulation components:

```bash
sudo apt remove --purge emulationstation ppsspp retroarch
sudo apt autoremove
```

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
bash Install-XFCE.sh
```

⏳ Installation may take several minutes.

---

## ⚙️ Step 9: Enable Auto-Start Services

Create `systemd` services to auto-run:

* `OTG2WiFi.sh`
* `Launch-XFCE.sh`

> 📌 **TODO:** Add service files and enable commands here

After reboot, **XFCE should start automatically**.

---

## 🎮 Step 10: Configure Controls (QJoyPad)

1. Confirm **QJoyPad is already installed**
2. Install joystick utilities:

```bash
sudo apt install joystick
```

3. Run joystick configuration commands

> 📌 **TODO:** Add joystick config commands here

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
