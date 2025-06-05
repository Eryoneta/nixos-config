nix-lib: rec {
  # SearchFiles
  /*
    - List files that matches all filters
      - "dirPath": A path to a directory
      - "withPrefix": A text prefix
      - "withInfix": A text infix. Can also be a list of texts
      - "withSuffix": A text suffix
    - Is the same as "listFiles", but it also includes sub-directories!
  */
  searchFiles = dirPath: withPrefix: withInfix: withSuffix: (
    let

      # HasPrefix: ("pre" "pre-text") -> true
      hasPrefix = text: (nix-lib.strings.hasPrefix withPrefix text);

      # HasInfix: ("text" "pre-text.ext") -> true
      hasInfix = infix: text: (nix-lib.strings.hasInfix withInfix text);

      # HasSuffix: (".ext" "pre-text.ext") -> true
      hasSuffix = text: (nix-lib.strings.hasSuffix withSuffix text);

      # HasInfix: ([ "text" ] "pre-text.ext") -> true
      hasInfixList = text: (
        if (builtins.isString withInfix) then (
          # If it's a string, do a regular check
          hasInfix withInfix text
        ) else if (builtins.isList withInfix) then (
          # If it's a list, do a check for each item
          builtins.all (infixValue: (
            hasInfix infixValue text
          )) withInfix
        ) else false
      );

    in (
      nix-lib.pipe dirPath [

        # Gets the path and returns a set. It only considers the first level
        # dirPath -> { "file.ext" = "regular"; subdir = "directory"; }
        (x: builtins.readDir x)

        # Transforms each item into a list
        (x: builtins.mapAttrs (filename: filetype: (
          if (filetype == "directory") then (
            # If it's a directory, search for its files
            # Do a recursion
            searchFiles "${dirPath}/${filename}" withPrefix withInfix withSuffix
          ) else (
            # If it's a file, include it only if it matches all filters
            if ((hasPrefix filename) && (hasInfixList filename) && (hasSuffix filename)) then (
              [ "${dirPath}/${filename}" ]
            ) else []
          )
          # The final result is a list, either empty or filled with paths
        )) x)

        # Transforms the set into a list
        (x: builtins.attrValues x)

        # Transforms the list of lists into a single list
        (x: builtins.concatLists x)

      ]
    )
  );
}
