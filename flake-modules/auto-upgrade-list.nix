# AutoUpgrade List
# Defines a "auto-upgrade-list" inside "specialArgs" or "extraSpecialArgs" that contains a list of inputs to autoupgrade
# It's a convenience! The "flake.nix" itself can set what inputs should be autoupgraded and "config.system.autoUpgrade" just uses the list
# "packages" should be a set containing the ones from the flake-input(Ex.: packages = { inherit stable; inherit unstable; })
# All that matters is the names
flakePath: (
  let

    # List Builder
    buildList = packages: (
      # AttrNames: { pkgs = ...; } -> [ "pkgs" ]
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
