#!/usr/bin/env bash
# Regenerates the README preview images, a light and a dark card for each use:
#   assets/preview.png / preview-dark.png     banner, six icons in a row, transparent (2752x512)
#   assets/thumbs/*.png / thumbs-dark/*.png   table thumbnails, transparent (144x144)
#   assets/social-preview.png                 1280x640 card for the repo's social preview
# The README picks the dark files via <picture> + prefers-color-scheme, which follows the
# viewer's OS setting.
# Requires ImageMagick 7 (banner, thumbs) and Chrome (social card; macOS path below,
# set CHROME=/path/to/chrome elsewhere). Run: bash scripts/build-previews.sh
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
ICONS=(png/512/shadcn-avatar-{a,b,c,d,e,f}.png)

# theme name, banner output, thumbs dir, stroke recolor (empty = keep black). Transparent backgrounds.
build_theme() {
  local banner=$2 thumbs=$3 recolor=$4
  local rc=(); [ -n "$recolor" ] && rc=(-channel RGB -fill "$recolor" -colorize 100 +channel)
  # Banner: six 320px boxes, 128px gaps, 96px padding -> 2752x512
  magick "${ICONS[@]}" -filter Lanczos -resize 320x320 +repage \
    -background none -bordercolor none -border 64x0 +repage +append -bordercolor none -border 32x96 +repage \
    ${rc[@]+"${rc[@]}"} "$banner"
  # Thumbnails: 144x144, icon at 120px (displayed at 48px in the README)
  mkdir -p "$thumbs"
  for f in "${ICONS[@]}"; do
    magick "$f" -filter Lanczos -resize 120x120 +repage ${rc[@]+"${rc[@]}"} \
      -background none -gravity center -extent 144x144 +repage "$thumbs/$(basename "$f")"
  done
}
build_theme light assets/preview.png      assets/thumbs      ''
build_theme dark  assets/preview-dark.png assets/thumbs-dark white

# Social preview card, 1280x640 at 2x, rendered from the SVGs with headless Chrome
icons_html() { # $1 = px per icon, $2 = gap px -> the six svgs inline, in a row
  for s in svg/*.svg; do cat "$s"; done |
    sed "s|<svg |<svg style=\"width:$1px;height:$1px;flex:none;margin-right:$2px\" |g"
}
shot() { # $1 html (absolute), $2 out png (absolute), $3 width, $4 height, $5 scale
  rm -f "$2"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run --no-default-browser-check \
    --use-mock-keychain --user-data-dir="$TMP/profile" --default-background-color=00000000 \
    --force-device-scale-factor="$5" --window-size="$3,$4" --screenshot="$2" "file://$1" >/dev/null 2>&1 &
  local pid=$! i=0
  # new headless Chrome writes the screenshot but does not always exit: wait for the file, then stop it
  while [ $i -lt 120 ] && [ ! -s "$2" ]; do sleep 0.25; i=$((i+1)); done
  sleep 0.5; kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true
  [ -s "$2" ] || { echo "render failed: $2" >&2; exit 1; }
}
cat > "$TMP/social.html" <<HTML
<!doctype html><meta charset="utf-8">
<body style="margin:0;width:1280px;height:640px;background:#fff;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Inter,Helvetica,Arial,sans-serif;color:#09090b;display:flex;flex-direction:column;align-items:center;justify-content:center">
<div style="display:flex;margin-left:40px">$(icons_html 140 40)</div>
<div style="font-size:54px;font-weight:600;letter-spacing:-0.02em;margin-top:56px">shadcn avatar icons</div>
<div style="font-size:26px;color:#71717a;margin-top:14px">6 free SVG icons &nbsp;·&nbsp; 24 × 24 &nbsp;·&nbsp; MIT &nbsp;·&nbsp; by @eugypastore</div>
</body>
HTML
shot "$TMP/social.html" "$PWD/assets/social-preview.png" 1280 640 2
echo "previews built"
