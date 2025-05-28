{ config, lib, ... }: ( # (Setup-Module)
  let

    cfg = config;

    mkIncludeTagsList = includedTags: (lib.pipe cfg.modules [

      # For each module, define if it should be included or be empty (Be unincluded)
      (x: builtins.mapAttrs (moduleId: module: (
        if (module.enable && (module.include == null || module.include)) then module else null
      )) x)

      # Collects all included tags from the included modules
      (x: builtins.mapAttrs (moduleId: module: module.includeTags) x)

      # Transforms the set of includedTags into a list of includedTags
      (x: builtins.attrValues x)

      # Transforms the list of includedTags(Which is a list) into a single list of tags
      (x: builtins.concatLists x)

      # Remove all tags that are already included
      (x: builtins.map (tag: (
        if (builtins.elem tag includedTags) then null else tag
      )) x)

      # Remove all null items
      (x: lib.remove null x)

      # Return the given tags or reinterate to return the final list of tags
      (x: if ((builtins.length x) > 0) then (
        includedTags ++ (mkIncludeTagsList x)
      ) else includedTags)

    ]);
    finalIncludeTags = (mkIncludeTagsList cfg.includeTags);

    evalModules = moduleType: (
      lib.pipe cfg.modules [

        # For each module in "config.modules", calls "setup" using "attr" (If it's a function)
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) enable include tags;
          setup = if (builtins.isFunction module.setup) then (
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
                  builtins.elem tag finalIncludeTags
                )) x)

                # Check if any of the tags is present in the list
                (x: builtins.elem true x)

              ]
            )
          );
        }) x)

        # For each module, define if it should be included or be empty (Be unincluded)
        (x: builtins.mapAttrs (moduleId: module: (
          if (module.enable && module.include) then module.setup.${moduleType} else null
        )) x)

        # Transforms the set of modules into a list of modules
        (x: builtins.attrValues x)

        # Remove all null items
        (x: lib.remove null x)

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
