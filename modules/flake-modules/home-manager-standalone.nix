# Home-Manager-Standalone Configuration
/*
  - Returns a Home-Manager configuration
  - It support modifiers(Other flake-modules) for extra features!
*/
flakePath: (
  let

    # CollapseAttrs
    collapseAttrs = (import ../nix-modules/collapseAttrs.nix).collapseAttrs;

    # Gets Only Home-Manager-Standalone Modifiers
    homeManagerStandaloneModifiers = username: modifiers: (
      builtins.map (value: (
        if(builtins.isFunction value.homeManagerStandalone) then (
          value.homeManagerStandalone username
        ) else value.homeManagerStandalone
      )) modifiers
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
    homeManagerConfigWithModifiers = systemPackage: architecture: username: modifiers: (
      collapseAttrs (homeManagerConfig systemPackage architecture) (homeManagerStandaloneModifiers username modifiers) {
        modules = [];
        extraSpecialArgs = {};
      }
    );

  in {

    # Builder
    build = { username ? "nixos", package, systemPackage, architecture ? "x86_64-linux", modifiers ? [] }: (
      # Build Home-Manager Configuration
      package.lib.homeManagerConfiguration (homeManagerConfigWithModifiers systemPackage architecture username modifiers)
    );

  }
)