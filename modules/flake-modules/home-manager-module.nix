# Home-Manager-Module
# Puts a home-manager-module inside a NixOS configuration
# It support modifiers(Other flake-modules) for extra features
flakePath: {

  # Builder
  build = { username ? "nixos", package, modifiers ? [] }: (
    let
    
      # Utils
      utils = (import ../nix-modules/collapseAttrs.nix);

      # Basic Home-Manager Configuration
      homeManagerConfig = {
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
      homeManagerConfigWithModifiers = (
        utils.collapseAttrs homeManagerConfig modifiers {
          home-manager = {
            sharedModules = [];
            extraSpecialArgs = {};
          };
        }
      );

    # Override System Configuration
    in {
      modules = [
        # IT'S TWO SEPARATE THINGS??? NOT A FUNCTION CALL???
        package.nixosModules.home-manager homeManagerConfigWithModifiers
      ];
    }
  );

}