#!/bin/bash

# --- 1. REPAIR TERMUX & PHP (System Fix) ---
# Sabse pehle hum PHP ko fresh install karenge
echo -e "\033[1;33m[*] Fixing PHP Installation... (Wait)\033[0m"
pkg install php -y > /dev/null 2>&1

# --- 2. PREPARE CLEAN FOLDER (Home Directory) ---
HOME_DIR="/data/data/com.termux/files/home"
PROJECT_DIR="$HOME_DIR/anurag_pro_server"
TMP_DIR="$PROJECT_DIR/tmp_data"

# Purana folder safai
pkill -f php > /dev/null 2>&1
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/auth"
mkdir -p "$TMP_DIR"
chmod -R 777 "$PROJECT_DIR"

# --- 3. CREATE STRONG CONFIG (php.ini) ---
# Ye file PHP ko bataegi ki system folder ko hath bhi na lagaye
cat > "$PROJECT_DIR/php.ini" <<EOF
[PHP]
sys_temp_dir = "$TMP_DIR"
upload_tmp_dir = "$TMP_DIR"
session.save_path = "$TMP_DIR"
error_log = "$PROJECT_DIR/error.log"
display_errors = Off
EOF

# --- 4. CREATE DUMMY PAGE ---
cat > "$PROJECT_DIR/auth/index.php" <<EOF
<html>
<body style="background:black;color:cyan;text-align:center;margin-top:50px;">
<h1>✅ SERVER IS WORKING!</h1>
<p>Anurag Pro Tool is Online</p>
<form method="POST" action="login.php">
<input style="padding:10px" name="user" placeholder="Test User"><br><br>
<button style="padding:10px">LOGIN</button>
</form>
</body>
</html>
EOF

# --- 5. CAPTURE LOGIC ---
cat > "$PROJECT_DIR/auth/login.php" <<EOF
<?php
file_put_contents("../creds.txt", "LOG: " . \$_POST['user'] . "\n", FILE_APPEND);
header('Location: /');
?>
EOF

# --- 6. LAUNCH SERVER (Localhost Mode) ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}╔══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║      ${CYAN}NUCLEAR FIX MODE (Port 4444)${GREEN}    ║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════╝${RESET}"

echo -e "${CYAN}[*] Server Path: $PROJECT_DIR${RESET}"
echo -e "${CYAN}[*] Starting on 127.0.0.1:4444...${RESET}"

# --- THE FIX COMMAND ---
# -c flag se hum apni php.ini force kar rahe hain
# 127.0.0.1 use kar rahe hain jo sabse safe hai
cd "$PROJECT_DIR"
php -S 127.0.0.1:4444 -c php.ini -t auth > server.log 2>&1 &
PID=$!
sleep 3

# --- 7. VERIFY ---
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] SUCCESS! Server Started.${RESET}"
    echo -e "${CYAN}Link: http://127.0.0.1:4444${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Exit${RESET}"
    
    # Loop
    while true; do
        sleep 1
    done
else
    echo -e "${RED}[!] FAILED AGAIN.${RESET}"
    echo -e "${CYAN}Original Error Log:${RESET}"
    cat server.log
fi
