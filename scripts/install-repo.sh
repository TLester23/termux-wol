#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
BASE_URL='https://TLester23.github.io/termux-wol'
KEYRING="$PREFIX/etc/apt/keyrings/termux-wol.gpg"
SOURCE="$PREFIX/etc/apt/sources.list.d/termux-wol.list"
command -v curl >/dev/null 2>&1 || pkg install -y curl
mkdir -p "$(dirname "$KEYRING")" "$(dirname "$SOURCE")"
curl -fsSL "$BASE_URL/termux-wol-archive-keyring.gpg" -o "$KEYRING"
printf 'deb [arch=all signed-by=%s] %s stable main\n' "$KEYRING" "$BASE_URL" > "$SOURCE"
echo 'Repository configured. Run: pkg update && pkg install termux-wol'
