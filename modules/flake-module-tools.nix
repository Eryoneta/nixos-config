# Inputs as Arguments
# Defines a "inputs" inside "specialArgs" or "extraSpecialArgs" that contains "flake.inputs"
#   Allows for accessing inputs wherever necessary





flakePath: (
  let

    # SpecialArg
    specialArg = nix-lib: pkgs: hm-lib: {
      tools = (import ./tools.nix nix-lib pkgs hm-lib);
    };

  in {
    # Builder
    build = { nixpkgs-lib, pkgs, home-manager-lib }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg nixpkgs-lib pkgs home-manager-lib);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg nixpkgs-lib pkgs home-manager-lib);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg nixpkgs-lib pkgs home-manager-lib);
      };

    };
  }
)