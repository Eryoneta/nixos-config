# Home-Manager-Module
/*
  - A flake-module modifier
    - It also supports other modifiers(Other flake-modules) for extra features!
  - Imports Home-Manager as a NixOS module
*/
flakePath: (
  let

    # CollapseAttrs
    collapseAttrs = (import ../nix-modules/collapseAttrs.nix).collapseAttrs;

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
      collapseAttrs (homeManagerConfig username) (homeManagerModuleModifiers modifiers) {
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