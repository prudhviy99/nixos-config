nixpkgs.overlays = [ (final: prev: {
  claude-code = (import inputs.nixpkgs-unstable {
    inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  }).claude-code;
}) ];
