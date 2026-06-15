#!/usr/bin/env bash
# Rasterize workflow icons to PNG via Chrome headless (not ImageMagick).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/workflow/src"
OUT="$ROOT/assets/workflow"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

CHROME="${CHROME:-google-chrome}"
if ! command -v "$CHROME" >/dev/null 2>&1; then
  CHROME=chromium-browser
fi

render_icon() {
  local name="$1"
  local fill="$2"
  local svg_file="$SRC/$3"
  local html="$WORK/$name.html"

  python3 - "$svg_file" "$fill" "$html" <<'PY'
import re
import sys
from pathlib import Path

svg_path, fill, html_path = sys.argv[1:4]
svg = Path(svg_path).read_text()
svg = re.sub(r'\s+width="16"\s+height="16"', '', svg, count=1)
svg = re.sub(r'<path\b', f'<path fill="{fill}"', svg)
svg = re.sub(r'fill="[^"]*"\s+fill="', 'fill="', svg)
html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ width: 128px; height: 128px; background: #161b22; display: flex; align-items: center; justify-content: center; }}
svg {{ width: 96px; height: 96px; display: block; }}
</style></head><body>{svg}</body></html>"""
Path(html_path).write_text(html)
PY

  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --window-size=128,128 --force-device-scale-factor=2 \
    --screenshot="$OUT/$name.png" "file://$html"
  echo "wrote $OUT/$name.png"
}

render_traffic() {
  local html="$WORK/traffic-green.html"
  cat > "$html" <<EOF
<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { width: 128px; height: 128px; background: #161b22; display: flex; align-items: center; justify-content: center; }
svg { width: 96px; height: 96px; display: block; }
</style></head><body>
$(cat "$SRC/traffic-green.svg")
</body></html>
EOF
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --window-size=128,128 --force-device-scale-factor=2 \
    --screenshot="$OUT/traffic-green.png" "file://$html"
  echo "wrote $OUT/traffic-green.png"
}

render_icon people '#c9d1d9' people-16.svg
render_icon issue-opened '#58a6ff' issue-opened-16.svg
render_icon git-pull-request '#c9d1d9' git-pull-request-16.svg
render_icon git-merge '#a371f7' git-merge-16.svg
render_traffic
