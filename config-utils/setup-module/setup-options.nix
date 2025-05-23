{ lib, ... }: { # (Setup-Module)
  options = {

      # Tags
      enabledTags = lib.mkOption {
        type = (lib.types.listOf (lib.types.str));
        default = [];
        description = ''
          FINAL-TAGS
        '';
        example = ''
          EXAMPLE
        '';
      };

      # NixOS system config
      nixosConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          ATTRS
        '';
      };

      # Home-Manager system config
      homeConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          ATTRS
        '';
      };

      # Darwin system config
      darwinConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          ATTRS
        '';
      };

      # Modules
      modules = lib.mkOption {
        type = (lib.types.attrsOf (lib.types.submodule {
          options = {

            # Module enabler
            enabled = lib.mkOption {
              type = (lib.types.bool);
              default = true;
              description = ''
                ENABLE
              '';
              example = ''
                EXAMPLE
              '';
            };

            # Module includer
            included = lib.mkOption {
              type = (lib.types.nullOr (lib.types.bool));
              default = null;
              description = ''
                TAGS
              '';
              example = ''
                EXAMPLE
              '';
            };

            # Module tags
            tags = lib.mkOption {
              type = (lib.types.listOf (lib.types.str));
              default = [];
              description = ''
                TAGS
              '';
              example = ''
                EXAMPLE
              '';
            };

            # Module attributes
            attr = lib.mkOption {
              type = (lib.types.attrs);
              default = {};
              description = ''
                ATTRS
              '';
              example = ''
                EXAMPLE
              '';
            };

            # Module setup
            setup = lib.mkOption (
              let
                mkSetupConfig = {
                options = {

                  # Module system config
                  nixos = lib.mkOption {
                    type = (lib.types.raw);
                    default = {};
                    description = ''
                      ATTRS
                    '';
                    example = ''
                      EXAMPLE
                    '';
                  };

                  # Module home config
                  home = lib.mkOption {
                    type = (lib.types.raw);
                    default = {};
                    description = ''
                      ATTRS
                    '';
                    example = ''
                      EXAMPLE
                    '';
                  };

                  # Module darwin config
                  darwin = lib.mkOption {
                    type = (lib.types.raw);
                    default = {};
                    description = ''
                      ATTRS
                    '';
                    example = ''
                      EXAMPLE
                    '';
                  };

                };
              };
            in {
              type = (lib.types.either
                (lib.types.functionTo (lib.types.submodule mkSetupConfig))
                (lib.types.submodule mkSetupConfig)
              );
              default = {};
              description = ''
                ATTRS
              '';
              example = ''
                EXAMPLE
              '';
            });

          };
        }));
        default = {};
        description = ''
          MODULES
        '';
        example = ''
          EXAMPLE
        '';
      };

  };
}
