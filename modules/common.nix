{ config, pkgs, ... }:

{
  # ---- Bootloader: systemd-boot, EFI ----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---- Networking ----
  networking.networkmanager.enable = true;

  # ---- Locale / time ----
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---- Audio: PipeWire (replaces PulseAudio) ----
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;          # PulseAudio compatibility layer
    jack.enable = true;           # JACK compatibility (audiophile stack)
  };

  # ---- Bluetooth ----
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ---- User account ----
  users.users.fedal = {
    isNormalUser = true;
    description = "Prudhvi";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.zsh;
  };

  # ---- zsh enabled at system level so it's a valid login shell ----
  programs.zsh.enable = true;

  # ---- System-wide packages (keep minimal; user stuff goes in home/) ----
  environment.systemPackages = with pkgs; [
    git           # needed before flake clone
    vim           # emergency editor
    wget
    curl
    pciutils      # lspci, useful for hardware debugging
    usbutils      # lsusb
  ];

  # ---- Enable unfree packages (chromium, 1password, spotify, etc.) ----
  nixpkgs.config.allowUnfree = true;

  # ---- Flakes ----
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ---- Garbage collection: auto-clean old generations after 14 days ----
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ---- stateVersion: DO NOT CHANGE after first install ----
  # It's a compatibility marker, not a "use latest" flag. Set to whatever
  # NixOS version you installed.
  system.stateVersion = "26.05";
}
