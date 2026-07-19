{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ../../modules/zram.nix ../../modules/overlays.nix];

  networking.hostName = "desktop";

  # ADD THIS TO YOUR GLOBAL SYSTEM CONFIGURATION (e.g., configuration.nix)
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # --- Remote access: SSH + Ollama from other devices on the LAN ---
  # Only reachable on the local network — no router port-forwarding involved.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Runs ollama as a systemd service (auto-starts on boot, restarts on crash)
  # instead of needing `ollama serve` run manually every time.
  services.ollama = {
    enable = true;
    host = "0.0.0.0"; # listen on all interfaces so LAN devices can reach it, not just localhost
    port = 11434;
    package = pkgs.ollama-cuda; # use the RTX 5080
    openFirewall = true;
  };


  # --- Bootloader (only if your modules/common.nix doesn't already set one) ---
  # If common.nix already enables systemd-boot, DELETE this block to avoid a clash.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- RTX 5080 (Blackwell): OPEN modules are mandatory ---
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;            # 32-bit libs for Steam / Wine / Elden Ring etc.
  };

  hardware.nvidia = {
    open = true;                   # MANDATORY for Blackwell — proprietary modules don't support it
    modesetting.enable = true;     # required for Wayland; adds nvidia-drm.modeset=1 for you
    nvidiaSettings = true;
    powerManagement.enable = true;
    # Pick a package the 5080 supports. beta/latest are safest for a new card.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # --- Wayland / Electron / hardware video decode ---
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";          # runs Electron/Chromium (Discord, VSCode) natively on Wayland -> clean screenshare
    LIBVA_DRIVER_NAME = "nvidia";  # VA-API decode through nvidia
  };

  # --- Firmware for webcams and other USB peripherals ---
  hardware.enableRedistributableFirmware = true;

  # --- Desktop apps ---
  environment.systemPackages = with pkgs; [
    discord
    pavucontrol      # pick the Topping DAC as default sink/source
    wl-clipboard
  ];
}
