# Basic NixOS Configuration
# Returns a simple NixOS configuration
# But it support modifiers(Other flake-modules) for extra features!
flakePath: (
  let

    # Utils
    utils = (import ../nix-modules/collapseAttrs.nix);

    # Gets Only NixOS Modifiers
    nixosSystemModifiers = modifiers: (
      builtins.map (value: value.nixosSystem) modifiers
    );

    # Basic System Configuration
    systemConfig = architecture: {
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
    systemConfigWithModifiers = architecture: modifiers: (
      utils.collapseAttrs (systemConfig architecture) (nixosSystemModifiers modifiers) {
        modules = [];
        specialArgs = {};
      }
    );

  in {

    # Builder
    build = { architecture ? "x86_64-linux", package, modifiers ? [] }: (
      # Build System
      package.lib.nixosSystem (systemConfigWithModifiers architecture modifiers)
    );

  }
)