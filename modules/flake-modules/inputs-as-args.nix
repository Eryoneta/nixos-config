# Inputs as Arguments
/*
  - A flake-module modifier
  - Defines a "inputs" inside "specialArgs" or "extraSpecialArgs"
    - It contains "flake.inputs"
    - Allows for accessing inputs wherever necessary
*/
flakePath: (
  let

    # SpecialArg
    specialArg = inputs: {
      inherit inputs;
    };

  in {
    # Builder
    build = { inputs }: {

      # Override Home-Manager-Module Configuration
      homeManagerModule = {
        home-manager = {
          extraSpecialArgs = (specialArg inputs);
        };
      };

      # Override Home-Manager-Standalone Configuration
      homeManagerStandalone = {
        extraSpecialArgs = (specialArg inputs);
      };

      # Override System Configuration
      nixosSystem = {
        specialArgs = (specialArg inputs);
      };

    };
  }
)