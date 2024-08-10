flakePath: (
  let

    # List Builder
    buildList = packages: (
      # AttrNames: { pkgs = pkgs; } -> { pkgs = (import pkgs { ... }); }
      builtins.attrNames packages
    );

  in {
    # Auto-Upgrade-List Builder
    buildFor = (
      let
        specialArg = packages: {
          auto-upgrade-pkgs = (buildList packages);
        };
      in {

        # Override Home-Manager-Module Configuration
        homeManagerModule = { packages }: {
          home-manager = {
            sharedModules = [];
            extraSpecialArgs = (specialArg packages);
          };
        };

        # Override Home-Manager-Standalone Configuration
        homeManagerStandalone = { packages }: {
          modules = [];
          extraSpecialArgs = (specialArg packages);
        };

        # Override System Configuration
        nixosSystem = { packages }: {
          modules = [];
          specialArgs = (specialArg packages);
        };

      }
    );

  }
)
