# Plasma-Manager Configuration
/*
  - A flake-module modifier
  - Imports Plasma-Manager as a Home-Manager module
*/
flakePath: (
  let

  in {
    # Builder
    build = { package }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          sharedModules = [
            package.homeManagerModules.plasma-manager
          ];
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = [
          package.homeManagerModules.plasma-manager
        ];
      };

      # Override System Configuration
      nixosSystem = {};

    };
  }
)