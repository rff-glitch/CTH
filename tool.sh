#!/usr/bin/env bash
set -e

FILE="$1"
WORKDIR="$(pwd)"
JOHN="/opt/john"
RUN="$JOHN/run"

if [ -z "$FILE" ]; then
  echo "Usage: sudo ./tool.sh <archive>"
  echo "       sudo ./tool.sh <archive> --resume"
  echo "       sudo ./tool.sh <archive> --stop"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

echo "=========================================="
echo "     Archive Password Cracker - rff-glitch"
echo "=========================================="
echo

# Check flags
if [ "$2" = "--resume" ] || [ "$2" = "-r" ]; then
  RESUME_MODE=true
elif [ "$2" = "--stop" ] || [ "$2" = "-s" ]; then
  STOP_MODE=true
fi

# Install deps
echo "[*] Installing dependencies..."
apt update -y >/dev/null 2>&1
apt install -y git build-essential python3 perl p7zip-full rar unzip hashcat libssl-dev zlib1g-dev >/dev/null 2>&1
echo "[+] Dependencies installed"

# Build John
if [ -d "$JOHN/run" ]; then
  echo "[+] John already built"
else
  echo "[*] Building John the Ripper..."
  rm -rf "$JOHN" >/dev/null 2>&1
  git clone https://github.com/openwall/john "$JOHN" >/dev/null 2>&1
  cd "$JOHN/src"
  ./configure >/dev/null 2>&1
  make -sj$(nproc) >/dev/null 2>&1
  cd "$WORKDIR"
  echo "[+] John built"
fi

EXT="${FILE##*.}"
OUT="${FILE}.hash"
FILENAME=$(basename "$FILE")

# Stop mode
if [ "$STOP_MODE" = true ]; then
  echo "[*] Stopping attack..."
  pkill -f "hashcat.*$(basename "$OUT")" 2>/dev/null || true
  echo "[+] Attack stopped"
  exit 0
fi

# Resume mode
if [ "$RESUME_MODE" = true ]; then
  echo "[*] Looking for restore file..."
  RESTORE_FILE=$(find . -name "*.restore" 2>/dev/null | head -1)
  
  if [ -z "$RESTORE_FILE" ]; then
    echo "[-] No restore file found"
    exit 1
  fi
  
  echo "[+] Resuming from: $(basename "$RESTORE_FILE")"
  case "$EXT" in
    zip) MODE=13600 ;;
    rar) MODE=13000 ;;
    7z) MODE=11600 ;;
  esac
  
  hashcat --restore --restore-file-path "$RESTORE_FILE" 2>/dev/null || \
  hashcat -m "$MODE" "$OUT" --restore --restore-file-path "$RESTORE_FILE"
  exit 0
fi

# Extract hash
echo "[*] Extracting hash from $FILENAME..."
case "$EXT" in
  zip)
    "$RUN/zip2john" "$FILE" 2>/dev/null | grep -o '\$zip2\$[^:]*' > "$OUT"
    MODE=13600
    TYPE="ZIP"
    ;;
  rar)
    "$RUN/rar2john" "$FILE" 2>/dev/null | cut -d: -f2- > "$OUT"
    MODE=13000
    TYPE="RAR"
    ;;
  7z)
    "$RUN/7z2john" "$FILE" 2>/dev/null | cut -d: -f2- > "$OUT"
    MODE=11600
    TYPE="7-Zip"
    ;;
  *)
    echo "[-] Unsupported format: $EXT"
    exit 1
    ;;
esac

sed -i '/^$/d' "$OUT"
sed -i 's/^\s*//;s/\s*$//' "$OUT"

if [ ! -s "$OUT" ]; then
  echo "[-] Failed to extract hash"
  exit 1
fi

echo "[+] $TYPE hash extracted"

# Get attack settings
echo
echo "--- Attack Settings ---"
echo "1) Numbers (0-9)"
echo "2) Lowercase (a-z)"
echo "3) Uppercase (A-Z)"
echo "4) Mixed (a-z, A-Z)"
echo "5) Alphanumeric (a-z, A-Z, 0-9)"
echo "6) All characters"
echo
read -p "Select [1-6]: " CHOICE

read -p "Min length [1]: " MIN_LEN
MIN_LEN=${MIN_LEN:-1}

read -p "Max length [8]: " MAX_LEN
MAX_LEN=${MAX_LEN:-8}

# Validate
if ! [[ "$MIN_LEN" =~ ^[0-9]+$ ]] || ! [[ "$MAX_LEN" =~ ^[0-9]+$ ]]; then
  MIN_LEN=1
  MAX_LEN=8
fi

if [ "$MIN_LEN" -gt "$MAX_LEN" ]; then
  TEMP=$MIN_LEN
  MIN_LEN=$MAX_LEN
  MAX_LEN=$TEMP
fi

# Set charset
case "$CHOICE" in
  1) CHARSET="?d" ;;
  2) CHARSET="?l" ;;
  3) CHARSET="?u" ;;
  4) CHARSET="?l?u" ;;
  5) CHARSET="?l?u?d" ;;
  6) CHARSET="?a" ;;
  *) 
    echo "[-] Invalid choice, using alphanumeric"
    CHARSET="?l?u?d"
    ;;
esac

# Generate mask
if [ "$MIN_LEN" -eq "$MAX_LEN" ]; then
  MASK=$(printf "$CHARSET%.0s" $(seq 1 "$MAX_LEN"))
else
  MASK=$(printf "$CHARSET%.0s" $(seq 1 "$MAX_LEN"))
fi

# Start attack
echo
echo "--- Starting Attack ---"
echo "File: $FILENAME"
echo "Type: $TYPE (Mode: $MODE)"
echo "Length: $MIN_LEN-$MAX_LEN chars"
echo
echo "Press Ctrl+C to pause"
echo "Resume with: ./tool.sh '$FILE' --resume"
echo

# Run hashcat
SESSION="crack_$(date +%s)"
if [ "$MIN_LEN" -eq "$MAX_LEN" ]; then
  hashcat -m "$MODE" "$OUT" -a 3 "$MASK" --session "$SESSION"
else
  hashcat -m "$MODE" "$OUT" -a 3 "$MASK" --increment --increment-min "$MIN_LEN" --increment-max "$MAX_LEN" --session "$SESSION"
fi

# Check result
if [ $? -eq 0 ]; then
  echo
  echo "[+] PASSWORD FOUND!"
  echo "[*] Check hashcat output above"
else
  echo
  echo "[*] Attack finished"
  echo "[*] Password not found"
  echo "[*] Resume with: ./tool.sh '$FILE' --resume"
fi
