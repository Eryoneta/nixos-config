# Stylix
/*
  - A flake-module modifier
  - Imports Stylix
*/
flakePath: (
  let

  in {
    # Builder
    build = { package }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {};

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = [
          package.homeManagerModules.stylix
        ];
      };

      # Override System Configuration
      nixosSystem = {
        modules = [
          package.nixosModules.stylix
        ];
      };

    };
  }
)