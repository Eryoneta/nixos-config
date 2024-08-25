# Home-Manager-Standalone Configuration
# Returns a Home-Manager configuration
# It support modifiers(Other flake-modules) for extra features
flakePath: {

  # Home-Manager-Standalone Builder
  build = { username ? "nixos", package, systemPackage, architecture ? "x86_64-linux", modifiers ? [] }: (
    let

      # Basic Home-Manager Configuration
      homeManagerConfig = {
        pkgs = systemPackage.legacyPackages.${architecture};
        modules = (
          let
            configPath = "${flakePath}/home.nix";
          in
            if (builtins.pathExists configPath) then [ configPath ] else []
        );
        extraSpecialArgs = {};
      };

      # Home-Manager Configuration With Modifiers
      homeManagerConfigWithModifiers = (
        # Foldl': [ { ... } { ... } ] -> { ... }
        builtins.foldl' (
          accumulator: modifier: (
            accumulator // (modifier // {
              modules = (accumulator.modules ++ modifier.modules);
              extraSpecialArgs = (accumulator.extraSpecialArgs // modifier.extraSpecialArgs);
            })
          )
        ) homeManagerConfig modifiers
      );

    in (
      # Build Home-Manager Configuration
      package.lib.homeManagerConfiguration homeManagerConfigWithModifiers
    )
  );

}
