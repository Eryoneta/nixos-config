# Agenix
/*
  - A flake-module modifier
  - Imports Agenix
    - At system level, it also includes "Agenix CLI"
*/
flakePath: (
  let

  in {
    # Builder
    build = { architecture ? "x86_64-linux", package }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          sharedModules = [
            package.homeManagerModules.default
          ];
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        modules = [
          package.homeManagerModules.default
        ];
      };

      # Override System Configuration
      nixosSystem = {
        modules = [
          # Agenix
          package.nixosModules.default
          # Agenix CLI
          {
            config = {
              environment.systemPackages = [
                package.packages.${architecture}.default
              ];
            };
          }
        ];
      };

    };
  }
)