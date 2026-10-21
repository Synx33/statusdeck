---
name: theme
description: Switch or preview the statusdeck status line color theme. Use when the user runs /statusdeck:theme or asks to change statusdeck colors.
---

Themes: tokyo (default), catppuccin, dracula, nord, gruvbox, neon, slate.

- To preview, tell the user to run this themselves (Claude cannot see terminal colors):
  ```
  ! for t in tokyo catppuccin dracula nord gruvbox neon slate; do echo "== $t"; STATUSLINE_THEME=$t COLUMNS=110 STATUSLINE_DEBUG= ~/.claude/statusdeck/statusline.sh < /dev/null; done
  ```
- To switch, run:
  ```bash
  sed -i "s/STATUSLINE_THEME:-[a-z]*/STATUSLINE_THEME:-<theme>/" ~/.claude/statusdeck/statusline.sh
  ```
  The new colors show after the next message.
