{ inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (inputs.nixpkgs.legacyPackages.x86_64-linux.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs.overlays = [ (final: prev: {
    claude-code = unstable.claude-code;
    codex = inputs.codex-cli-nix.packages.${prev.stdenv.hostPlatform.system}.default;
}) ];
}
