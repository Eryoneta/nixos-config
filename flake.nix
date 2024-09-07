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

    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Unstable Packages (Manual Upgrade)
    nixpkgs-unstable-fixed.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Agenix
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Imports
      nix-lib = extraArgs.nixpkgs.lib;
      nix-utils = (
        let
          path = ./modules/nix-modules;
        in (import "${path}/mapDir.nix") // (import "${path}/formatStr.nix" nix-lib)
      );
      flake-modules = (
        # MapAttrs: { "feat.nix" = ./.../feat.nix; } -> { "feat.nix" = (import ./.../feat.nix self.outPath); }
        builtins.mapAttrs (
          name: value: (import value self.outPath)
        ) (nix-utils.mapDir ./modules/flake-modules)
      );

      # System_Label
      systemLabel = (nix-utils.formatStr (builtins.readFile ./NIXOS_LABEL.txt));

      # Hosts
      LiCo = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = systemLabel; #[a-zA-Z0-9:_.-]*
      };
      NeLiCo = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = systemLabel; #[a-zA-Z0-9:_.-]*
      };
      HyperV_VM = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "hyper-v_vm";
        name = "HyperV_VM";
        system.label = systemLabel; #[a-zA-Z0-9:_.-]*
      };

      # Users
      Yo = flake-modules."user-host-scheme.nix".buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
        configDevFolder = "/home/yo/Utilities/SystemConfig/nixos-config-dev"; # Dev folder
      };
      Eryoneta = flake-modules."user-host-scheme.nix".buildUser {
        username = "eryoneta";
        name = "Eryoneta";
        configFolder = "/home/eryoneta/.nixos-config";
      };

      # Common Configurations
      buildCommonConfig = user: host: (
        let

          # Common Modifiers
          commonModifiers = [
            # User-Host-Scheme
            (flake-modules."user-host-scheme.nix".build {
              inherit user;
              inherit host;
            })
            # Pkgs-Bundle
            (flake-modules."package-bundle.nix".build {
              architecture = host.system.architecture;
              packages = (with extraArgs; {
                stable = nixpkgs-stable;
                unstable = nixpkgs-unstable;
                unstable-fixed = nixpkgs-unstable-fixed;
              });
            })
            # Public-Private-Zones
            (flake-modules."public-private-domains.nix".build {
              # Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
              # But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
              # Important: That only affects dotfiles! Only absolute paths notices the dev folder
              configPath = if (user.username == "yo") then user.configDevFolder else user.configFolder;
              # configPath = user.configFolder;
              folders = {
                dotfiles = "/dotfiles";
                programs = "/programs";
                resources = "/resources";
                secrets = "/secrets";
              };
              absolutePaths.dotfiles = true;
            })
            # Map-Modules-Dir
            (flake-modules."map-modules-directory.nix".build {
              directory = ./modules;
            })
          ];

        in {

          # Common NixOS Configuration
          nixosSystemConfig = (
            # NixOS-System
            flake-modules."nixos-system.nix".build {
              architecture = host.system.architecture;
              package = extraArgs.nixpkgs;
              modifiers = commonModifiers ++ [
                # Home-Manager-Module
                (flake-modules."home-manager-module.nix".build {
                  username = user.username;
                  package = extraArgs.home-manager;
                  modifiers = commonModifiers;
                })
                # Auto-Upgrade-List
                (flake-modules."auto-upgrade-list.nix".build {
                  packages = (with extraArgs; {
                    inherit nixpkgs;
                    inherit home-manager;
                    inherit nixpkgs-stable;
                    inherit nixpkgs-unstable;
                    # inherit nixpkgs-unstable-fixed;
                  });
                })
                # Agenix
                (flake-modules."agenix.nix".build {
                  architecture = host.system.architecture;
                  package = extraArgs.agenix;
                })
              ];
            }
          );

          # Common Home-Manager Configuration
          homeManagerConfig = (
            # Home-Manager-Standalone
            flake-modules."home-manager-standalone.nix".build {
              package = extraArgs.home-manager;
              systemPackage = extraArgs.nixpkgs;
              username = user.username;
              modifiers = commonModifiers ++ [
                # Agenix
                (flake-modules."agenix.nix".build {
                  architecture = host.system.architecture;
                  package = extraArgs.agenix;
                })
              ];
            }
          );

        }
      );
      
    in {

      # NixOS + Home-Manager
      nixosConfigurations = {
        "Yo@LiCo" = (buildCommonConfig Yo LiCo).nixosSystemConfig;
        "Yo@HyperV_VM" = (buildCommonConfig Yo HyperV_VM).nixosSystemConfig;
        #"Yo@NeLiCo" = (buildCommonConfig Yo NeLiCo).nixosSystemConfig;
        #"Eryoneta@NeLiCo" = (buildCommonConfig Eryoneta NeLiCo).nixosSystemConfig;
      };
      
      # Home-Manager
      homeConfigurations = {
        "Yo@LiCo" = (buildCommonConfig Yo LiCo).homeManagerConfig;
        "Yo@HyperV_VM" = (buildCommonConfig Yo HyperV_VM).homeManagerConfig;
        #"Yo@NeLiCo" = (buildCommonConfig Yo NeLiCo).homeManagerConfig;
        #"Eryoneta@NeLiCo" = (buildCommonConfig Eryoneta NeLiCo).homeManagerConfig;
      };

    }
  );
}
