let
  mkConfig = (moduleType: { config, lib, ... }: (
    let
      cfg = config.setup;
    in {

      options = {
        setup = {

          # Tags
          taggedModules = lib.mkOption {
            type = (lib.types.attrsOf (lib.types.raw));
            default = {};
            description = ''
              FINAL-TAGS
            '';
          };

          # Modules
          modules = lib.mkOption {
            type = (lib.types.attrsOf (lib.types.submodule {
              options = {

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

      config = {
        setup.taggedPrograms = lib.pipe cfg.modules [

          # For each module in "setup.modules", calls "nixos" and "home" using "attributes" (If those are functions)
          (x: builtins.mapAttrs (moduleId: module: {
            inherit (module) tags;
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

          # For each module, load "nixos" or "home" into each tag from "tags"
          (x: builtins.mapAttrs (moduleId: module: {
            tags = lib.pipe module.tags [

              # Prepare list of tags to be transformed into a set of tags. Also, includes only one of the configurations
              (t: builtins.map (tagId: {
                name = "${tagId}";
                value = module.${moduleType};
              }) t)

              # List to set
              (t: builtins.listToAttrs t)

            ];
          }) x)

          # Transforms the set of modules into a list of modules
          (x: lib.attrsets.attrValues x)

          # Merges all sets of tags from each module into a single set of tags
          (x: lib.attrsets.foldAttrs (module: listOfModules: listOfModules ++ [ module.tags ]) [] x)

        ];
      };

    }
  ));
in {
  nixosModules = (mkConfig "nixos");
  homeManagerModules = (mkConfig "home");
}
