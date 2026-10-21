#!/usr/bin/env bash
# statusdeck — labeled full-width statusline for Claude Code
# https://github.com/Synx33/statusdeck  ·  MIT
input=$(cat)
[ -n "$STATUSLINE_DEBUG" ] && echo "$input" > "$HOME/.claude/statusline-last.json"   # debug: set STATUSLINE_DEBUG=1
j() { echo "$input" | jq -r "$1 // empty" 2>/dev/null; }

# ── theme ────────────────────────────────────────────────
# Pick one: tokyo · catppuccin · dracula · nord · gruvbox · neon · slate
THEME=${STATUSLINE_THEME:-tokyo}
R=$'\e[0m'; DIM=$'\e[2m'; B=$'\e[1m'
c() { printf '\e[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
case "$THEME" in
  catppuccin) FRAME=$(c 203 166 247); ACC=$(c 137 180 250); OK=$(c 166 227 161); WARN=$(c 249 226 175)
              CRIT=$(c 243 139 168); SEC=$(c 245 194 231); GREY=$(c 88 91 112); FG=$(c 205 214 244) ;;
  dracula)    FRAME=$(c 189 147 249); ACC=$(c 139 233 253); OK=$(c 80 250 123);  WARN=$(c 241 250 140)
              CRIT=$(c 255 85 85);    SEC=$(c 255 121 198); GREY=$(c 98 114 164); FG=$(c 248 248 242) ;;
  nord)       FRAME=$(c 129 161 193); ACC=$(c 136 192 208); OK=$(c 163 190 140); WARN=$(c 235 203 139)
              CRIT=$(c 191 97 106);   SEC=$(c 180 142 173); GREY=$(c 76 86 106);  FG=$(c 236 239 244) ;;
  gruvbox)    FRAME=$(c 214 93 14);   ACC=$(c 250 189 47);  OK=$(c 184 187 38);  WARN=$(c 254 128 25)
              CRIT=$(c 251 73 52);    SEC=$(c 211 134 155); GREY=$(c 102 92 84);  FG=$(c 235 219 178) ;;
  neon)       FRAME=$(c 255 0 170);   ACC=$(c 0 240 255);   OK=$(c 57 255 20);   WARN=$(c 255 176 0)
              CRIT=$(c 255 40 60);    SEC=$(c 150 90 255);  GREY=$(c 90 90 120);  FG=$(c 230 230 255) ;;
  slate)      FRAME=$(c 88 98 112);   ACC=$(c 122 162 204); OK=$(c 126 170 130); WARN=$(c 201 164 95)
              CRIT=$(c 196 102 102);  SEC=$(c 160 170 185); GREY=$(c 80 86 96);   FG=$(c 220 224 230) ;;
  *)          FRAME=$(c 122 162 247); ACC=$(c 125 207 255); OK=$(c 158 206 106); WARN=$(c 224 175 104)
              CRIT=$(c 247 118 142);  SEC=$(c 187 154 247); GREY=$(c 65 72 104);  FG=$(c 192 202 245) ;;
esac
# names used below
PINK=$FRAME; CYAN=$ACC; LIME=$OK; AMBER=$WARN; RED=$CRIT; VIO=$SEC; WHITE=$FG

# ── width ────────────────────────────────────────────────
W=${COLUMNS:-$(tput cols 2>/dev/null)}; W=${W:-100}; [ "$W" -lt 70 ] && W=70
BARW=$(( W - 62 )); [ "$BARW" -lt 12 ] && BARW=12; [ "$BARW" -gt 50 ] && BARW=50

# ── helpers ──────────────────────────────────────────────
human() { local n=${1:-0}; n=${n%.*}
  if   [ "$n" -ge 1000000 ]; then printf '%.1fM' "$(echo "$n/1000000" | bc -l)"
  elif [ "$n" -ge 1000 ];    then printf '%.0fk' "$(echo "$n/1000" | bc -l)"
  else printf '%s' "$n"; fi; }
color_for() { local p=${1:-0}
  if [ "$p" -ge 80 ]; then echo "$RED"; elif [ "$p" -ge 50 ]; then echo "$AMBER"; else echo "$LIME"; fi; }
bar() { local p=${1%.*}; p=${p:-0}
  local f=$(( p * BARW / 100 )) out="" i cell
  [ "$p" -gt 0 ] && [ $f -eq 0 ] && f=1
  for ((i=0;i<BARW;i++)); do
    if [ $i -lt $f ]; then cell=$(color_for $(( i * 100 / BARW ))); out+="${cell}■"
    else out+="${GREY}·"; fi
  done
  printf '%s%s' "$out" "$R"; }
until_ts() { local t=$1; [ -z "$t" ] && return; local d=$(( ${t%.*} - $(date +%s) )); [ $d -lt 0 ] && d=0
  if [ $d -ge 86400 ]; then printf '%dd %dh' $((d/86400)) $((d%86400/3600))
  elif [ $d -ge 3600 ]; then printf '%dh %dm' $((d/3600)) $((d%3600/60))
  else printf '%dm' $((d/60)); fi; }
fmt_ms() { local s=$(( ${1%.*} / 1000 ))
  if [ $s -ge 3600 ]; then printf '%dh%02dm' $((s/3600)) $((s%3600/60)); else printf '%dm%02ds' $((s/60)) $((s%60)); fi; }
row() { printf '%s│%s %s%-9s%s %s\n' "$PINK" "$R" "$B$CYAN" "$1" "$R" "$2"; }
hint() { printf '%s%s← %s%s' "$DIM" "$GREY" "$1" "$R"; }

# ── data ─────────────────────────────────────────────────
model=$(j '.model.display_name'); effort=$(j '.effort.level')
think=$(j '.thinking.enabled'); fast=$(j '.fast_mode')
sname=$(j '.session_name')
dir=$(j '.workspace.current_dir'); dir=${dir:-$PWD}
branch=$(git -C "$dir" branch --show-current 2>/dev/null); dir=${dir/#$HOME/\~}

pct=$(j '.context_window.used_percentage'); pct=${pct%.*}; pct=${pct:-0}
size=$(j '.context_window.context_window_size')
used=$(j '.context_window.current_usage | (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)')

h5=$(j '.rate_limits.five_hour.used_percentage'); h5r=$(j '.rate_limits.five_hour.resets_at')
d7=$(j '.rate_limits.seven_day.used_percentage'); d7r=$(j '.rate_limits.seven_day.resets_at')

hit=$(j '.prompt_cache.hit_ratio'); warm=$(j '.prompt_cache.warm'); cexp=$(j '.prompt_cache.expires_at')

cost=$(j '.cost.total_cost_usd'); dur=$(j '.cost.total_duration_ms'); api=$(j '.cost.total_api_duration_ms')
add=$(j '.cost.total_lines_added'); rem=$(j '.cost.total_lines_removed')
tin=$(j '.context_window.total_input_tokens'); tout=$(j '.context_window.total_output_tokens')

# ── header ───────────────────────────────────────────────
title=" CLAUDE CODE "
[ -n "$sname" ] && title+="· ${sname} "
pad=$(( W - ${#title} - 2 )); [ $pad -lt 0 ] && pad=0
printf '%s╭%s%s%s%s\n' "$PINK" "$B" "$title" "$R$PINK$(printf '─%.0s' $(seq 1 $pad))" "$R"

# BRAIN — which model & how hard it thinks
b="${WHITE}${B}${model:-?}${R}"
[ -n "$effort" ] && b+="  ${GREY}effort${R} ${VIO}${effort}${R}"
[ "$think" = "true" ] && b+="  ${GREY}thinking${R} ${LIME}on${R}" || b+="  ${GREY}thinking${R} ${GREY}off${R}"
[ "$fast" = "true" ] && b+="  ${AMBER}⚡fast${R}"
row "BRAIN" "$b   $(hint 'the AI model + how hard it thinks')"

# WHERE — folder & git branch
w="${VIO}${dir}${R}"; [ -n "$branch" ] && w+="  ${GREY}git${R} ${LIME} ${branch}${R}"
row "WHERE" "$w   $(hint 'folder Claude is working in')"

# MEMORY — context window
c=$(color_for "$pct"); left=$(( ${size:-0} - ${used:-0} ))
row "MEMORY" "$(bar "$pct") ${c}${B}${pct}%${R} ${GREY}$(human "$used")/$(human "$size") · $(human "$left") left${R}  $(hint 'chat memory; full = auto-compacts')"

# LIMITS — plan usage
[ -n "$h5" ] && row "5H LIMIT" "$(bar "$h5") $(color_for "${h5%.*}")${B}${h5%.*}%${R} ${GREY}resets in $(until_ts "$h5r")${R}  $(hint 'usage cap for this 5-hour window')"
[ -n "$d7" ] && row "WEEKLY" "$(bar "$d7") $(color_for "${d7%.*}")${B}${d7%.*}%${R} ${GREY}resets in $(until_ts "$d7r")${R}  $(hint 'usage cap for the week')"

# CACHE — reuse of already-sent context
if [ -n "$hit" ]; then
  hp=$(printf '%.0f' "$(echo "$hit*100" | bc -l)")
  st=$([ "$warm" = "true" ] && echo "${LIME}warm${R}" || echo "${AMBER}cold${R}")
  cx=""; [ -n "$cexp" ] && cx=" ${GREY}· expires in $(until_ts "$cexp")${R}"
  row "CACHE" "${CYAN}${hp}% reused${R} ${GREY}·${R} ${st}${cx}  $(hint 'higher = faster & cheaper replies')"
fi

# SESSION — spend, time, tokens, edits
s=""
[ -n "$cost" ] && s+="${AMBER}\$$(printf '%.2f' "$cost")${R} ${GREY}spent${R}"
[ -n "$dur" ] && s+="  ${VIO}⏱ $(fmt_ms "$dur")${R}${GREY} total${R}"
[ -n "$api" ] && s+=" ${GREY}($(fmt_ms "$api") AI working)${R}"
[ -n "$tin" ] && s+="  ${CYAN}↑$(human "$tin") in${R} ${PINK}↓$(human "$tout") out${R}"
[ -n "$add" ] && s+="  ${LIME}+${add}${R}${GREY}/${R}${RED}-${rem:-0}${R} ${GREY}lines${R}"
row "SESSION" "$s"

printf '%s╰%s%s\n' "$PINK" "$(printf '─%.0s' $(seq 1 $(( W - 2 ))))" "$R"
