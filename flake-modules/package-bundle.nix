# Package-Bundle for AutoUpgrade
# Defines a "pkgs-bundle" inside "specialArgs" or "extraSpecialArgs" that contains a set of packages
# Allows for getting packages from multiple inputs(Ex: Stable and Unstable)
# "packages" should be a set containing the ones from the flake-input(Ex.: packages = { inherit stable; inherit unstable; })
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

  in {
    # Package-Bundle Builder
    buildFor = (
      let
        specialArg = architecture: packages: {
          pkgs-bundle = (buildPkgsBundle architecture packages);
        };
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = { architecture ? "x86_64-linux", packages }: {
          home-manager = {
            extraSpecialArgs = (specialArg architecture packages);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { architecture ? "x86_64-linux", packages }: {
          extraSpecialArgs = (specialArg architecture packages);
        };

        # Override System Configuration
        nixosSystem = { architecture ? "x86_64-linux", packages }: {
          specialArgs = (specialArg architecture packages);
        };

      }
    );

  }
)
