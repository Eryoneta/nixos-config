# Agenix
# Imports Agenix
flakePath: (
  let

  in {
    # Builder
    build = { architecture ? "x86_64-linux", package }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {};

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