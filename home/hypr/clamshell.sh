#!/usr/bin/env bash
# Clamshell + docking for Hyprland — canonical "disable eDP-1" design.
#
# WHY DISABLE (not park off-screen): a monitor that is merely moved off-screen is
# still ENABLED, so Hyprland keeps assigning new/ghost workspaces to it (Super+N,
# auto-migrations) and they vanish onto the dark laptop panel. The only way to stop
# that is to genuinely `disable` eDP-1 — a disabled output cannot hold a workspace.
# This is what every working Hyprland clamshell setup does.
#
# ZERO-MONITOR SAFETY: on THIS machine (Hyprland 0.55.4) the zero-monitor recovery
# fix (hyprwm/Hyprland PR #14547) is NOT present — it lands in 0.56+. So if we ever
# reach zero enabled monitors (undock while the lid is still closed), re-enabling can
# fail and wedge the compositor. `ensure_output()` catches that and runs the one
# confirmed recovery, `hyprctl reload` (hyprland.conf has eDP-1 enabled at 0x0).
#
# Wiring (hyprland.conf + home-manager systemd service):
#   bindl switch:on:Lid Switch  -> lidclose  (== reconcile)
#   bindl switch:off:Lid Switch -> reconcile (lid opened)
#   bind  Super+Ctrl+D          -> restore   (force laptop panel back, any state)
#   systemd user service        -> watch     (reacts to cable plug/unplug via IPC)

LAPTOP="eDP-1"
LAPTOP_MODE="1920x1200@60"
LOG="$HOME/.cache/clamshell.log"

log() { echo "$(date '+%F %T') $*" >> "$LOG" 2>/dev/null; }

lid_present() { ls /proc/acpi/button/lid/*/state >/dev/null 2>&1; }
lid_closed()  { grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null; }

# First ENABLED monitor that isn't the internal panel (i.e. the external), or empty.
# Disabled eDP-1 does not appear in `hyprctl monitors`, so this is safe either way.
external_name() {
  hyprctl monitors -j | jq -r --arg l "$LAPTOP" 'first(.[] | select(.name != $l) | .name) // empty'
}

scale_of() {
  hyprctl monitors -j | jq -r --arg n "$1" 'first(.[] | select(.name == $n) | .scale) // 1'
}

# Count of currently ENABLED monitors.
enabled_count() { hyprctl monitors -j | jq 'length'; }

# Never leave the session with no output. If enabling eDP-1 failed because we hit the
# 0.55.4 zero-monitor bug, reload the config (eDP-1 is enabled at 0x0 there) to recover.
ensure_output() {
  if [ "$(enabled_count)" -lt 1 ]; then
    log "ZERO enabled monitors -> hyprctl reload (recovery)"
    hyprctl reload >/dev/null
  fi
}

# Laptop panel primary at the origin and lit; external (if present) to its right.
# Move the external to 1920x0 FIRST so enabling eDP-1 at 0x0 never transiently
# overlaps it (Hyprland warns on any momentary overlap).
laptop_primary() {
  local ext; ext="$(external_name)"
  [ -n "$ext" ] && hyprctl keyword monitor "$ext, preferred, 1920x0, $(scale_of "$ext")" >/dev/null
  hyprctl keyword monitor "$LAPTOP, $LAPTOP_MODE, 0x0, 1" >/dev/null
  hyprctl dispatch dpms on "$LAPTOP" >/dev/null
  ensure_output
}

reconcile() {
  lid_present || { log "no lid switch on this host -> skip"; return; }
  local ext; ext="$(external_name)"
  if lid_closed && [ -n "$ext" ]; then
    # Clamshell: external only. Pin it at 0x0, then fully DISABLE the laptop panel so
    # it can never receive a workspace. Hyprland auto-migrates eDP-1's workspaces to
    # the external — do NOT move them by hand (that creates stale monitor bindings).
    log "clamshell: external=$ext at 0x0, disable $LAPTOP"
    hyprctl keyword monitor "$ext, preferred, 0x0, $(scale_of "$ext")" >/dev/null
    hyprctl keyword monitor "$LAPTOP, disable" >/dev/null
  else
    log "laptop primary (lid_closed=$(lid_closed && echo y || echo n) ext='$ext')"
    laptop_primary
  fi
}

case "${1:-}" in
  reconcile)
    reconcile
    ;;
  lidclose)
    # Undocked (no external) + lid just closed -> actually suspend. Otherwise
    # reconcile()'s else-branch would call laptop_primary() and force eDP-1
    # back on/dpms-on right after the lid shut, which is why the laptop used
    # to never lock/sleep and just sat awake in the bag draining the battery.
    if lid_present && lid_closed && [ -z "$(external_name)" ]; then
      log "lid closed, undocked -> suspend"
      systemctl suspend
    else
      reconcile
    fi
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
          # Ignore events about our OWN eDP-1 disable/enable to avoid any self-loop;
          # only react to the EXTERNAL monitor appearing/disappearing.
          case "$line" in
            *"$LAPTOP"*) continue ;;
          esac
          log "watch: event ${line%%$'\n'*}"
          sleep 0.3            # coalesce the add/addv2 burst before acting
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
