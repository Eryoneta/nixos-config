# AutoUpgrade List
# Defines a "auto-upgrade-list" inside "specialArgs" or "extraSpecialArgs" that contains a list of inputs to autoupgrade
#   It's a convenience! The "flake.nix" itself can set what inputs should be autoupgraded and "config.system.autoUpgrade" just uses the list
# "packages" should be a set containing the ones from the flake-input(Ex.: packages = { inherit stable; inherit unstable; })
#   All that matters is the names
flakePath: (
  let

    # List Builder
    buildList = packages: (
      # AttrNames: { pkgs = ...; } -> [ "pkgs" ]
      builtins.attrNames packages
    );

    # SpecialArg
    specialArg = packages: {
      auto-upgrade-pkgs = (buildList packages);
    };

  in {
    # Builder
    build = { packages }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg packages);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg packages);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg packages);
      };

    };
  }
)
