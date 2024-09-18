{
  # Description
  description = "Yo Flake";

  # Inputs
  inputs = {

    # NixOS (AutoUpgrade)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home-Manager (AutoUpgrade)
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Agenix (AutoUpgrade)
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Unstable Packages (Manual Upgrade)
    nixpkgs-unstable-fixed.url = "github:NixOS/nixpkgs/nixos-unstable";

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Imports
      buildConfiguration = (import ./configurationBuilder.nix extraArgs self.outPath);
      user-host-scheme = (import ./modules/flake-modules/user-host-scheme.nix self.outPath);

      # System_Label ([a-zA-Z0-9:_.-]*)
      # I change it at every rebuild. Very convenient for marking generations!
      # But it might contain sensitive information, so its hidden
      systemLabel = (
        let
          filePath = ./private-config/NIXOS_LABEL.txt;
        in if (builtins.pathExists filePath) then (
          builtins.readFile filePath
        ) else "Initial Configuration: Requires private-config to be complete"
      );

      # Hosts
      LiCo = user-host-scheme.buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = systemLabel; 
      };
      NeLiCo = user-host-scheme.buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = systemLabel;
      };
      HyperV_VM = user-host-scheme.buildHost {
        hostname = "hyper-v_vm";
        name = "HyperV_VM";
        system.label = systemLabel;
      };

      # Users
      Yo = user-host-scheme.buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
        configDevFolder = "/home/yo/Utilities/SystemConfig/nixos-config-dev"; # Dev folder
      };
      Eryoneta = user-host-scheme.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
        configFolder = "/home/eryoneta/.nixos-config";
      };
      
    in {

      # NixOS + Home-Manager + Agenix
      nixosConfigurations = {
        "Yo@LiCo" = (buildConfiguration Yo LiCo).nixosSystemConfig;
        "Yo@HyperV_VM" = (buildConfiguration Yo HyperV_VM).nixosSystemConfig;
        #"Yo@NeLiCo" = (buildConfiguration Yo NeLiCo).nixosSystemConfig;
        #"Eryoneta@NeLiCo" = (buildConfiguration Eryoneta NeLiCo).nixosSystemConfig;
      };
      
      # Home-Manager + Agenix
      homeConfigurations = {
        "Yo@LiCo" = (buildConfiguration Yo LiCo).homeManagerConfig;
        "Yo@HyperV_VM" = (buildConfiguration Yo HyperV_VM).homeManagerConfig;
        #"Yo@NeLiCo" = (buildConfiguration Yo NeLiCo).homeManagerConfig;
        #"Eryoneta@NeLiCo" = (buildConfiguration Eryoneta NeLiCo).homeManagerConfig;
      };

    }
  );
}
