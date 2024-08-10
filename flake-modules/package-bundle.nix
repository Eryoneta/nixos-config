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
            sharedModules = [];
            extraSpecialArgs = (specialArg architecture packages);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { architecture ? "x86_64-linux", packages }: {
          modules = [];
          extraSpecialArgs = (specialArg architecture packages);
        };

        # Override System Configuration
        nixosSystem = { architecture ? "x86_64-linux", packages }: {
          modules = [];
          specialArgs = (specialArg architecture packages);
        };

      }
    );

  }
)
