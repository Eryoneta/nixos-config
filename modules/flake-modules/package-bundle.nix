# Package-Bundle
/*
  - A flake-module modifier
  - Defines a "pkgs-bundle" inside "specialArgs" or "extraSpecialArgs"
    - It contains a set of packages
    - Its convenient as all packages can be taken from one single atribute
      - Ex: ''
        { pkgs-bundle, ...}: {
          # ...
          environment.systemPackages = with pkgs-bundle; [
            unstable.home-manager
            stable.git
          ];
          # ...
        }
      ''
  - "packages" should be a set containing the ones from "inputs"
    - Ex.: "packages = { stable = nixpkgs-stable; unstable = nixpkgs-unstable; }"
    - They should not be imported! All that matters are its names
*/
flakePath: (
  let

    # Bundle Builder
    buildPkgsBundle = architecture: autoImportPackages: packages: (
      packages // (
        # MapAttrs: { pkgs = pkgs; } -> { pkgs = (import pkgs { ... }); }
        builtins.mapAttrs (
          name: value: (
            autoImportPkgs value architecture
          )
        ) autoImportPackages
      )
    );
    autoImportPkgs = input: architecture: (
      import input {
        system = architecture;
        config.allowUnfree = true;
      }
    );

    # SpecialArg
    specialArg = architecture: autoImportPackages: packages: {
      pkgs-bundle = (buildPkgsBundle architecture autoImportPackages packages);
    };

  in {
    # Builder
    build = { architecture ? "x86_64-linux", autoImportPackages, packages }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg architecture autoImportPackages packages);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg architecture autoImportPackages packages);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg architecture autoImportPackages packages);
      };

    };
  }
)