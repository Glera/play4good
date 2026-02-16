#!/usr/bin/env bash
set -euo pipefail

# Build both games from p4g-platform and copy into the site
# Usage: bash build-games.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM_DIR="$SCRIPT_DIR/../p4g-platform"
SITE_DIR="$SCRIPT_DIR/project14294856"

echo "=== Building games for play4good ==="
echo ""

# 1. Build all packages (dependencies)
echo "[1/4] Building packages..."
(cd "$SCRIPT_DIR/../liveops-shared" && npm run build)
(cd "$SCRIPT_DIR/../solitaire-core" && npm run build)
(cd "$SCRIPT_DIR/../treasure-hunt" && npm run build)
(cd "$SCRIPT_DIR/../dungeon-dig" && npm run build)
(cd "$SCRIPT_DIR/../mahjong-core" && npm run build)
echo "  OK: All packages built"
echo ""

# 2. Build Solitaire
echo "[2/4] Building Solitaire..."
(cd "$PLATFORM_DIR" && npx vite build --base /solitaire/)
rm -rf "$SITE_DIR/solitaire"
cp -r "$PLATFORM_DIR/dist/solitaire" "$SITE_DIR/solitaire"
SOL_SIZE=$(du -sh "$SITE_DIR/solitaire" | cut -f1)
echo "  OK: Solitaire -> $SITE_DIR/solitaire ($SOL_SIZE)"
echo ""

# 3. Build Mahjong
echo "[3/4] Building Mahjong..."
(cd "$PLATFORM_DIR" && GAME=mahjong npx vite build --base /mahjong/)
rm -rf "$SITE_DIR/mahjong"
cp -r "$PLATFORM_DIR/dist/mahjong" "$SITE_DIR/mahjong"
MAH_SIZE=$(du -sh "$SITE_DIR/mahjong" | cut -f1)
echo "  OK: Mahjong -> $SITE_DIR/mahjong ($MAH_SIZE)"
echo ""

# 4. Verify
echo "[4/4] Verifying..."
if [ -f "$SITE_DIR/solitaire/index.html" ] && [ -f "$SITE_DIR/mahjong/index.html" ]; then
  echo "  OK: Both games have index.html"
else
  echo "  FAIL: Missing index.html in game directories"
  exit 1
fi

echo ""
echo "=== DONE ==="
echo "Site ready at: $SITE_DIR"
echo "  Landing:   $SITE_DIR/index.html"
echo "  Solitaire: $SITE_DIR/solitaire/index.html"
echo "  Mahjong:   $SITE_DIR/mahjong/index.html"
