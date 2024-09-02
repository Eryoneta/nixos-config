# Home-Manager-Module
# Puts a home-manager-module inside a NixOS configuration
# It support modifiers(Other flake-modules) for extra features
flakePath: (
  let

    # Utils
    utils = (import ../nix-modules/collapseAttrs.nix);

    # Gets Only Home-Manager-Module Modifiers
    homeManagerModuleModifiers = modifiers: (
      builtins.map (value: value.homeManagerModule) modifiers
    );

    # Basic Home-Manager Configuration
    homeManagerConfig = username: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = (
          let
            configPath = "${flakePath}/home.nix";
          in
            if (builtins.pathExists configPath) then (import configPath) else ({ ... }: {})
        );
        sharedModules = [];
        extraSpecialArgs = {};
      };
    };

    # Home-Manager Configuration With Modifiers
    homeManagerConfigWithModifiers = username: modifiers: (
      utils.collapseAttrs (homeManagerConfig username) (homeManagerModuleModifiers modifiers) {
        home-manager = {
          sharedModules = [];
          extraSpecialArgs = {};
        };
      }
    );

  in {
    # Builder
    build = { username ? "nixos", package, modifiers ? [] }: {

      # Override System Configuration
      nixosSystem = {
        modules = [
          # IT'S TWO SEPARATE THINGS??? NOT A FUNCTION CALL???
          package.nixosModules.home-manager (homeManagerConfigWithModifiers username modifiers)
        ];
      };

    };
  }
)