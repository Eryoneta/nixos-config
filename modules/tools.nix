# Tools: My toolkit for conveniences
#   "nix-lib": From "inputs.nixpkgs.lib"
#   "hm-pkgs": From ''inputs.nixpkgs.legacyPackages."x86_64-linux"''
#   "hm-lib": From "inputs.home-manager.lib"
nix-lib: hm-pkgs: hm-lib: (
  let

    # Import
    mapDir = (import ./nix-modules/mapDir.nix).mapDir;

    # It's a set with useful functions I use a lot
    firstAttrSet = {

      # Set a value to be before others
      mkBefore = value: (nix-lib.mkBefore value);

      # Set a value to be after others
      mkAfter = value: (nix-lib.mkAfter value);

      # Defines a default value
      mkDefault = value: (nix-lib.mkDefault value);

      # Forces a value
      mkForce = value: (nix-lib.mkForce value);

      # Creates a symlink to files outside Nix Store
      # It's a recreation from: https://github.com/nix-community/home-manager/blob/master/modules/files.nix#L64-L69
      # Scary! I hope it doesn't break...!
      # All that to avoid requiring "config.lib.file" from home-manager modules
      mkOutOfStoreSymlink = absolutePath: (
        let
          pathStr = toString absolutePath;
          name = hm-lib.hm.strings.storeFileName (baseNameOf pathStr);
        in (
          hm-pkgs.runCommandLocal name {} ''ln -s ${nix-lib.strings.escapeShellArg pathStr} $out''
        )
      );

      # All my "nix-modules"
      mkFunc = {};

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

  in (
    firstAttrSet // {
      mkFunc = (
        # Foldl': ( { ... }, [ { ... } { ... } ] ) -> { ... }
        builtins.foldl' (
          accumulator: modifier: (
            # Merges everything into one huge set
            accumulator // modifier
          )
        ) firstAttrSet.mkFunc attrSets
      );
    }
  )
)
