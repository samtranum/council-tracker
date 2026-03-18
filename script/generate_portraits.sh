#!/usr/bin/env bash
# Usage: ./script/generate_portraits.sh <source-image> <councillor-slug>
# Example: ./script/generate_portraits.sh ~/Downloads/jane-smith.jpg jane-smith
#
# Generates the 4 portrait variants and places them in public/councillors/<slug>/

set -e

SOURCE="$1"
SLUG="$2"

if [[ -z "$SOURCE" || -z "$SLUG" ]]; then
  echo "Usage: $0 <source-image> <councillor-slug>"
  exit 1
fi

if [[ ! -f "$SOURCE" ]]; then
  echo "Error: file not found: $SOURCE"
  exit 1
fi

DEST="public/councillors/$SLUG"
mkdir -p "$DEST"

echo "Generating portraits for '$SLUG' in $DEST ..."

# Original → portrait.png (just convert to PNG)
convert "$SOURCE" "$DEST/portrait.png"
echo "  portrait.png (original)"

# Small → 192x192, cropped to fill
convert "$SOURCE" -resize 192x192^ -gravity Center -extent 192x192 "$DEST/small_portrait.png"
echo "  small_portrait.png (192x192 cropped)"

# Medium → fit within 512x512 (no crop)
convert "$SOURCE" -resize 512x512\> "$DEST/medium_portrait.png"
echo "  medium_portrait.png (512x512 max)"

# Large → fit within 1024x1024 (no crop)
convert "$SOURCE" -resize 1024x1024\> "$DEST/large_portrait.png"
echo "  large_portrait.png (1024x1024 max)"

echo ""
echo "Done! Now commit with:"
echo "  git add $DEST"
echo "  git commit -m 'Add portrait for $SLUG'"
echo "  git push"
