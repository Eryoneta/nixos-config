{ config, lib, ... }: ( # (Setup-Manager Module)
  let

    cfg = config;

    evalPresence = includedTags: excludedTags: (
      lib.pipe cfg.modules [
        /* {
          "A" = { tags = [ "tagA" ]; includeTags = [ "tagB" ]; }; # This is included with includeTags = [ "tagA" ];
          "B" = { tags = [ "tagB" ]; excludeTags = [ "tagC" ]; };
          "C" = { tags = [ "tagC" ]; };
          "D" = { tags = [ "tagD" ]; };
        } */

        # For each module, define if it should be included, excluded, or ignored
        (x: builtins.mapAttrs (moduleId: module: {
          inherit (module) includeTags excludeTags;
          include = (
            if (module.enable == false) then (
              false # Module is disabled
            ) else if (module.include != null) then ( # If "include" is defined, then use it
              module.include
            ) else ( # If "include" is null, then check "tags"
              lib.pipe module.tags [

                # Compare each tag with the given tag list for exclusion
                (x: builtins.map (tag: (
                  if (builtins.elem tag excludedTags) then true else tag # Preserve the tag string
                )) x)

                # Any matches means the module is to be excluded
                (x: (
                  if (builtins.elem true x) then false else x
                ))

                # Check each tag with the given tag list
                (x: (
                  if (x == false) then x else (
                    builtins.map (tag: (
                      if (builtins.elem tag includedTags) then true else null
                    )) x
                  )
                ))

                # Any matches means the module is to be included
                (x: (
                  if (x == false) then x else (
                    if (builtins.elem true x) then true else null
                  )
                ))

              ]
            )
          ); # Note: "true" = Include, "false" = Exclude, and "null" = Ignore
        }) x)

        /* {
          "A" = { include = true; includeTags = [ "tagB" ]; };
          "B" = { include = null; excludeTags = [ "tagC" ]; };
          "C" = { include = null; };
          "D" = { include = null; };
        } */

        # Transforms each included module into a set of all modules it itself includes and excludes
        (x: builtins.mapAttrs (moduleId: module: (
          if (module.include == false || module.include == null) then (
            {
              ${moduleId} = module.include; # Should define its own inclusion
            }
          ) else (
            let
              newIncludeTags = (lib.pipe module.includeTags [

                # Remove all tags that are already included
                (x: builtins.map (tag: (
                  if (builtins.elem tag includedTags) then null else tag
                )) x)

                # Remove all null items
                (x: lib.remove null x)

              ]);
              newExcludeTags = (lib.pipe module.excludeTags [

                # Remove all tags that are already excluded
                (x: builtins.map (tag: (
                  if (builtins.elem tag excludedTags) then null else tag
                )) x)

                # Remove all null items
                (x: lib.remove null x)

              ]);
            in (
              # If there is new tags, reinterate modules to include or exclude new modules
              (if ((builtins.length newIncludeTags) > 0 || (builtins.length newExcludeTags) > 0) then (
                (evalPresence newIncludeTags newExcludeTags)
              ) else {}) // {
                ${moduleId} = true; # It should define itself as included
                # Note: A module that includes others should not be excluded by these same ones
              }
            )
          )
        )) x)

        /* {
          "A" = { "A" = true; "B" = true; "C" = null; "D" = null; };
          "B" = { "A" = null; "B" = true; "C" = false; "D" = null; };
          "C" = { "C" = null; };
          "D" = { "D" = null; };
        } */

        # # Transforms the set of sets of modules into a list of sets of modules
        (x: builtins.attrValues x)

        /* [
          { "A" = true; "B" = true; "C" = null; "D" = null; }
          { "A" = null; "B" = true; "C" = false; "D" = null; }
          { "C" = null; }
          { "D" = null; }
        ] */

        # Merges all sets from the list into a single set of modules inclusions, each one with a list of inclusions
        (x: lib.foldAttrs (finalModuleInclusion: isModuleIncluded: (
          [ finalModuleInclusion ] ++ isModuleIncluded
        )) [] x)

        /* {
          "A" = [ true null ];
          "B" = [ true true ];
          "C" = [ null false null ];
          "D" = [ null null null ];
        } */

        # Merges the list of inclusions of each one into a single value
        (x: builtins.mapAttrs (moduleId: inclusionList: (
          builtins.foldl' (isFinalModuleIncluded: isModuleIncluded: (
            if (isFinalModuleIncluded == false || isModuleIncluded == false) then (
              false # Module is excluded
            ) else if (isFinalModuleIncluded == true || isModuleIncluded == true) then (
              true # Module is included
            ) else (
              null # Module is ignored
            )
          )) null inclusionList
        )) x)

        /* {
          "A" = true;
          "B" = true;
          "C" = false;
          "D" = null;
        } */

      ]
    );

    # Returns a set with all the final modules included
    includedModules = (
      lib.pipe cfg.modules [

        # Transforms each module into a boolean
        (x: builtins.mapAttrs (moduleId: module: (
          if ((evalPresence cfg.includeTags cfg.excludeTags).${moduleId} == true) then (
            true
          ) else false # This is necessary, as evalPresence also uses null, which should be false to be boolean
        )) x)

      ]
    );

    # Takes all "config.includedModules" and returns a list with the desired module-type from inside each setup-module
    evalModules = moduleType: (
      lib.pipe cfg.includedModules [

        # For each module, include the content or mark as unincluded
        (x: builtins.mapAttrs (moduleId: isModuleIncluded: (
          if (isModuleIncluded) then (
            cfg.modules.${moduleId}
          ) else null
        )) x)

        # Transforms the set of modules into a list of modules
        (x: builtins.attrValues x)

        # Remove all unincluded modules
        (x: builtins.filter (module: (module != null)) x)

        # For each module in "config.modules", calls "setup" using "attr" (If it's a function)
        (x: builtins.map (module: {
          setup = (
            if (lib.isFunction module.setup) then (
              module.setup { attr = module.attr; } # Calls the function
            ) else module.setup # Simply forwards the set
          );
        }) x)

        # For each module, get the desired module inside "setup"
        (x: builtins.map (module: (
          module.setup.${moduleType}
        )) x)

      ]
    );

  in {

    config = {

      includedModules = includedModules;

      nixosConfigurationModules = (evalModules "nixos");
      homeConfigurationModules = (evalModules "home");
      darwinConfigurationModules = (evalModules "darwin");

      modules."setup-manager-default-module" = {
        # Note: Hopefully, nobody will use that name
        include = true;
        setup.nixos = {};
        setup.home = {};
        setup.darwin = {};
      };
      # Note: A default module is included. That stops the readOnly config from being empty, if "config.modules" is empty

    };

  }
)
