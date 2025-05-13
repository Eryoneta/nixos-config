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
    build = {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          sharedModules = [
            modular-config.homeManagerModules
          ];
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = [
          modular-config.homeManagerModules
        ];
      };

      # Override System Configuration
      nixosSystem = {
        modules = [
          modular-config.nixosModules
        ];
      };

    };
  }
)