#!/bin/bash

# --- 1. FIND TERMUX NATIVE TEMP DIR ---
# Ye Termux ka wo folder hai jahan permission kabhi fail nahi hoti
TERMUX_TMP="/data/data/com.termux/files/usr/tmp"

# Agar ye folder nahi mila, to hum ise khud bana denge
if [ ! -d "$TERMUX_TMP" ]; then
    mkdir -p "$TERMUX_TMP"
fi

# --- 2. FORCE ENVIRONMENT VARIABLES ---
# Ye sabse jaruri line hai. Hum system ko bata rahe hain ki
# "Temporary kaam ke liye sirf isi folder ko use karo"
export TMPDIR="$TERMUX_TMP"
export TEMP="$TERMUX_TMP"
export TMP="$TERMUX_TMP"

# --- 3. CLEANUP OLD PROCESSES ---
pkill -f php > /dev/null 2>&1

# --- 4. CREATE DUMMY FILES (To avoid empty errors) ---
# Ek clean environment banate hain
mkdir -p $HOME/myserver
echo "<h1>It Works!</h1>" > $HOME/myserver/index.php
touch $HOME/myserver/usernames.txt

# --- 5. INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}=========================================${RESET}"
echo -e "${CYAN}   TERMUX NATIVE FIX (Official Path)     ${RESET}"
echo -e "${GREEN}=========================================${RESET}"
echo -e "${CYAN}[*] Using Temp Path: $TERMUX_TMP${RESET}"
echo -e "${CYAN}[*] Starting Server on Port 8080...${RESET}"

# --- 6. RUN SERVER ---
# Is baar hum '0.0.0.0' ki jagah '127.0.0.1' try karenge pehle
# Kyunki kuch phones me 0.0.0.0 permission error deta hai lock file ke liye
cd $HOME/myserver
php -S 127.0.0.1:8080 -t . > php_log.txt 2>&1 &
PID=$!
sleep 2

# --- 7. CHECK IF STARTED ---
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] SERVER STARTED SUCCESSFULLY!${RESET}"
    echo -e "${CYAN}Link: http://127.0.0.1:8080${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    
    # Wait loop
    while true; do
        sleep 1
    done
else
    echo -e "${RED}[!] STILL FAILED. Checking Logs...${RESET}"
    echo -e "${RED}=====================================${RESET}"
    cat php_log.txt
    echo -e "${RED}=====================================${RESET}"
fi
