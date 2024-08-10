flakePath: {

  # System Builder
  build = { architecture ? "x86_64-linux", package, modifiers ? [] }: (
    let

      # Basic System Configuration
      systemConfig = {
        system = architecture;
        modules = (
          let
            configPath = "${flakePath}/configuration.nix";
          in
            if (builtins.pathExists configPath) then [ configPath ] else []
        );
        specialArgs = {};
      };

      # System Configuration With Modifiers
      systemConfigWithModifiers = (
        # Foldl': [ { ... } { ... } ] -> { ... }
        builtins.foldl' (
          accumulator: modifier: (
            accumulator // (modifier // {
              modules = (accumulator.modules ++ modifier.modules);
              specialArgs = (accumulator.specialArgs // modifier.specialArgs);
            })
          )
        ) systemConfig modifiers
      );

    in (
      # Build System
      package.lib.nixosSystem systemConfigWithModifiers
    )
  );

}