let
  mkConfig = (moduleType: { config, lib, ... }: (
    let
      cfg = config.setup;
    in {

      options = {
        setup = {

          # Tags
          enabledTags = lib.mkOption {
            type = (lib.types.attrsOf (lib.types.raw));
            default = {};
            description = ''
              FINAL-TAGS
            '';
          };

          # Modules
          modules = lib.mkOption {
            type = (lib.types.lazyAttrsOf (lib.types.submodule {
              options = {

                # Module includer
                included = lib.mkOption {
                  type = (lib.types.bool);
                  default = true;
                  description = ''
                    TAGS
                  '';
                };

                # Module tags
                tags = lib.mkOption {
                  type = (lib.types.listOf (lib.types.str));
                  default = [];
                  description = ''
                    TAGS
                  '';
                };

                # Module attributes
                attributes = lib.mkOption {
                  type = (lib.types.attrs);
                  default = {};
                  description = ''
                    ATTRS
                  '';
                };

                # Module system config
                nixos = lib.mkOption {
                  type = (lib.types.raw);
                  default = {};
                  description = ''
                    ATTRS
                  '';
                };

                # Module home config
                home = lib.mkOption {
                  type = (lib.types.raw);
                  default = {};
                  description = ''
                    ATTRS
                  '';
                };

              };
            }));
            default = {};
            description = ''
              FINAL-TAGS
            '';
          };
        };
      };

      config = (lib.pipe cfg.modules [

        # For each module in "setup.modules", calls "nixos" and "home" using "attributes" (If those are functions)
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enabled tags;
          nixos = if(builtins.isFunction module.nixos) then (
            module.nixos {
              attributes = module.attributes;
            }
          ) else module.nixos;
          home = if(builtins.isFunction module.home) then (
            module.home {
              attributes = module.attributes;
            }
          ) else module.home;
        }) x)

        # For each module, define if it should be included or not
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enabled nixos home;
          included = lib.mkDefault ( # Default value, allows to be overriden
            lib.pipe module.tags [

              # Check each tag with the list present in "config.setup.enabledTags"
              (x: builtins.map (tag: (
                builtins.elem tag cfg.enabledTags
              )) x)

              # Check if any of the tags is present in the list
              (x: builtins.elem true x)

            ]
          );
        }) x)

        # For each module, define if it should be enabled or not
        (x: builtins.mapAttrs (moduleId: module: (
          lib.mkIf (module.enabled && module.included) module.${moduleType}
          # if (module.enabled && module.included) then module.${moduleType} else {}
        )) x)

        (x: builtins.mapAttrs (moduleId: module:
          builtins.removeAttrs module [ "setup" ]
        ) x)

        # Transforms the set of modules into a list of modules
        (x: lib.attrsets.attrValues x)

        # Merges everything into a single set
        (x: lib.mkMerge x)
        # (x: lib.foldAttrs (attrs: attrsList: attrsList ++ [ attrs ]) [] x)

      ]);

    }
  ));
in {
  nixosModules = (mkConfig "nixos");
  homeManagerModules = (mkConfig "home");
}
