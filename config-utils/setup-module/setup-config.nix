{ config, lib, ... }: ( # (Setup-Module)
  let

    cfg = config;

    evalModules = moduleType: (
      lib.pipe cfg.modules [

        # For each module in "config.modules", calls "setup" using "attr" (If it's a function)
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enable include tags;
          setup = if(builtins.isFunction module.setup) then (
            module.setup {
              attr = module.attr;
            }
          ) else module.setup;
        }) x)

        # For each module, define if it should be included or not
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enable setup;
          include = (
            if (module.include != null) then (
              module.include
            ) else (
              lib.pipe module.tags [

                # Check each tag with the list present in "config.includeTags"
                (x: builtins.map (tag: (
                  builtins.elem tag cfg.includeTags
                )) x)

                # Check if any of the tags is present in the list
                (x: builtins.elem true x)

              ]
            )
          );
        }) x)

        # For each module, define if it should be included or be empty
        (x: builtins.mapAttrs (moduleId: module: (
          if (module.enable && module.include) then module.setup.${moduleType} else {}
        )) x)

        # Transforms the set of modules into a list of modules
        (x: builtins.attrValues x)

      ]
    );

  in {

    imports = [
      ./setup-options.nix
    ];

    config = {

      nixosConfigurationModules = (evalModules "nixos");
      homeConfigurationModules = (evalModules "home");
      darwinConfigurationModules = (evalModules "darwin");

      modules."default" = {
        enable = true;
        tags = [ "default" ];
        setup.nixos = {};
        setup.home = {};
        setup.darwin = {};
      };
      # Note: A default module is included. That stops the readOnly config from being empty, if "config.modules" is empty

      includeTags = [ "default" ];
      # Note: This "default" tag can be used to automatically include a module

    };

  }
)
