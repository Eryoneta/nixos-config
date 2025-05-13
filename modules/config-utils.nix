# Configuration-Utilities: My toolkit for conveniences
#   "nix-lib": From "inputs.nixpkgs.lib"
#   "hm-pkgs": From ''inputs.nixpkgs.legacyPackages."x86_64-linux"''
#   "hm-lib": From "inputs.home-manager.lib"
nix-lib: hm-pkgs: hm-lib: (
  let

    # Import
    mapDir = (import ./nix-modules/mapDir.nix).mapDir;

    # It's a set with useful functions I use a lot
    firstAttrSet = {

      # Defines a default value
      mkDefault = value: (nix-lib.mkDefault value);

      # Forces a value
      mkForce = value: (nix-lib.mkForce value);

      # Set a value to be before others
      mkBefore = value: (nix-lib.mkBefore value);

      # Set a value to be after others
      mkAfter = value: (nix-lib.mkAfter value);

      # If condition
      mkIf = condition: content: (nix-lib.mkIf condition content);
      # Note: It seems it cannot be used like "config = utils.mkIf" as it causes an infinte recursion
      # Theory:
      #   Some config(override?) changes "pkgs"? That changes "pkgs.lib"?
      #   That changes "config-utils" (Which uses "nixpkgs.lib"(Which is "pkgs.lib"))?
      #   Infinite recursion: A config affects "pgks", and that causes "utils.mkIf" to "change" and affect the config...?

      # If else
      mkIfElse = condition: content: elseContent: nix-lib.mkMerge [
        (nix-lib.mkIf condition content)
        (nix-lib.mkIf (!condition) elseContent)
      ];

      # Merge arrays
      mkMerge = value: (nix-lib.mkMerge value);

      # Creates a symlink to files outside Nix Store
      # It's a recreation from: https://github.com/nix-community/home-manager/blob/master/modules/files.nix#L64-L69
      # Scary! I hope it doesn't break...!
      # All that to avoid requiring "config.lib.file" from every home-manager module that needs this
      mkOutOfStoreSymlink = absolutePath: (
        let
          pathStr = builtins.toString absolutePath;
          name = hm-lib.hm.strings.storeFileName (builtins.baseNameOf pathStr);
        in (
          hm-pkgs.runCommandLocal name {} ''ln -s ${nix-lib.strings.escapeShellArg pathStr} $out''
        )
      );

      # Creates a list of integers option for "options"
      mkIntListOption = default: nix-lib.mkOption {
        inherit default;
        type = nix-lib.types.listOf nix-lib.types.int;
      };

      # Creates a bool option for "options"
      mkBoolOption = default: nix-lib.mkOption {
        inherit default;
        type = nix-lib.types.bool;
      };

      # Creates a int option for "options"
      mkIntOption = default: nix-lib.mkOption {
        inherit default;
        type = nix-lib.types.int;
      };

      # Creates a package option for "options"
      mkPackageOption = default: nix-lib.mkOption {
        inherit default;
        type = nix-lib.types.attrs;
      };

      # Creates a defaults option for "options"
      mkDefaultsOption = default: nix-lib.mkOption {
        inherit default;
        type = nix-lib.types.attrs;
      };

      # Check if a path exists
      pathExists = path: (builtins.pathExists path);

      # Join strings from a list into one
      joinStr = str: list: (builtins.concatStringsSep str list);

      # Replace strings
      replaceStr = from: to: list: (builtins.replaceStrings [ from ] [ to ] list);

      # Greatly simplify the use of functions
      pipe = startValue: listOfFunctions: (nix-lib.pipe startValue listOfFunctions);

      # Merges lists of lists into a single list
      concatLists = listOfLists: (builtins.concatLists listOfLists);

      # Check if a path exists
      toFile = fileName: content: (builtins.toFile fileName content);

      # Build a JSON format from a set
      toJSON = content: (nix-lib.generators.toJSON {} content);

      # Build a INI format from a set
      toINI = content: (nix-lib.generators.toINI {} content);

      # Build a YAML format from a set
      # Note: "nix-lib.generators.toYAML" is not real!
      toYAML = content: (
        builtins.readFile (
          (hm-pkgs.formats.yaml {}).generate "toYAML_file.yaml" content
        )
      );

    };

    # It's a list of all my "nix-modules"
    attrSets = (
      # Map: [ "file1.nix" "file2.nix" "file3.nix" ] -> [ { ... } { ... } { ... } ]
      builtins.map (
        value: (
          let
            nixModule = (import (./nix-modules + "/${value}"));
          in
            if (builtins.isFunction nixModule) then (
              # If its a function, then it requires "lib"
              (nixModule nix-lib)
            ) else nixModule
        )
      ) (builtins.attrNames (mapDir ./nix-modules))
    );

  in {
    utils = (firstAttrSet // (
      # Foldl': ( { ... }, [ { ... } { ... } ] ) -> { ... }
      builtins.foldl' (
        accumulator: modifier: (
          # Merges everything into one huge set
          accumulator // modifier
        )
      ) firstAttrSet attrSets
    ));
  }
)
