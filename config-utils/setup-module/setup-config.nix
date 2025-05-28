{ config, lib, ... }: ( # (Setup-Module)
  let

    cfg = config;

    validateModules = includedTags: (
      lib.pipe cfg.modules [

        # For each module, define if it should be included or not
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enable includeTags setup;
          include = (
            if (module.include != null) then ( # If "include" is defined, then use it
              module.include
            ) else ( # If "include" is null, then check "tags"
              lib.pipe module.tags [

                # Check each tag with the given tag list
                (x: builtins.map (tag: (
                  builtins.elem tag includedTags
                )) x)

                # Check if any of the tags is present in the list
                (x: builtins.elem true x)

              ]
            )
          );
        }) x)

        # For each module, define if it should be included or be null (Be unincluded)
        (x: builtins.mapAttrs (moduleId: module: (
          if (module.enable && module.include) then module else null
        )) x)

        # Remove all null modules
        (x: lib.filterAttrs (moduleId: module: (module != null)) x)

        # Transforms each module into a set of modules
        (x: builtins.mapAttrs (moduleId: module: (
          x // ( # By merging a set, a duplicate is overriden
            let
              finalIncludeTags = (lib.pipe module.includeTags [

                # Remove all tags that are already included
                (x: builtins.map (tag: (
                  if (builtins.elem tag includedTags) then null else tag
                )) x)

                # Remove all null items
                (x: lib.remove null x)

              ]);
            in (
              # If there is new tags, reinterate modules to include new modules
              if ((builtins.length finalIncludeTags) > 0) then (
                (validateModules finalIncludeTags)
              ) else {}
            )
          )
        )) x)

        # Transforms the set of sets of modules into a list of sets of modules
        (x: builtins.attrValues x)

        # Merges all sets of modules into a single set of modules
        (x: builtins.foldl' (finalModules: modules: (
          finalModules // modules # By merging sets, all duplicates are overriden
        )) {} x)

      ]
    );

    evalModules = moduleType: (
      lib.pipe (validateModules cfg.includeTags) [

        # Transforms the set of modules into a list of modules
        (x: builtins.attrValues x)

        # For each module in "config.modules", calls "setup" using "attr" (If it's a function)
        (x: builtins.map (module: {
          setup = if (builtins.isFunction module.setup) then (
            module.setup {
              attr = module.attr;
            }
          ) else module.setup;
        }) x)

        # For each module, get the desired module inside "setup"
        (x: builtins.map (module: (
          module.setup.${moduleType}
        )) x)

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
