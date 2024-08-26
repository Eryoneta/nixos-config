# Basic NixOS Configuration
# Returns a simple NixOS configuration
# But it support modifiers(Other flake-modules) for extra features!
flakePath: {

  # Builder
  build = { architecture ? "x86_64-linux", package, modifiers ? [] }: (
    let

      # Utils
      utils = (import ../nix-modules/collapseAttrs.nix);

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
        utils.collapseAttrs systemConfig modifiers {
          modules = [];
          specialArgs = {};
        }
      );

    in (
      # Build System
      package.lib.nixosSystem systemConfigWithModifiers
    )
  );

}