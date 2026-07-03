#!/usr/bin/env bash
# Hyprland clamshell mode: disable/enable laptop screen based on lid state.
# Invoked via hyprland.conf: bindl = , switch:on:Lid Switch, exec, ~/.config/hypr/clamshell.sh on
#                             bindl = , switch:off:Lid Switch, exec, ~/.config/hypr/clamshell.sh off

LAPTOP="eDP-1"

get_external() {
    hyprctl monitors -j | jq -r --arg l "$LAPTOP" '.[] | select(.name != $l) | .name' | head -1
}

case "${1:-}" in
  on)
    # Lid closing — enter clamshell if an external monitor is present
    EXTERNAL=$(get_external)
    if [ -n "$EXTERNAL" ]; then
      # Move all laptop workspaces to the external monitor before disabling
      hyprctl workspaces -j | \
        jq -r --arg m "$LAPTOP" '.[] | select(.monitor == $m) | .id' | \
        while read -r ws; do
          hyprctl dispatch moveworkspacetomonitor "$ws $EXTERNAL"
        done
      sleep 0.3
      hyprctl keyword monitor "$LAPTOP, disable"
    fi
    ;;
  off)
    # Lid opening — restore laptop display
    hyprctl keyword monitor "$LAPTOP, 1920x1200@60, 0x0, 1"
    sleep 0.3
    # Nudge external monitor back to its expected position (it may drift to 0,0 while eDP-1 was off)
    EXTERNAL=$(get_external)
    if [ -n "$EXTERNAL" ]; then
      hyprctl keyword monitor "$EXTERNAL, preferred, 1920x0, 1.5"
    fi
    ;;
  *)
    echo "Usage: $0 on|off" >&2
    exit 1
    ;;
esac
