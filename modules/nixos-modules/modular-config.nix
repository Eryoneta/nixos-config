let
  mkConfig = (moduleType: { config, lib, ... }: (
    let

      cfg = config;

      getModuleToEval = typeMatch: (
        if (moduleType == "nixos") then (
          if (typeMatch) then "nixosConfigurationModules" else "homeConfigurationModules"
        ) else if (moduleType == "home") then (
          if (typeMatch) then "homeConfigurationModules" else "nixosConfigurationModules"
        ) else ""
      );

      moduleToEval = (getModuleToEval true);
      moduleToNotEval = (getModuleToEval false);

    in {

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

      config.${moduleToEval} = (lib.pipe cfg.modules [

        # For each module in "config.modules", calls "setup" using "attr" (If it's a function)
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enabled included tags;
          setup = if(builtins.isFunction module.setup) then (
            module.setup {
              attr = module.attr;
            }
          ) else module.setup;
        }) x)

        # For each module, define if it should be included or not
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enabled setup;
          included = (
            if (module.included != null) then (
              module.included
            ) else (
              lib.pipe module.tags [

                # Check each tag with the list present in "config.setup.enabledTags"
                (x: builtins.map (tag: (
                  builtins.elem tag cfg.enabledTags
                )) x)

                # Check if any of the tags is present in the list
                (x: builtins.elem true x)

              ]
            )
          );
        }) x)

        # For each module, define if it should be included or be empty
        (x: builtins.mapAttrs (moduleId: module: (
          if (module.enabled && module.included) then module.setup.${moduleType} else {}
        )) x)

        # Transforms the set of modules into a list of modules
        (x: builtins.attrValues x)

      ]);

      config.${moduleToNotEval} = {};

      config.modules."default" = {
        enabled = true;
        tags = [ "default" ];
        setup.nixos = {};
        setup.home = {};
      };
      # Note: A default module is included. That avoids 'homeConfigurationModules' or 'nixosConfigurationModules' from being empty
      config.enabledTags = [ "default" ];
      # Note: The "default" tag can be used to automatically include a module

    }
  ));
in {
  nixosModules = (mkConfig "nixos");
  homeModules = (mkConfig "home");
}
