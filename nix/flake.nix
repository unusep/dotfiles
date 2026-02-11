{
  description = "Deshun's MacOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }:
  let
    user = "deshuncai";
    hostname = "Deshuns-MacBook-Pro";
    system = "aarch64-darwin";
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit user hostname self; };
      modules = [
        ./modules/system.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit user; };
          home-manager.users.${user} = { ... }: {
            imports = [
              ./modules/home-manager.nix
              ./modules/programs/shell.nix
              ./modules/programs/editor.nix
              ./modules/programs/claude-code.nix
              ./modules/programs/aerospace.nix
              ./modules/programs/zellij.nix
              ./modules/programs/ghostty.nix
              ./modules/programs/karabiner.nix
            ];
          };
        }
      ];
    };
  };
}
