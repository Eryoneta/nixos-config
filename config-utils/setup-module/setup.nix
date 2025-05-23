# Setup Configuration
/*
  - A complete modular system, independent from NixOS or Home-Manager
    - Perfect for modularizing the configuration
*/
(
  let

    # Setup Configuration
    setup = (builtins.import ./setup-config.nix);

  in {
    setupSystem = { lib, modules ? [], specialArgs ? {}}: (
      let
        eval = (lib.evalModules { # Evaluation
          modules = [
            setup.homeModules
          ] ++ modules;
          inherit specialArgs;
        });
      in {
        nixosModules.setup = eval.config.nixosConfigurationModules;
        homeManagerModules.setup = eval.config.homeConfigurationModules;
        darwinModules.setup = eval.config.darwinConfigurationModules;
      }
    );
  }
)
