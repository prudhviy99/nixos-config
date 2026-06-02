{
  description = "Prudhvi's NixOS config";

  inputs = {
    # nixpkgs: the package set. Using unstable because Hyprland and Ghostty
    # move fast and the stable channel lags. Swap to "nixos-25.11" later if
    # you want to trade fresh packages for stability.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager: user-environment manager.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";   # use the same nixpkgs, not its own
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    # One entry per host. Add hosts.desktop later.
    nixosConfigurations.t14s = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/t14s
        ./modules/common.nix
        ./modules/hyprland.nix
        ./modules/fonts.nix

        # Wire home-manager into the NixOS build
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.fedal = import ./home/fedal.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
