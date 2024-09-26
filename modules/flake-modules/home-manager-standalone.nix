# Home-Manager-Standalone Configuration
/*
  - Returns a Home-Manager configuration
  - It support modifiers(Other flake-modules) for extra features!
*/
flakePath: (
  let

    # Utils
    utils = (import ../nix-modules/collapseAttrs.nix);

    # Gets Only Home-Manager-Standalone Modifiers
    homeManagerStandaloneModifiers = modifiers: (
      builtins.map (value: value.homeManagerStandalone) modifiers
    );

    # Basic Home-Manager Configuration
    homeManagerConfig = systemPackage: architecture: {
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
    homeManagerConfigWithModifiers = systemPackage: architecture: modifiers: (
      utils.collapseAttrs (homeManagerConfig systemPackage architecture) (homeManagerStandaloneModifiers modifiers) {
        modules = [];
        extraSpecialArgs = {};
      }
    );

  in {

    # Builder
    build = { username ? "nixos", package, systemPackage, architecture ? "x86_64-linux", modifiers ? [] }: (
      # Build Home-Manager Configuration
      package.lib.homeManagerConfiguration (homeManagerConfigWithModifiers systemPackage architecture modifiers)
    );

  }
)