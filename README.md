# statusdeck

A labeled, full-width status line for [Claude Code](https://claude.com/claude-code). Every row says what it means.

```
╭ CLAUDE CODE · my session ──────────────────────────────────────────────
│ BRAIN     Opus 5.5  effort medium  thinking on   ← the AI model + how hard it thinks
│ WHERE     ~/project  git  main   ← folder Claude is working in
│ MEMORY    ■■■■■■······························ 15% 150k/1.0M · 850k left  ← chat memory; full = auto-compacts
│ 5H LIMIT  ■■······································ 4% resets in 2h 10m  ← usage cap for this 5-hour window
│ WEEKLY    ■■■■···································· 10% resets in 3d 19h  ← usage cap for the week
│ CACHE     93% reused · warm · expires in 59m  ← higher = faster & cheaper replies
│ SESSION   $0.59 spent  ⏱ 3m22s total (1m52s AI working)  ↑60k in ↓3k out  +147/-47 lines
╰────────────────────────────────────────────────────────────────────────
```

Bars shift green → amber → red as they fill.

## Install

Requires `jq` and `bc`.

In Claude Code:

```
/plugin marketplace add Synx33/statusdeck
/plugin install statusdeck@statusdeck
/statusdeck:install
```

Or without the plugin system:

```bash
git clone https://github.com/Synx33/statusdeck
bash statusdeck/scripts/install.sh            # optional: pass a theme name
```

The installer copies the script to `~/.claude/statusdeck/statusline.sh`, points `statusLine` in `~/.claude/settings.json` at it, and saves a backup of your settings to `~/.claude/settings.json.bak-statusdeck`.

## Themes

`tokyo` (default) · `catppuccin` · `dracula` · `nord` · `gruvbox` · `neon` · `slate`

Switch with `/statusdeck:theme`, or:

```bash
sed -i "s/STATUSLINE_THEME:-[a-z]*/STATUSLINE_THEME:-dracula/" ~/.claude/statusdeck/statusline.sh
```

## Uninstall

```bash
jq 'del(.statusLine)' ~/.claude/settings.json > /tmp/s && mv /tmp/s ~/.claude/settings.json
rm -rf ~/.claude/statusdeck
```

## Privacy

The script only reads the JSON Claude Code passes to it on stdin and runs `git branch`. It makes no network requests and writes nothing, unless you set `STATUSLINE_DEBUG=1`, which saves the last input to `~/.claude/statusline-last.json`.

## License

MIT
