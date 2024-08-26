# Map Modules Directory
# Defines a "modules" inside "specialArgs" or "extraSpecialArgs" that contains a set of paths
# Is meant to be used as a easy way of setting paths for files inside a given directory
# (Ex.: Given a folder "./modules/feat.nix", then "modules" contains "{ "feat.nix" = /nix/store/.../modules/feat.nix; }")
flakePath: (
  let

    # Utils
    utils = (import ../nix-modules/mapDir.nix);
    
  in {
    # Builder
    buildFor = (
      let
        specialArg = directory: {
          modules = (utils.mapDir directory);
        };
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = { directory }: {
          home-manager = {
            extraSpecialArgs = (specialArg directory);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { directory }: {
          extraSpecialArgs = (specialArg directory);
        };

        # Override System Configuration
        nixosSystem = { directory }: {
          specialArgs = (specialArg directory);
        };

      }
    );

  }
)
