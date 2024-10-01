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
    buildPkgsBundle = architecture: packages: (
      # MapAttrs: { pkgs = pkgs; } -> { pkgs = (import pkgs { ... }); }
      builtins.mapAttrs (
        name: value: (
          if ((builtins.hasAttr "pkgs" value) && (builtins.hasAttr "importPkgs" value)) then (
            # If it has extra atributes
            if (value.importPkgs) then (
              importPkgs value.pkgs architecture
            ) else value.pkgs
          ) else (
            # If it's only the input
            importPkgs value architecture
          )
        )
      ) packages
    );
    importPkgs = input: architecture: (
      import input {
        system = architecture;
        config.allowUnfree = true;
      }
    );

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