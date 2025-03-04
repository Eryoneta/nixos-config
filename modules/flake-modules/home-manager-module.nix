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
    homeManagerConfig = usernames: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users = (builtins.listToAttrs (builtins.map (
          username: {
            name = username;
            value = (
              let
                configPath = "${flakePath}/home.nix";
              in if (builtins.pathExists configPath) then (import configPath) else ({...}: {})
            );
          }
        ) usernames));
        sharedModules = [];
        extraSpecialArgs = {};
      };
    };

    # Home-Manager Configuration With Modifiers
    homeManagerConfigWithModifiers = usernames: modifiers: (
      collapseAttrs (homeManagerConfig usernames) (homeManagerModuleModifiers modifiers) {
        home-manager = {
          sharedModules = [];
          extraSpecialArgs = {};
        };
      }
    );

  in {
    # Builder
    build = { usernames ? [ "nixos" ], package, modifiers ? [] }: {

      # Override System Configuration
      nixosSystem = {
        modules = [
          # Note: It's two separate items within a list! Not a function!
          package.nixosModules.home-manager
          (homeManagerConfigWithModifiers usernames modifiers)
        ];
      };

    };
  }
)