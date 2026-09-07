#!/usr/bin/env bash
# Regenerates the README preview images. One image per use, no light/dark variants:
#   assets/preview.png          banner: the six icons on a light rounded card (2752x512)
#   assets/thumbs/*.png         table thumbnails on the same card (144x144)
#   assets/social-preview.png   1280x640 card for the repo's social preview (rendered at 2x)
# The card background keeps the black icons visible on GitHub's dark theme too.
# Requires ImageMagick 7 (banner, thumbs) and Chrome (social card; macOS path below,
# set CHROME=/path/to/chrome elsewhere). Run: bash scripts/build-previews.sh
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
CARD_FILL='#f4f4f5'; CARD_EDGE='#e4e4e7'
ICONS=(png/512/shadcn-avatar-{a,b,c,d,e,f}.png)

# Banner: six 320px boxes, 128px gaps, 96px padding -> 2752x512, on a rounded card
magick "${ICONS[@]}" -filter Lanczos -resize 320x320 +repage \
  -background none -bordercolor none -border 64x0 +repage +append -bordercolor none -border 32x96 +repage "$TMP/row.png"
magick -size 2752x512 xc:none -fill "$CARD_FILL" -stroke "$CARD_EDGE" -strokewidth 2 \
  -draw "roundrectangle 1,1 2750,510 40,40" "$TMP/row.png" -gravity center -composite +repage assets/preview.png

# Table thumbnails: 144x144 card with the icon at 100px (displayed at 48px in the README)
mkdir -p assets/thumbs
for f in "${ICONS[@]}"; do
  magick -size 144x144 xc:none -fill "$CARD_FILL" -stroke "$CARD_EDGE" -strokewidth 1.5 \
    -draw "roundrectangle 1,1 142,142 22,22" \( "$f" -filter Lanczos -resize 100x100 +repage \) \
    -gravity center -composite +repage "assets/thumbs/$(basename "$f")"
done

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
