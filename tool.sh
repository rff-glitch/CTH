#!/usr/bin/env bash
FILE="$1"
ARCHIVE_TYPE=""
JOHN_DIR="$HOME/john"
RUN_DIR="$JOHN_DIR/run"

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

echo -e "AHE ---- Archive Hash Extractor ---- by Rff-glitch\n"
echo -e "[*] Updating system..."
sudo apt update -y >/dev/null 2>&1 &
spinner $!
echo -e "[✔] System updated"

echo -e "[*] Installing dependencies..."
sudo apt install -y build-essential git perl p7zip-full unrar-free rar unzip libssl-dev zlib1g-dev libbz2-dev >/dev/null 2>&1 &
spinner $!
echo -e "[✔] Dependencies ready"

if [ ! -d "$JOHN_DIR" ]; then
    echo -e "[*] John Jumbo not found, cloning and building..."
    git clone https://github.com/openwall/john "$JOHN_DIR" >/dev/null 2>&1
    cd "$JOHN_DIR/src"
    ./configure >/dev/null 2>&1
    make -sj$(nproc) >/dev/null 2>&1 &
    spinner $!
    echo -e "[✔] John Jumbo built"
else
    echo -e "[✔] John Jumbo already installed, skipping build"
fi

if [ -z "$FILE" ]; then
    echo -e "[✖] Usage: ./tool.sh <archive>"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo -e "[✖] File not found"
    exit 1
fi

EXT="${FILE##*.}"
case "$EXT" in
    zip) ARCHIVE_TYPE="zip"; BIN="$RUN_DIR/zip2john" ;;
    rar) ARCHIVE_TYPE="rar"; BIN="$RUN_DIR/rar2john" ;;
    7z)  ARCHIVE_TYPE="7z";  BIN="$RUN_DIR/7z2john" ;;
    *) echo -e "[✖] Unsupported archive type"; exit 1 ;;
esac

if [ ! -x "$BIN" ]; then
    echo -e "[*] Making $BIN executable"
    chmod +x "$BIN"
fi

echo -e "[*] Extracting hash from $ARCHIVE_TYPE archive..."
HASH_FILE="${FILE%.*}.hash"
"$BIN" "$FILE" > "$HASH_FILE" &
spinner $!
echo -e "[✔] Hash extracted to $HASH_FILE"
