# Tools
# Defines a "tools" inside "specialArgs" or "extraSpecialArgs" that contains useful functions
#   Allows for easier coding
flakePath: (
  let

    # SpecialArg
    specialArg = nix-lib: hm-pkgs: hm-lib: {
      tools = (import ./tools.nix nix-lib hm-pkgs hm-lib);
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