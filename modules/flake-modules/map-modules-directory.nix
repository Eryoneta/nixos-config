# Map Modules Directory
# Defines a "modules" inside "specialArgs" or "extraSpecialArgs" that contains a set of paths
# Is meant to be used as a easy way of setting paths for files inside a given directory
# (Ex.: Given a folder "./modules/feat.nix", then "modules" contains "{ "feat.nix" = /nix/store/.../modules/feat.nix; }")
flakePath: (
  let

    # Utils
    utils = (import ../nix-modules/mapDir.nix);

    # SpecialArg
    specialArg = directory: {
      modules = (utils.mapDir directory);
    };
    
  in {
    # Builder
    build = { directory }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg directory);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg directory);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg directory);
      };

    };
  }
)
