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

    # Plasma-Manager (AutoUpgrade)
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    # Agenix (AutoUpgrade)
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Stylix (AutoUpgrade)
    stylix.url = "github:danth/stylix/release-24.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";

    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Unstable Packages (Manual Upgrade)
    nixpkgs-unstable-fixed.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Firefox Addons (AutoUpgrade)
    nurpkgs-firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    nurpkgs-firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox: FX-AutoConfig (Manual Upgrade)
    fx-autoconfig.url = "github:MrOtherGuy/fx-autoconfig/master";
    fx-autoconfig.flake = false;

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Imports
      user-host-scheme = (import ./modules/flake-modules/user-host-scheme.nix self.outPath);
      inputsAndExtras = (extraArgs // {

        # NixOS Artwork (Manual Fetch)
        nixos-artwork = architecture: {
          "wallpaper/nix-wallpaper-simple-blue.png" = (
            extraArgs.nixpkgs.legacyPackages.${architecture}.fetchurl {
              url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-simple-blue.png";
              sha256 = "sha256-utrcjzfeJoFOpUbFY2eIUNCKy5rjLt57xIoUUssJmdI=";
            }
          );
        };

      });
      buildConfiguration = (import ./configurationBuilder.nix inputsAndExtras self.outPath);

      # System_Label ([a-zA-Z0-9:_.-]*)
      # I change it at every rebuild. Very convenient for naming generations!
      systemLabel = (
        let
          filePath = ./NIXOS_LABEL.txt;
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
        configFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config";
        configDevFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config-dev"; # Dev folder
      };
      Eryoneta = user-host-scheme.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
        configFolder = "/home/eryoneta/.nixos-config";
      };
      
    in {

      # NixOS + Home-Manager(+ Plasma-Manager + Agenix) + Agenix
      nixosConfigurations = {
        "Yo@LiCo" = (buildConfiguration Yo LiCo).nixosSystemConfig;
        "Yo@HyperV_VM" = (buildConfiguration Yo HyperV_VM).nixosSystemConfig;
        #"Yo@NeLiCo" = (buildConfiguration Yo NeLiCo).nixosSystemConfig;
        #"Eryoneta@NeLiCo" = (buildConfiguration Eryoneta NeLiCo).nixosSystemConfig;
      };
      
      # Home-Manager + Plasma-Manager + Agenix
      homeConfigurations = {
        "Yo@LiCo" = (buildConfiguration Yo LiCo).homeManagerConfig;
        "Yo@HyperV_VM" = (buildConfiguration Yo HyperV_VM).homeManagerConfig;
        #"Yo@NeLiCo" = (buildConfiguration Yo NeLiCo).homeManagerConfig;
        #"Eryoneta@NeLiCo" = (buildConfiguration Eryoneta NeLiCo).homeManagerConfig;
      };

    }
  );
}
