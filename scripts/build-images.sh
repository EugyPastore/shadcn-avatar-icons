#!/usr/bin/env bash
# Renders PNG exports and README previews from svg/*.svg.
# Requires ImageMagick 7 (`brew install imagemagick`). Run from anywhere:
#   bash scripts/build-images.sh
set -euo pipefail
cd "$(dirname "$0")/.."

SIZES="128 256 512 1024"
ORDER="shadcn-avatar shadcn-avatar-sunglasses shadcn-avatar-sunglasses-filled shadcn-avatar-bust shadcn-avatar-bust-sunglasses shadcn-avatar-minimal"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for f in svg/*.svg; do
  name=$(basename "$f" .svg)
  # currentColor has no meaning outside a document, so pin a color for rasterising
  sed 's/currentColor/black/g' "$f" > "$TMP/$name-black.svg"
  sed 's/currentColor/white/g' "$f" > "$TMP/$name-white.svg"
  # README dark-mode previews
  cp "$TMP/$name-white.svg" "assets/dark/$name.svg"
  # 1024px master, then downscale for each size
  magick -background none -density 3072 "$TMP/$name-black.svg" -resize 1024x1024 "$TMP/$name-black.png"
  magick -background none -density 3072 "$TMP/$name-white.svg" -resize 1024x1024 "$TMP/$name-white.png"
  for s in $SIZES; do
    mkdir -p "png/$s"
    magick "$TMP/$name-black.png" -resize "${s}x${s}" "png/$s/$name.png"
  done
done

# Banner previews (transparent background, one row of icons)
for theme in black white; do
  args=()
  for name in $ORDER; do
    magick "$TMP/$name-$theme.png" -resize 160x160 "$TMP/banner-$name-$theme.png"
    args+=("$TMP/banner-$name-$theme.png")
  done
  out=assets/preview-light.png; [ "$theme" = white ] && out=assets/preview-dark.png
  magick "${args[@]}" -background none +smush 64 -bordercolor none -border 48x48 "$out"
done
echo "images built"
