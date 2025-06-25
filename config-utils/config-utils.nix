# Configuration-Utilities: My toolkit for conveniences
#   "nix-lib": From "inputs.nixpkgs.lib"
#   "hm-pkgs": From ''inputs.nixpkgs.legacyPackages."x86_64-linux"''
#   "hm-lib": From "inputs.home-manager.lib"
{
  # Builder
  build = { nixpkgs-lib, home-manager-pkgs, home-manager-lib}: (
    let
      nix-lib = nixpkgs-lib;
      hm-pkgs = home-manager-pkgs;
      hm-lib = home-manager-lib;

      # Import
      mapDir = (builtins.import ./nix-utils/mapDir.nix nix-lib).mapDir;

      # It's a set with useful functions I use a lot
      commonFuncs = {

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
        # Note: Using it like "config = utils.mkIf" causes an infinte recursion. That does not happen with "lib.mkIf"
        # Theory:
        #   Some config(override?) changes "pkgs"? That changes "pkgs.lib"?
        #   That changes "config-utils" (Which uses "nixpkgs.lib"(Which is "pkgs.lib"))?
        #   Infinite recursion: A config affects "pgks", and that causes "utils.mkIf" to "change" and affect the config...?

        # If else
        mkIfElse = condition: content: elseContent: (
          nix-lib.mkMerge [
            (nix-lib.mkIf condition content)
            (nix-lib.mkIf (!condition) elseContent)
          ]
        );

        # Merge values
        mkMerge = value: (nix-lib.mkMerge value);

        # Creates a symlink to files outside Nix Store
        # It's a recreation from: https://github.com/nix-community/home-manager/blob/master/modules/files.nix#L64-L69
        mkOutOfStoreSymlink = absolutePath: (
          let
            pathStr = builtins.toString absolutePath;
            name = (hm-lib.hm.strings.storeFileName (builtins.baseNameOf pathStr));
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

        # Sets a package to override others in case of conflict
        higherPriority = package: (nix-lib.hiPrio package);

        # Sets a package to be overriden by others in case of conflict
        lowerPriority = package: (nix-lib.lowPrio package);

        # Check if a path exists
        pathExists = path: (builtins.pathExists path);

        # Join strings from a list into one
        joinStr = str: list: (builtins.concatStringsSep str list);

        # Replace strings
        replaceStr = from: to: list: (builtins.replaceStrings [ from ] [ to ] list);

        # Greatly simplify the use of functions
        pipe = startValue: listOfFunctions: (nix-lib.pipe startValue listOfFunctions);

        # Greatly simplify the use of functions
        reverseList = list: (nix-lib.reverseList list);

        # Creates a file
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

      # My NixOS modules from ./nixos-modules
      nixosModules = {
        nixos-modules = (mapDir ./nixos-modules);
      };

      # My nix functions from ./nix-utils
      nixUtils = (nix-lib.pipe ./nix-utils [

        # List all files as a set
        (x: builtins.readDir x)

        # Get the filenames
        (x: builtins.attrNames x)

        # Import each module
        (x: builtins.map (filename: (
          builtins.import "${./nix-utils}/${filename}"
        )) x)

        # For each module, if its a function, call it with "lib"
        (x: builtins.map (module: (
          if (builtins.isFunction module) then (
            module nix-lib
          ) else module
        )) x)

        # Merges everything into one huge set
        (x: builtins.foldl' (finalSet: nixUtil: (
          finalSet // nixUtil
        )) {} x)

      ]);

    in {
      config-utils = {
        utils = (commonFuncs // nixosModules // nixUtils);
      };
    }
  );
}
