{ lib, ... }: { # (Setup-Module)
  options = {

      # Included modules, by tags
      includeTags = lib.mkOption {
        type = (lib.types.listOf (lib.types.str));
        default = [];
        description = ''
          A list of tags from tagged modules to be included in the final configuration.
        '';
        example = ''
          [ "development" ]
        '';
      };

      # Final NixOS system config
      nixosConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          The final configuration, a single NixOS Module that contains all the `nixos` configurations from the included modules.

          This is the output. It returns a valid NixOS Module.
        '';
      };

      # Final Home-Manager system config
      homeConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          The final configuration, a single Home-Manager Module that contains all the `home` configurations from the included modules.

          This is the output. It returns a valid Home-Manager Module.
        '';
      };

      # Final Darwin system config
      darwinConfigurationModules = lib.mkOption {
        type = (lib.types.raw);
        readOnly = true;
        visible = false;
        description = ''
          The final configuration, a single Darwin Module that contains all the `darwin` configurations from the included modules.

          This is the output. It returns a valid Darwin Module.
        '';
      };

      # Modules
      modules = lib.mkOption {
        type = (lib.types.attrsOf (lib.types.submodule {
          options = {

            # Module enabler
            enable = lib.mkOption {
              type = (lib.types.bool);
              default = true;
              description = ''
                Can be set to disable the module glabally.

                It's true by default.
              '';
              example = ''
                false
              '';
            };

            # Module includer
            include = lib.mkOption {
              type = (lib.types.nullOr (lib.types.bool));
              default = null;
              description = ''
                If set, includes or excludes the module. It overrides tag behaviour.

                Very useful for excluding modules from a included tag.
              '';
              example = ''
                true
              '';
            };

            # Module tags
            tags = lib.mkOption {
              type = (lib.types.listOf (lib.types.str));
              default = [];
              description = ''
                List of tags for this module.

                When a tag is present in `config.includeTags`, then this module is included.
              '';
              example = ''
                [ "development" ]
              '';
            };

            # Module attributes
            attr = lib.mkOption {
              type = (lib.types.attrs);
              default = {};
              description = ''
                A set of atributes for this module. Can be thought as a content of a `let in`.

                It can also be used by other modules, allowing to share data between modules.
              '';
              example = ''
                {
                  gitUsername = "yo";
                }
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
                      A valid NixOS module. See [NixOS manual](https://nixos.org/manual/nixos/stable/#ch-configuration) for more information.
                    '';
                    example = ''
                      { config, ... }: { }
                    '';
                  };

                  # Module home config
                  home = lib.mkOption {
                    type = (lib.types.raw);
                    default = {};
                    description = ''
                      A valid `home-manager` module. See [home-manager manual](https://nix-community.github.io/home-manager/) for more information.
                    '';
                    example = ''
                      { config, ... }: { }
                    '';
                  };

                  # Module darwin config
                  darwin = lib.mkOption {
                    type = (lib.types.raw);
                    default = {};
                    description = ''
                      A valid `nix-darwin` module. See [nix-darwin manual](https://daiderd.com/nix-darwin/manual/index.html) for more information.
                    '';
                    example = ''
                      { config, ... }: { }
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
                Either a set or a function that takes `{ attr }` as a argument.
              '';
              example = ''
                { attr }: {
                  nixos = { };
                  home = { };
                  darwin = { };
                }
              '';
            });

          };
        }));
        default = {};
        description = ''
          A module carries a valid module for NixOS, Home-Manager, and Darwin.

          It can be included by `tags`, or by directly setting `include`.

          When included, its modules are put in the final 3 sets that are the output.
        '';
        example = ''
          {
            tags = [ "development" ];
            attr.gitUsername = "yo";
            setup = { attr }: {
              home = { };
            };
          }
        '';
      };

  };
}
