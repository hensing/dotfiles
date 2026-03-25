#!/bin/bash

# --- CONFIGURATION ---
SOURCE="/Volumes/Photos/"
TARGET="/Volumes/Photos_ext/"
RSYNC_BIN="/opt/homebrew/bin/rsync"

# Fallback to system rsync if Homebrew version isn't found
if [ ! -x "$RSYNC_BIN" ]; then
    RSYNC_BIN="rsync"
fi

# --- VALIDATION ---
# Check if source and target are actually mounted
if [ ! -d "$SOURCE" ]; then
    echo "❌ Source $SOURCE not found."
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "❌ Target $TARGET not found. Is the drive connected?"
    exit 1
fi

# --- NOTIFICATION (Start) ---
osascript -e "display notification \"Syncing $SOURCE to $TARGET...\" with title \"📸 Photo Backup\""

echo "🚀 Starting rsync from $SOURCE to $TARGET..."

# --- RSYNC COMMAND ---
# -a: Archive mode (preserves times, permissions)
# -v: Verbose output
# -P: Show progress and allow resuming partial transfers
# --delete: Remove files from target if they were deleted from source
$RSYNC_BIN -auvP --delete \
    --exclude='.DS_Store' \
    --exclude='.fseventsd' \
    --exclude='.Spotlight-V100' \
    --exclude='.Trashes' \
    --exclude='.TemporaryItems' \
    --exclude='Lightroom/' \
    "$SOURCE" "$TARGET"

# --- STATUS CHECK ---
if [ $? -eq 0 ]; then
    echo "✅ Backup completed successfully."
    osascript -e "display notification \"Backup finished successfully!\" with title \"📸 Photo Backup\""
else
    echo "⚠️ Backup failed or interrupted (Code $?)"
    osascript -e "display notification \"ERROR during backup! Check Terminal.\" with title \"📸 Photo Backup\""
fi

