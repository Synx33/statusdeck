#!/usr/bin/env bash
# Installs statusdeck as your Claude Code status line.
# Usage: install.sh [theme]   (tokyo, catppuccin, dracula, nord, gruvbox, neon, slate)
set -euo pipefail
command -v jq >/dev/null || { echo "statusdeck needs jq (e.g. sudo apt install jq)"; exit 1; }
command -v bc >/dev/null || { echo "statusdeck needs bc (e.g. sudo apt install bc)"; exit 1; }
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/statusline.sh"
DEST_DIR="$HOME/.claude/statusdeck"; DEST="$DEST_DIR/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST"; chmod +x "$DEST"
if [ -n "${1:-}" ]; then sed -i.tmp "s/STATUSLINE_THEME:-[a-z]*/STATUSLINE_THEME:-$1/" "$DEST" && rm -f "$DEST.tmp"; fi
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "$SETTINGS.bak-statusdeck"
tmp=$(mktemp)
jq --arg cmd "$DEST" '.statusLine = {type:"command", command:$cmd, padding:0}' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
echo "statusdeck installed → $DEST"
echo "settings backup → $SETTINGS.bak-statusdeck"
