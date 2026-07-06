#!/usr/bin/env bash
# Clamshell + docking for Hyprland — reliability-first design.
#
# HARD CONSTRAINT proven on this machine: reaching ZERO enabled monitors wedges
# the compositor (disable eDP-1 then unplug the external => black, frozen, even
# keybinds dead; suspend can't save it — it collides with itself and stalls on
# hyprlock). Therefore eDP-1 is NEVER disabled.
#
# To still get true clamshell (cursor cannot sit on the laptop panel) we PARK the
# internal output far off-screen (99999x0) with a real gap and its backlight off.
# A gap between monitors confines relative cursor motion, so the panel is
# unreachable, yet it stays enabled so the monitor count never hits zero. On
# unplug the panel is simply moved back to 0x0 and lit — no wedge, always recovers.
#
# Wiring (hyprland.conf + home-manager systemd service):
#   bindl switch:on:Lid Switch  -> lidclose  (== reconcile)
#   bindl switch:off:Lid Switch -> reconcile (lid opened)
#   bind  Super+Ctrl+D          -> restore   (force laptop panel back, any state)
#   systemd user service        -> watch     (reacts to cable plug/unplug)

LAPTOP="eDP-1"
LAPTOP_MODE="1920x1200@60"
PARK_POS="99999x0"          # far off-screen; gap from the external confines the cursor
LOG="$HOME/.cache/clamshell.log"

log() { echo "$(date '+%F %T') $*" >> "$LOG" 2>/dev/null; }

lid_present() {
  ls /proc/acpi/button/lid/*/state >/dev/null 2>&1
}

lid_closed() {
  grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null
}

# First enabled monitor that isn't the internal panel, or empty.
external_name() {
  hyprctl monitors -j | jq -r --arg l "$LAPTOP" 'first(.[] | select(.name != $l) | .name) // empty'
}

scale_of() {
  hyprctl monitors -j | jq -r --arg n "$1" 'first(.[] | select(.name == $n) | .scale) // 1'
}

move_workspaces_to() {
  local target="$1" ws
  for ws in $(hyprctl workspaces -j | jq -r --arg l "$LAPTOP" '.[] | select(.monitor == $l) | .id'); do
    hyprctl dispatch moveworkspacetomonitor "$ws $target" >/dev/null
  done
}

# Laptop panel at the origin and lit; external (if present) to its right.
# Order matters: move the external to its final spot (1920x0) BEFORE placing the
# panel at 0x0, so the two are never both at the origin (Hyprland warns on any
# momentary overlap). Explicit 1920x0 (not auto-right) avoids the external chasing
# the panel while it is still parked far away.
laptop_primary() {
  local ext; ext="$(external_name)"
  [ -n "$ext" ] && hyprctl keyword monitor "$ext, preferred, 1920x0, $(scale_of "$ext")" >/dev/null
  hyprctl keyword monitor "$LAPTOP, $LAPTOP_MODE, 0x0, 1" >/dev/null
  hyprctl dispatch dpms on "$LAPTOP" >/dev/null
}

reconcile() {
  lid_present || { log "no lid switch on this host -> skip"; return; }
  local ext; ext="$(external_name)"
  if lid_closed && [ -n "$ext" ]; then
    log "clamshell: park $LAPTOP at $PARK_POS (dark), $ext -> 0x0"
    move_workspaces_to "$ext"
    # Park the panel FIRST (out of the origin), then pin the external at 0x0.
    # This ordering avoids a transient two-monitors-at-0x0 overlap warning.
    hyprctl keyword monitor "$LAPTOP, $LAPTOP_MODE, $PARK_POS, 1" >/dev/null
    hyprctl keyword monitor "$ext, preferred, 0x0, $(scale_of "$ext")" >/dev/null
    hyprctl dispatch dpms off "$LAPTOP" >/dev/null
  else
    log "laptop primary (lid_closed=$(lid_closed && echo y || echo n) ext='$ext')"
    laptop_primary
  fi
}

case "${1:-}" in
  reconcile|lidclose)
    reconcile
    ;;
  restore)
    log "manual restore (Super+Ctrl+D)"
    laptop_primary
    ;;
  watch)
    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    until [ -S "$SOCKET" ]; do sleep 0.5; done
    log "watch: started"
    reconcile
    socat -u "UNIX-CONNECT:$SOCKET" - | while IFS= read -r line; do
      case "$line" in
        monitoradded*|monitorremoved*)
          log "watch: event ${line%%>>*}"
          reconcile
          ;;
      esac
    done
    ;;
  *)
    echo "Usage: $0 reconcile|lidclose|restore|watch" >&2
    exit 1
    ;;
esac
