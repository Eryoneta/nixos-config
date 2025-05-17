let
  mkConfig = (moduleType: { config, lib, ... }: (
    let

      cfg = config.setup;

      evalModule = (
        if (moduleType == "nixos") then (
          "nixosConfiguration"
        ) else if (moduleType == "home") then (
          "homeConfiguration"
        ) else ""
      );

    in {

      options = {
        setup = {

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
          nixosConfiguration = lib.mkOption {
            type = (lib.types.raw);
            readOnly = true;
            visible = false;
            description = ''
              ATTRS
            '';
          };

          # Home-Manager system config
          homeConfiguration = lib.mkOption {
            type = (lib.types.raw);
            readOnly = true;
            visible = false;
            description = ''
              ATTRS
            '';
          };

          # Modules
          modules = lib.mkOption {
            type = (lib.types.lazyAttrsOf (lib.types.submodule {
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
                  type = (lib.types.bool);
                  default = true;
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
                attributes = lib.mkOption {
                  type = (lib.types.attrs);
                  default = {};
                  description = ''
                    ATTRS
                  '';
                  example = ''
                    EXAMPLE
                  '';
                };

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
      };

      config.setup.${evalModule} = (lib.pipe cfg.modules [

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
          included = ( # Default value, allows to be overriden
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
        )) x)

        # Transforms the set of modules into a list of modules
        (x: lib.attrsets.attrValues x)

        # Merges everything into a single set
        (x: lib.mkMerge x)

      ]);

    }
  ));
in {
  nixosModules = (mkConfig "nixos");
  homeManagerModules = (mkConfig "home");
}
