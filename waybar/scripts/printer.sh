#!/usr/bin/env bash
# =============================================================================
# Waybar Printer Status Monitor Script
# Monitors CUPS print queue and hardware/printer status for Canon PIXMA & CUPS
# Output: JSON for Waybar custom module
# =============================================================================

# Get queued jobs
JOBS_RAW=$(lpstat -o 2>/dev/null)
JOB_COUNT=0
if [[ -n "$JOBS_RAW" ]]; then
    JOB_COUNT=$(echo "$JOBS_RAW" | grep -c -v '^[[:space:]]*$')
fi

# Get printer status
PRINTER_STATUS=$(lpstat -p 2>/dev/null)
PRINTER_DISABLED=0
if echo "$PRINTER_STATUS" | grep -qi "disabled"; then
    PRINTER_DISABLED=1
fi

# Build Tooltip
TOOLTIP="<b>🖨️ CUPS Printer Status</b>\n"

if [[ -n "$PRINTER_STATUS" ]]; then
    CLEAN_STATUS=$(echo "$PRINTER_STATUS" | head -n 2 | sed 's/^[ \t]*//')
    TOOLTIP="${TOOLTIP}\n<b>State:</b> ${CLEAN_STATUS}\n"
fi

if [[ $JOB_COUNT -gt 0 ]]; then
    TOOLTIP="${TOOLTIP}\n<b>Active / Queued Jobs (${JOB_COUNT}):</b>\n"
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Parse line: Canon_G3010-49  x  1221632  Rabu 16 Sep...
            JOB_ID=$(echo "$line" | awk '{print $1}')
            JOB_SIZE=$(echo "$line" | awk '{print $3}')
            # Convert size to human readable if numeric
            if [[ "$JOB_SIZE" =~ ^[0-9]+$ ]]; then
                if [[ $JOB_SIZE -ge 1048576 ]]; then
                    HR_SIZE=$(awk "BEGIN {printf \"%.1f MB\", $JOB_SIZE/1048576}")
                elif [[ $JOB_SIZE -ge 1024 ]]; then
                    HR_SIZE=$(awk "BEGIN {printf \"%.1f KB\", $JOB_SIZE/1024}")
                else
                    HR_SIZE="${JOB_SIZE} B"
                fi
            else
                HR_SIZE="$JOB_SIZE"
            fi
            TOOLTIP="${TOOLTIP}• <b>${JOB_ID}</b> (${HR_SIZE})\n"
        fi
    done <<< "$JOBS_RAW"
else
    TOOLTIP="${TOOLTIP}\nNo active print jobs in queue.\n"
fi

TOOLTIP="${TOOLTIP}\n<i>Left-click: Open Canon G-Series Tool\nMiddle-click: Resume / Unpause Queue\nRight-click: CUPS Jobs Web UI</i>"

# Determine Class, Text, and Alt
if [[ $PRINTER_DISABLED -eq 1 ]]; then
    CLASS="paused"
    if [[ $JOB_COUNT -gt 0 ]]; then
        TEXT="󰐪 ${JOB_COUNT} (Paused)"
        ALT="paused"
    else
        TEXT="󰐪 Paused"
        ALT="paused"
    fi
elif [[ $JOB_COUNT -gt 0 ]]; then
    CLASS="printing"
    TEXT="󰐪 ${JOB_COUNT}"
    ALT="printing"
else
    # Idle - hide or show nothing
    CLASS="idle"
    TEXT=""
    ALT="idle"
fi

# Escape tooltip for JSON
ESCAPED_TOOLTIP=$(printf '%s' "$TOOLTIP" | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))')

# Output JSON
cat <<EOF
{"text": "${TEXT}", "alt": "${ALT}", "tooltip": ${ESCAPED_TOOLTIP}, "class": "${CLASS}", "count": ${JOB_COUNT}}
EOF
