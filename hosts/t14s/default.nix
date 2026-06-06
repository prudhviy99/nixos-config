{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];
  
  systemd.services.tlp.serviceConfig.StandardOutput = "null";
  # ---- Hostname ----
  networking.hostName = "t14s";

  # ADD THIS TO YOUR GLOBAL SYSTEM CONFIGURATION (e.g., configuration.nix)
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };


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
    };
  };
  services.thermald.enable = true;   # Intel thermal management daemon

  # ---- Fingerprint reader (Synaptics WBDI on the T14s Gen 1) ----
  services.fprintd.enable = true;

  # ---- Firmware updates via LVFS (Lenovo pushes BIOS through this) ----
  services.fwupd.enable = true;

  # After first boot, run: fwupdmgr refresh && fwupdmgr update

  # ---- Lid behavior ----
  services.logind.settings.Login = {
    HandleLidSwitch              = "suspend";
    HandleLidSwitchDocked         = "ignore";
    HandleLidSwitchExternalPower  = "suspend";
    HandlePowerKey               = "suspend";
  };
}
