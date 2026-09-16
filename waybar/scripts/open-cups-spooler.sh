#!/usr/bin/env bash
# =============================================================================
# Open CUPS Print Spooler / Queue Window
# =============================================================================

# Find active printer or default destination
PRINTER_NAME=$(lpstat -d 2>/dev/null | awk -F': ' '{print $2}' | xargs)
if [[ -z "$PRINTER_NAME" ]]; then
    PRINTER_NAME=$(lpstat -p 2>/dev/null | awk '{print $2}' | head -n 1)
fi
if [[ -z "$PRINTER_NAME" ]]; then
    PRINTER_NAME="Canon_G3010"
fi

if command -v system-config-printer >/dev/null 2>&1; then
    exec system-config-printer --show-jobs "$PRINTER_NAME"
else
    exec xdg-open "http://localhost:631/jobs/"
fi
