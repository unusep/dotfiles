{
  description = "Deshun's MacOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    claude-code.url = "github:sadjow/claude-code-nix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, claude-code, rust-overlay, nix-homebrew, ... }:
  let
    user = builtins.getEnv "SUDO_USER";
    hostname = builtins.getEnv "HOSTNAME";
    system = "aarch64-darwin";
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit user hostname self; };
      modules = [
        { nixpkgs.overlays = [ claude-code.overlays.default rust-overlay.overlays.default ]; }
        ./modules/system.nix
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = user;
            autoMigrate = true;
          };
        }

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
              ./modules/programs/claude-tmux-bridge.nix
              ./modules/programs/aerospace.nix
              ./modules/programs/cmux.nix
              ./modules/programs/ghostty.nix
              ./modules/programs/karabiner.nix

              ./modules/programs/hrm.nix
              ./modules/programs/git.nix
              ./modules/programs/gh.nix

            ];
          };
        }
      ];
    };
  };
}
