---
name: install
description: Install or reinstall the statusdeck status line into the user's Claude Code settings. Use when the user runs /statusdeck:install or asks to set up statusdeck.
---

Install statusdeck as the user's status line.

1. Run the installer. Pass a theme name if the user gave one (tokyo, catppuccin, dracula, nord, gruvbox, neon, slate):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/install.sh" [theme]
   ```
   If `CLAUDE_PLUGIN_ROOT` is empty, locate the script with
   `find ~/.claude/plugins -path '*statusdeck*/scripts/install.sh' | head -1` and run that.
2. Tell the user it is installed, that a backup of their settings was saved to
   `~/.claude/settings.json.bak-statusdeck`, and that the bar appears after their next message.
