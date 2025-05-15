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
          sharedModules = [
            (nixpkgs-lib.evalModules {
              modules = [
                modular-config.homeManagerModules
                ../../public-config/programs/app-store/calibre.home.yo.nix
                ../../public-config/programs/dev-programs.nixos.default.nix
                # ../../users/yo/home.nix
              ];
            }).config.setup.homeConfiguration
            modular-config.homeManagerModules
          ];
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = [
          (nixpkgs-lib.evalModules {
            modules = [
              modular-config.homeManagerModules
              ../../public-config/programs/app-store/calibre.home.yo.nix
              ../../public-config/programs/dev-programs.nixos.default.nix
                # ../../users/yo/home.nix
            ];
          }).config.setup.homeConfiguration
          modular-config.homeManagerModules
        ];
      };

      # Override System Configuration
      nixosSystem = {
        modules = [
          (nixpkgs-lib.evalModules {
            modules = [
              modular-config.nixosModules
              ../../public-config/programs/app-store/calibre.home.yo.nix
              ../../public-config/programs/dev-programs.nixos.default.nix
              {setup.enabledTags = [ "development" ];}
            ];
            specialArgs = {
              pkgs = packages;
            };
          }).config.setup.nixosConfiguration
          modular-config.nixosModules
        ];
      };

    };
  }
)