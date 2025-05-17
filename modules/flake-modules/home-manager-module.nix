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
        useGlobalPkgs = false; # Ignore system nixpkgs configuration. Every one is configured separately
        useUserPackages = true; # Save user packages in "/etc/profiles/per-user/$USERNAME" if it's already present in the system ("/etc/profiles/")
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
    build = { systemPackage, architecture ? "x86_64-linux", usernames ? [ "nixos" ], package, modifiers ? [] }: {

      # Override System Configuration
      nixosSystem = {
        modules = [
          # Note: It's two separate items within a list! Not a function!
          package.nixosModules.home-manager
          (homeManagerConfigWithModifiers usernames modifiers)
          {
            home-manager = {
              extraSpecialArgs = {
                pkgs = import systemPackage { # Replace "pkgs" with a custom one
                  system = architecture;
                  config.allowUnfree = true;
                };
                # Note: Not exactly a good idea...! But it works!
                #   This allows all home-manager modules to use a different package from the system
                #   Kernel and KDE Plasma are defined by NixOS. Nearly all apps are defined by Home-Manager
                #   Both can use a different version of nixpkgs now
                #   Evaluation time is doubled, lol
              };
            };
          }
        ];
      };

    };
  }
)