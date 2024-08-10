flakePath: {

  # Home-Manager-Module Builder
  build = { username ? "nixos", package, modifiers ? [] }: (
    let

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
        # Foldl': [ { ... } { ... } ] -> { ... }
        builtins.foldl' (
          accumulator: modifier: (
            accumulator // (modifier // {
              home-manager = (accumulator.home-manager // (modifier.home-manager // {
                sharedModules = (accumulator.home-manager.sharedModules ++ modifier.home-manager.sharedModules);
                extraSpecialArgs = (accumulator.home-manager.extraSpecialArgs // modifier.home-manager.extraSpecialArgs);
              }));
            })
          )
        ) homeManagerConfig modifiers
      );

    # Override System Configuration
    in {
      modules = [
        # IT'S TWO SEPARATE THINGS??? NOT A FUNCTION CALL???
        package.nixosModules.home-manager homeManagerConfigWithModifiers
      ];
      specialArgs = {};
    }
  );

}