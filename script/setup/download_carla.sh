#!/usr/bin/env bash
# Download the prebuilt custom CARLA (server + matching Python client wheel) from Google Drive.
# Run on the HOST, before building the container image (the image installs the wheel).
#   - CARLA server (LinuxNoEditor) -> $DEST          (runs on the host)
#   - Python client wheel          -> container/     (installed into the image)
# Usage: ./script/setup/download_carla.sh [dest]   (default: ~/carla-zenoh)
set -e

FILE_ID="1MZyKA5rGsMphfWDFM__e5y0kmwDUiSuL"
WHEEL="carla-0.9.16-cp312-cp312-linux_x86_64.whl"
DEST="${1:-$HOME/carla-zenoh}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHIVE="$DEST/carla-zenoh-shipping.tar.gz"

python3 -c "import gdown" 2>/dev/null || python3 -m pip install --user --break-system-packages gdown

mkdir -p "$DEST"
[ -f "$ARCHIVE" ] || python3 -m gdown "$FILE_ID" -O "$ARCHIVE"
tar -xf "$ARCHIVE" -C "$DEST"
cp "$DEST/$WHEEL" "$REPO/container/$WHEEL"

echo "Done. CARLA server: $DEST/LinuxNoEditor | wheel -> container/$WHEEL"
