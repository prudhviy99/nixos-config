{ config, pkgs, ... }:

{
  # ---- Hyprland Wayland session ----
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;   # for X11 apps (most browsers, electron)
  };

  # ---- Portal: lets sandboxed apps screenshot, screen-share, file-pick ----
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk          # GTK fallback (file pickers, etc.)
    ];
  };

  # ---- Environment hints for Wayland-native apps ----
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";     # tells Chromium/Electron to use Wayland natively
    MOZ_ENABLE_WAYLAND = "1";
  };

  # ---- Login manager: greetd + tuigreet ----
  # Lightweight terminal-based greeter. Picks Hyprland directly, no SDDM bloat.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd 'uwsm start hyprland-uwsm.desktop'";
        user = "greeter";
      };
    };
  };

  # Fingerprint for hyprlock (unlock) and sudo (terminal)
  security.pam.services.sudo.fprintAuth = true;

  # IMPORTANT: keep password login working — do NOT enable fprint on login/greetd.
  # This avoids the known issue where fprint hijacks the password prompt.
  security.pam.services.login.fprintAuth = false;

  # ---- Required system bits for hyprlock to authenticate ----
  security.pam.services.hyprlock = {};

  # ---- GVFS: virtual filesystem backend for Nautilus ----
  # Enables trash, network locations (SFTP/SMB/WebDAV), MTP (Android), etc.
  services.gvfs.enable = true;

  # Gnome Keyring: stores passwords for network shares so you don't re-enter them
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # ---- Polkit agent: prompts for sudo password from GUI apps ----
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
