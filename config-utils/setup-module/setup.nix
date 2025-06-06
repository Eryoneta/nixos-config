# Setup Configuration
/*
  - A complete modular system, independent from NixOS or Home-Manager
    - Perfect for modularizing the configuration
*/
{ # (A Module)
  setupSystem = { lib, modules ? [], specialArgs ? {}}: (
    let
      eval = (lib.evalModules { # Evaluation
        modules = [
          ./setup-config.nix
        ] ++ modules;
        inherit specialArgs;
      });
    in {
      nixosModules.setup = { # (NixOS Module)
        imports = eval.config.nixosConfigurationModules;
      };
      homeModules.setup = { # (Home-Manager Module)
        imports = eval.config.homeConfigurationModules;
      };
      darwinModules.setup = { # (Darwin Module)
        imports = eval.config.darwinConfigurationModules;
      };
    }
  );
}
