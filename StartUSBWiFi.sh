#!/bin/bash
# Start USB Network Gadget (RNDIS/ECM)
# Enables internet sharing from computer to device

if [ "$EUID" -ne 0 ]; then
    exec sudo bash "$0" "$@"
    exit $?
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/usb_network_log.txt"
exec > >(tee -a "$LOG_FILE") 2>&1

echo ""
echo "===================================="
echo "Starting USB Network Gadget"
echo "Started: $(date)"
echo "===================================="
echo ""

CONFIGFS="/sys/kernel/config/usb_gadget"
GADGET_NAME="network_gadget"
GADGET_PATH="$CONFIGFS/$GADGET_NAME"

# Network configuration
DEVICE_IP="192.168.137.2"
HOST_IP="192.168.137.1"
NETMASK="255.255.255.0"

echo "Network configuration:"
echo "  Device IP: $DEVICE_IP"
echo "  Host IP: $HOST_IP"
echo "  Netmask: $NETMASK"
echo ""

# Check if gadget already exists
if [ -d "$GADGET_PATH" ]; then
    echo "Gadget already exists! Cleaning up first..."
    echo "" > "$GADGET_PATH/UDC" 2>/dev/null
    rm -f "$GADGET_PATH/configs/c.1/rndis.usb0" 2>/dev/null
    rm -f "$GADGET_PATH/configs/c.1/ecm.usb0" 2>/dev/null
    rmdir "$GADGET_PATH/configs/c.1/strings/0x409" 2>/dev/null
    rmdir "$GADGET_PATH/configs/c.1" 2>/dev/null
    rmdir "$GADGET_PATH/functions/rndis.usb0" 2>/dev/null
    rmdir "$GADGET_PATH/functions/ecm.usb0" 2>/dev/null
    rmdir "$GADGET_PATH/strings/0x409" 2>/dev/null
    rmdir "$GADGET_PATH" 2>/dev/null
    sleep 2
fi

# Create gadget directory
echo "Creating gadget structure..."
mkdir -p "$GADGET_PATH"
cd "$GADGET_PATH"

# Set USB IDs (Microsoft RNDIS compatible)
echo 0x1d6b > idVendor     # Linux Foundation
echo 0x0104 > idProduct    # Multifunction Composite Gadget
echo 0x0100 > bcdDevice    # Device version
echo 0x0200 > bcdUSB       # USB 2.0

# Create strings
mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Linux Foundation" > strings/0x409/manufacturer
echo "USB Network Device" > strings/0x409/product

# Create network function (RNDIS for Windows, ECM for Linux/Mac)
# RNDIS has better Windows compatibility
mkdir -p functions/rndis.usb0

# Set host and device MAC addresses
echo "00:11:22:33:44:55" > functions/rndis.usb0/host_addr
echo "00:11:22:33:44:56" > functions/rndis.usb0/dev_addr

# For better compatibility, also create ECM (optional, comment out if not needed)
# mkdir -p functions/ecm.usb0
# echo "00:11:22:33:44:57" > functions/ecm.usb0/host_addr
# echo "00:11:22:33:44:58" > functions/ecm.usb0/dev_addr

echo "✓ Network function created"

# Create configuration
mkdir -p configs/c.1
mkdir -p configs/c.1/strings/0x409
echo "RNDIS Network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

# Create symlink
ln -s "$GADGET_PATH/functions/rndis.usb0" "$GADGET_PATH/configs/c.1/"
# If using ECM too:
# ln -s "$GADGET_PATH/functions/ecm.usb0" "$GADGET_PATH/configs/c.1/"

# Configure OS descriptors for Windows
echo 1 > os_desc/use
echo 0xcd > os_desc/b_vendor_code
echo "MSFT100" > os_desc/qw_sign
ln -s "$GADGET_PATH/configs/c.1" "$GADGET_PATH/os_desc"

echo "✓ Configuration created"

# Find and enable UDC
UDC=$(ls /sys/class/udc | head -n 1)
if [ -z "$UDC" ]; then
    echo "ERROR: No UDC found"
    exit 1
fi
echo "Found UDC: $UDC"

# Enable gadget
echo "$UDC" > UDC

echo ""
echo "✓ USB Network Gadget enabled"
echo ""

# Wait for network interface to appear
echo "Waiting for network interface..."
sleep 3

# Find the usb0 interface
IFACE="usb0"
if ! ip link show "$IFACE" > /dev/null 2>&1; then
    echo "WARNING: Interface $IFACE not found yet"
    echo "Available interfaces:"
    ip link show
    echo ""
    echo "Try waiting a few seconds and configure manually:"
    echo "  sudo ip addr add $DEVICE_IP/24 dev usb0"
    echo "  sudo ip link set usb0 up"
else
    echo "✓ Interface $IFACE found"

    # Configure network interface
    echo "Configuring network interface..."
    ip addr flush dev "$IFACE" 2>/dev/null
    ip addr add "$DEVICE_IP/24" dev "$IFACE"
    ip link set "$IFACE" up

    echo "✓ Interface configured"

    # Set default route through host
    echo "Setting up routing..."
    ip route add default via "$HOST_IP" dev "$IFACE" metric 100 2>/dev/null

    echo "✓ Routing configured"
fi

echo ""
echo "===================================="
echo "Setup Complete!"
echo "===================================="
echo ""
echo "On your COMPUTER, configure internet sharing:"
echo ""
echo "--- Linux ---"
echo "1. Enable IP forwarding:"
echo "   sudo sysctl -w net.ipv4.ip_forward=1"
echo ""
echo "2. Set up NAT (replace eth0 with your internet interface):"
echo "   sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
echo "   sudo iptables -A FORWARD -i eth0 -o usb0 -m state --state RELATED,ESTABLISHED -j ACCEPT"
echo "   sudo iptables -A FORWARD -i usb0 -o eth0 -j ACCEPT"
echo ""
echo "3. The computer should auto-assign IP or manually set:"
echo "   sudo ip addr add $HOST_IP/24 dev usb0"
echo "   sudo ip link set usb0 up"
echo ""
echo "--- Windows ---"
echo "1. Go to Network Connections"
echo "2. Right-click your internet connection > Properties"
echo "3. Sharing tab > Enable 'Allow other network users to connect'"
echo "4. Select the USB network device"
echo ""
echo "--- macOS ---"
echo "1. System Preferences > Sharing"
echo "2. Enable 'Internet Sharing'"
echo "3. Share from: (your internet connection)"
echo "4. To computers using: USB Ethernet (or similar)"
echo ""
echo "Then test on device:"
echo "  ping 8.8.8.8"
echo "  ping google.com"
echo ""
echo "Script finished: $(date)