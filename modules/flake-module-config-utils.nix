# Configuration-Utilities
# Defines a "config-utils" inside "specialArgs" or "extraSpecialArgs" that contains useful functions
#   Allows for easier coding
flakePath: (
  let

    # SpecialArg
    specialArg = nix-lib: hm-pkgs: hm-lib: {
      config-utils = (import ./config-utils.nix nix-lib hm-pkgs hm-lib);
    };

  in {
    # Builder
    build = { nixpkgs-lib, home-manager-pkgs, home-manager-lib }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg nixpkgs-lib home-manager-pkgs home-manager-lib);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg nixpkgs-lib home-manager-pkgs home-manager-lib);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg nixpkgs-lib home-manager-pkgs home-manager-lib);
      };

    };
  }
)