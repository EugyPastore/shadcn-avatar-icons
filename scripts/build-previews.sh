#!/usr/bin/env bash
# Regenerates the README preview images from svg/*.svg:
#   assets/dark/*.svg         white copies for GitHub dark mode
#   assets/preview-*.png      banner, light and dark (from assets/banner/*.png)
#   assets/social-preview.png 1280x640 card for the repo's social preview
# Rendering uses headless Chrome for proper curve anti-aliasing. macOS path
# below; set CHROME=/path/to/chrome elsewhere. Run: bash scripts/build-previews.sh
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
mkdir -p assets/dark

icons_html() { # $1 = px per icon, $2 = gap px -> the six svgs inline, in a row
  for f in svg/*.svg; do cat "$f"; done |
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

for f in svg/*.svg; do sed 's/currentColor/white/g' "$f" > "assets/dark/$(basename "$f")"; done

# Banner: composed from the designer's PNG exports in assets/banner/ (with keyline guides),
# 6 icons at 320px, 128px gaps, 96px padding -> 2752x512. Dark twin: black strokes become
# white, the gray guides stay as they are. Requires ImageMagick 7.
magick assets/banner/shadcn-avatar-{a,b,c,d,e,f}.png -filter Lanczos -resize 320x320 \
  -background none +smush 128 -bordercolor none -border 96 assets/preview-light.png
magick assets/preview-light.png -channel RGB +level-colors 'white,gray(112)' +channel assets/preview-dark.png

# Social preview card, 1280x640 at 2x
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
