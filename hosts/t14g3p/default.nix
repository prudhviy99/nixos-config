{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ../../modules/zram.nix ../../modules/overlays.nix];
  
  # ---- Hostname ----
  networking.hostName = "t14g3p";

  # ADD THIS TO YOUR GLOBAL SYSTEM CONFIGURATION (e.g., configuration.nix)
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # memtest86+
  boot.loader.systemd-boot.memtest86.enable = true;

  # Enable RTC alarm for reliable s2idle wakeup and suspend-then-hibernate.
  # PSR (Panel Self Refresh) is kept enabled by default for battery savings.
  boot.kernelParams = [ "rtc_cmos.use_acpi_alarm=1" ];

  # ---- Intel CPU microcode ----
  hardware.cpu.intel.updateMicrocode = true;

  # ---- Intel iGPU acceleration (Iris Xe / UHD Graphics) ----
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver       # iHD: gen8+ (Alder Lake)
      intel-vaapi-driver       # i965: legacy fallback
      vpl-gpu-rt               # newer media SDK
    ];
  };

  # ---- Power management ----
  # power-profiles-daemon integrates natively with Intel P-State & Alder Lake E-cores
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;   # Intel thermal management daemon

  # Automatic display power-off and idle suspend are safe on this Intel laptop,
  # but must not leak into the shared Home Manager profile (the NVIDIA desktop
  # can freeze during the DPMS off/on lock sequence).
  home-manager.users.fedal.services.hypridle.settings.listener = lib.mkAfter [
    {
      timeout = 360;                 # 6 min -> turn off screen (DPMS off)
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";
    }
    {
      timeout = 900;                 # 15 min -> suspend on prolonged idle
      on-timeout = "systemctl suspend";
    }
  ];

  # ---- Lazy-unmount FUSE mounts before suspend to prevent s2idle sleep freeze ----
  powerManagement.powerDownCommands = ''
    while IFS=' ' read -r _ mountpoint fstype _; do
      if [[ "$fstype" == "fuse.gvfsd-fuse" ]]; then
        ${pkgs.fuse3}/bin/fusermount3 -uz "$mountpoint" 2>/dev/null || true
      fi
    done < /proc/mounts
  '';

  # ---- Fingerprint reader (Synaptics WBDI) ----
  services.fprintd.enable = true;
  systemd.services.fprintd.serviceConfig.TimeoutStopSec = 5;

  # ---- Firmware updates via LVFS ----
  services.fwupd.enable = true;

  # ---- Lid behavior ----
  # Hyprland's clamshell.sh owns lid handling so a docked laptop keeps running
  # on its external display. Letting logind handle these events as well races the
  # compositor-side handler and can suspend the machine while it is docked.
  services.logind.settings.Login = {
    HandleLidSwitch              = "ignore";
    HandleLidSwitchDocked         = "ignore";
    HandleLidSwitchExternalPower  = "ignore";
    HandlePowerKey               = "suspend";
  };
}
