# Link to Source-Configuration
/*
  - Creates a symlink for the configuration present inside "/nix/store"
    - Its named "src"
    - It can be accessed at "/run/current-system/src"
*/
{ config, lib, ... }:
  let
    cfg = config.system.linkToSourceConfiguration;
  in {

    options = {
      system.linkToSourceConfiguration = {

        enable = lib.mkEnableOption ''
          Enables the creation of a symlink for the current configuration at `/run/current-system/src`.
        '';

        configurationPath = lib.mkOption {
          type = lib.types.path;
          description = ''
            The path for the configuration.

            It can be a path for a user domain ('/home/user/myConfiguration'), but a '/nix/store' path is recommended

            The path for the 'nix/store' can be obtained with `./.` or `self.outPath`.
          '';
        };

      };
    };

    config = lib.mkIf (cfg.enable) {

      assertions = [
        {
          assertion = !(cfg.configurationPath == "");
          message = ''
            The option 'system.linkToSourceConfiguration.configurationPath' cannot be empty
          '';
        }
      ];

      # Link to source configuration
      # Available at "/run/current-system/src"
      system.extraSystemBuilderCmds = "ln -s ${cfg.configurationPath} $out/src";

    };
  }
