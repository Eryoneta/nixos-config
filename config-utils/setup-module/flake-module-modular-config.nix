# Modular Configuration
/*
  - A flake-module modifier
  - Adds new options in "config.setup"
    - Perfect for modularizing the configuration
*/
flakePath: (
  let

    # Modular Configuration
    modular-config = (import ../nixos-modules/modular-config.nix);

  in {
    # Builder
    build = { nixpkgs-lib, packages }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          sharedModules = (nixpkgs-lib.evalModules {
            modules = [
              modular-config.homeModules
            # ../../public-config/programs/app-store/calibre.setup.nix
            ../../public-config/programs/dev-programs.setup.nix
            { config.enabledTags = [ "yo" ]; }
            ];
          }).config.homeConfigurationModules;
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = (nixpkgs-lib.evalModules {
          modules = [
            modular-config.homeModules
            # ../../public-config/programs/app-store/calibre.setup.nix
            ../../public-config/programs/dev-programs.setup.nix
            { config.enabledTags = [ "yo" ]; }
          ];
        }).config.homeConfigurationModules;
      };

      # Override System Configuration
      nixosSystem = {
        modules = (nixpkgs-lib.evalModules {
          modules = [
            modular-config.nixosModules
            # ../../public-config/programs/app-store/calibre.setup.nix
            ../../public-config/programs/dev-programs.setup.nix
            { config.enabledTags = [ "development" ]; }
          ];
          specialArgs = {
            pkgs = packages;
          };
        }).config.nixosConfigurationModules;
      };

    };
  }
)