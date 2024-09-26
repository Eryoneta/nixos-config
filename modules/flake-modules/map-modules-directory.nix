# Map Modules Directory
/*
  - A flake-module modifier
  - Defines a "modules" inside "specialArgs" or "extraSpecialArgs"
    - It contains a set of paths of a given directory
    - Its meant to be used as a easy way of setting paths for files
    - Better than using relative paths!
  - Ex.: Given "directory = ./modules/feat.nix", then "modules" contains: ''
    {
      "feat1.nix" = /nix/store/.../modules/feat1.nix;
      subDir = {
        "feat2.nix" = /nix/store/.../modules/subDir/feat2.nix;
      };
    }
  ''
    - Ex.: ''
        { modules, ...}: {
          imports = [
            modules."feat1.nix"
            modules.subDir."feat2.nix"
          ]
          # ...
        }
      ''
*/
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
