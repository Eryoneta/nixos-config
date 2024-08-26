# Home-Manager-Standalone Configuration
# Returns a Home-Manager configuration
# It support modifiers(Other flake-modules) for extra features
flakePath: {

  # Home-Manager-Standalone Builder
  build = { username ? "nixos", package, systemPackage, architecture ? "x86_64-linux", modifiers ? [] }: (
    let
    
      # Utils
      utils = (import ../nix-modules/collapseAttrs.nix);

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
        utils.collapseAttrs homeManagerConfig modifiers {
          modules = [];
          extraSpecialArgs = {};
        }
      );

    in (
      # Build Home-Manager Configuration
      package.lib.homeManagerConfiguration homeManagerConfigWithModifiers
    )
  );

}
