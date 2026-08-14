{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../modules/zram.nix ../../modules/overlays.nix];
  
  systemd.services.tlp.serviceConfig.StandardOutput = "null";
  # ---- Hostname ----
  networking.hostName = "t14g3p";

  # ADD THIS TO YOUR GLOBAL SYSTEM CONFIGURATION (e.g., configuration.nix)
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  #memtest86+
  
  boot.loader.systemd-boot.memtest86.enable = true;


  
  # fix screen flickering
  boot.kernelParams = [ "i915.enable_psr=0" ];

  # NOTE (2026-08-05): there used to be an iwlwifi power_save=0 / iwlmvm
  # power_scheme=1 override here, added because "WiFi keeps dropping after
  # inactivity". That diagnosis was wrong - the drops were the airplane-mode key
  # on the function row being pressed (rfkill), not power management. The
  # override forced the card into continuously-awake mode, burning power around
  # the clock for nothing, so it is gone. If WiFi ever "drops" again, check
  # `rfkill list` before blaming power saving.

  # ---- Intel CPU microcode (10th gen on T14s Gen 1 Intel) ----
  hardware.cpu.intel.updateMicrocode = true;

  # ---- Intel iGPU acceleration (UHD Graphics) ----
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver       # iHD: gen8+ (your CPU)
      intel-vaapi-driver               # i965: legacy fallback
      vpl-gpu-rt               # newer media SDK
    ];
  };

  # ---- Power management ----
  # TLP gives you significantly better battery life than the default
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";

      CPU_BOOST_ON_AC  = 1;
      CPU_BOOST_ON_BAT = 1;   # TLP disables turbo on battery by default

      # ThinkPad battery thresholds: charge to 80, start charging again at 75.
      # Massively extends battery lifespan over the years.
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0  = 80;

      # WiFi power saving: off on AC (lowest latency while docked/working), on when
      # on battery. This is TLP's own default split. It was previously "off" in both
      # cases to chase phantom WiFi drops that turned out to be the rfkill key - see
      # the note near boot.extraModprobeConfig above.
      WIFI_PWR_ON_AC  = "off";
      WIFI_PWR_ON_BAT = "on";

      # PCIe runtime PM while on AC. TLP's default is "on", which pins every PCIe
      # device fully powered whenever the charger is connected — that is why the
      # fans stay audible sitting idle in clamshell at the desk. "auto" only lets
      # devices drop down once they are genuinely idle; anything under load stays
      # at full speed, so there is no throughput or latency cost while working.
      # xhci_hcd (USB) is already in TLP's RUNTIME_PM_DRIVER_DENYLIST, so dock USB
      # is untouched. Matches RUNTIME_PM_ON_BAT, which has been "auto" all along.
      RUNTIME_PM_ON_AC = "auto";
    };
  };
  services.thermald.enable = true;   # Intel thermal management daemon

  # ---- Fingerprint reader (Synaptics WBDI on the T14s Gen 1) ----
  services.fprintd.enable = true;
  systemd.services.fprintd.serviceConfig.TimeoutStopSec = 5;

  # ---- Firmware updates via LVFS (Lenovo pushes BIOS through this) ----
  services.fwupd.enable = true;

  # After first boot, run: fwupdmgr refresh && fwupdmgr update

  # ---- Lid behavior ----
  # Hyprland's clamshell.sh owns the lid (see home/hypr/clamshell.sh):
  #   docked   -> disable the internal panel, keep the external monitor
  #   undocked -> suspend
  # logind must ignore the lid entirely, otherwise it suspends on lid-close
  # while docked (external power) and races with the compositor.
  services.logind.settings.Login = {
    HandleLidSwitch              = "ignore";
    HandleLidSwitchDocked         = "ignore";
    HandleLidSwitchExternalPower  = "ignore";
    HandlePowerKey               = "suspend";
  };
}
