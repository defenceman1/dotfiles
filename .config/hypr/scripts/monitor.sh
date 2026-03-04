#!/usr/bin/env bash
# ~/.config/hypr/scripts/monitor.sh
# Combined monitor management: lid switch + Super+P toggle
# Usage:
#   monitor.sh lid-close
#   monitor.sh lid-open
#   monitor.sh toggle    (also refreshes settings before switching)
#   monitor.sh refresh   (re-apply correct settings without switching)

INTERNAL="eDP-1"

get_best_mode() {
    local monitor="$1"
    local modes
    modes=$(hyprctl monitors all -j | jq -r --arg mon "$monitor" \
        '.[] | select(.name == $mon) | .availableModes[]')
    [ -z "$modes" ] && return 1
    echo "$modes" | awk -F'[x@]' '{
        gsub(/Hz/, "", $3)
        pixels = $1 * $2
        printf "%d %s %s %s\n", pixels, $1, $2, $3
    }' | sort -t' ' -k1,1nr -k4,4nr | head -1 | awk '{printf "%sx%s@%sHz", $2, $3, $4}'
}

get_scale() {
    local mode="$1"
    local width height pixels
    width=$(echo "$mode" | awk -F'[x@]' '{print $1}')
    height=$(echo "$mode" | awk -F'[x@]' '{print $2}')
    pixels=$((width * height))
    if [ "$pixels" -ge 8294400 ]; then
        echo "2"
    elif [ "$pixels" -gt 2073600 ]; then
        echo "1.60"
    else
        echo "1"
    fi
}

activate_monitor() {
    local monitor="$1"
    local mode scale
    mode=$(get_best_mode "$monitor")
    [ -z "$mode" ] && return 1
    scale=$(get_scale "$mode")
    hyprctl keyword monitor "$monitor,${mode},auto,${scale}"
}

lid_is_closed() {
    local state
    state=$(cat /proc/acpi/button/lid/LID0/state 2>/dev/null \
         || cat /proc/acpi/button/lid/LID/state 2>/dev/null)
    echo "$state" | grep -q "closed"
}

get_external() {
    hyprctl monitors all -j | jq -r --arg int "$INTERNAL" \
        '.[] | select(.name != $int) | .name' | head -1
}

is_active() {
    hyprctl monitors -j | jq -e --arg mon "$1" \
        '.[] | select(.name == $mon) | .disabled == false' >/dev/null 2>&1
}

ACTION="${1:-toggle}"
EXTERNAL=$(get_external)

case "$ACTION" in
    lid-close)
        if [ -n "$EXTERNAL" ]; then
            hyprctl keyword monitor "$INTERNAL,disable"
            activate_monitor "$EXTERNAL"
            notify-send "Monitor" "Lid closed - external only ($EXTERNAL)"
        else
            hyprlock &
            sleep 1
            systemctl suspend
        fi
        ;;
    lid-open)
        if [ -n "$EXTERNAL" ]; then
            activate_monitor "$INTERNAL"
            hyprctl keyword monitor "$EXTERNAL,disable"
            notify-send "Monitor" "Lid open - internal only ($INTERNAL)"
        fi
        ;;
    refresh)
        # Re-apply correct settings to all active monitors
        if is_active "$INTERNAL"; then
            activate_monitor "$INTERNAL"
        fi
        if [ -n "$EXTERNAL" ] && is_active "$EXTERNAL"; then
            activate_monitor "$EXTERNAL"
        fi
        notify-send "Monitor" "Refreshed active monitor settings"
        ;;
    toggle)
        if [ -z "$EXTERNAL" ]; then
            # No external — just refresh internal settings
            activate_monitor "$INTERNAL"
            notify-send "Monitor" "Refreshed ($INTERNAL)"
            exit 0
        fi
        if lid_is_closed; then
            # Lid closed — refresh external settings
            activate_monitor "$EXTERNAL"
            notify-send "Monitor" "Refreshed ($EXTERNAL)"
            exit 0
        fi
        if is_active "$INTERNAL"; then
            hyprctl keyword monitor "$INTERNAL,disable"
            activate_monitor "$EXTERNAL"
            notify-send "Monitor" "External only ($EXTERNAL)"
        else
            activate_monitor "$INTERNAL"
            hyprctl keyword monitor "$EXTERNAL,disable"
            notify-send "Monitor" "Internal only ($INTERNAL)"
        fi
        ;;
    *)
        echo "Usage: $0 {lid-close|lid-open|toggle|refresh}"
        exit 1
        ;;
esac
