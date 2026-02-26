#!/usr/bin/env bash

INTERNAL="eDP-1"

# Get all monitors (active + disabled)
ALL_MONITORS=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}')
ACTIVE_MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# Find external monitor (anything that's not eDP-1)
EXTERNAL=$(echo "$ALL_MONITORS" | grep -v "$INTERNAL" | head -1)

# If no external monitor connected, do nothing
if [ -z "$EXTERNAL" ]; then
    notify-send "Monitor" "No external monitor detected"
    exit 0
fi

INTERNAL_ACTIVE=$(echo "$ACTIVE_MONITORS" | grep -q "$INTERNAL" && echo "yes" || echo "no")
EXTERNAL_ACTIVE=$(echo "$ACTIVE_MONITORS" | grep -q "$EXTERNAL" && echo "yes" || echo "no")

if [ "$INTERNAL_ACTIVE" = "yes" ] && [ "$EXTERNAL_ACTIVE" = "yes" ]; then
    # Both on → external only
    hyprctl keyword monitor "$INTERNAL,disable"
    notify-send "Monitor" "External only ($EXTERNAL)"
elif [ "$INTERNAL_ACTIVE" = "no" ] && [ "$EXTERNAL_ACTIVE" = "yes" ]; then
    # External only → internal only
    hyprctl keyword monitor "$INTERNAL,2944x1840@90.00Hz,auto,1.60"
    hyprctl keyword monitor "$EXTERNAL,disable"
    notify-send "Monitor" "Internal only ($INTERNAL)"
else
    # Internal only → both on
    hyprctl keyword monitor "$EXTERNAL,3840x2160@120.00Hz,auto,1.60"
    notify-send "Monitor" "Both monitors"
fi
