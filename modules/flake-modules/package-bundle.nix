# Package-Bundle
# Defines a "pkgs-bundle" inside "specialArgs" or "extraSpecialArgs" that contains a set of packages
#   Allows for accessing packages from a single atribute(Ex: pkgs-bundle.stable and pkgs-bundle.unstable)
# "packages" should be a set containing the ones from the flake-input(Ex.: packages = { inherit stable; inherit unstable; })
#   All that matters is the names
flakePath: (
  let

    # Bundle Builder
    buildPkgsBundle = architecture: packages: (
      # MapAttrs: { pkgs = pkgs; } -> { pkgs = (import pkgs { ... }); }
      builtins.mapAttrs (name: value: (import value (pkgsConfig architecture))) packages
    );
    pkgsConfig = architecture: {
      system = architecture;
      config.allowUnfree = true;
    };

    # SpecialArg
    specialArg = architecture: packages: {
      pkgs-bundle = (buildPkgsBundle architecture packages);
    };

  in {
    # Builder
    build = { architecture ? "x86_64-linux", packages }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg architecture packages);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg architecture packages);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg architecture packages);
      };

    };
  }
)