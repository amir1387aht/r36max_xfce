#!/bin/bash
progdir=$(dirname "$(realpath "$0")")
CUR_TTY=/dev/tty0
export TERM=linux
sudo chmod 666 $CUR_TTY
printf "\033c" > $CUR_TTY
echo "Starting XFCE."  > $CUR_TTY

# Clean up any stale X server locks
sudo rm -f /tmp/.X1-lock
sudo rm -f /tmp/.X11-unix/X1

# Enable swap if not already on
sudo swapon $progdir/swapfile 2>/dev/null || true
sudo mkdir -p /run/user/1002
sudo chown 1002 /run/user/1002/
pulseaudio --start

# Start XFCE in background
startx /usr/bin/startxfce4 -- :1 -keeptty > $progdir/xfce.log 2>&1 &
XPID=$!

# Wait for X to start
sleep 3

# Keep switching to VT2 while X is running
while kill -0 $XPID 2>/dev/null; do
    sudo chvt 2
    sleep 10  # Check every 10 seconds
done

wait $XPID

sudo swapoff -a
echo "Exiting ..." > $CUR_TTY