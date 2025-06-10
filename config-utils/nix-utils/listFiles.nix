nix-lib: {
  # ListFiles
  /*
    - List files that matches all filters
      - "dirPath": A path to a directory
      - "withPrefix": A text prefix
      - "withInFix": A text infix
      - "withSuffix": A text suffix
  */
  listFiles = dirPath: withPrefix: withInfix: withSuffix: (
    let

      # HasPrefix: ("pre" "pre-text") -> true
      hasPrefix = text: (nix-lib.strings.hasPrefix withPrefix text);

      # HasInfix: ("text" "pre-text.ext") -> true
      hasInfix = text: (nix-lib.strings.hasInfix withInfix text);

      # HasSuffix: (".ext" "pre-text.ext") -> true
      hasSuffix = text: (nix-lib.strings.hasSuffix withSuffix text);

    in (
      nix-lib.pipe dirPath [

        # Gets the path and returns a set. It only considers the first level
        # ./path -> { "file.nix" = "regular"; subdir = "directory"; }
        (x: builtins.readDir x)

        # Transforms the set of files into a list of filenames
        # { "file.ext" = "regular"; subdir = "directory"; } -> [ "file.ext" "subdir" ]
        (x: builtins.attrNames x)

        # Includes only the files that matches all filters
        (x: builtins.filter (filename: (
          (hasPrefix filename) && (hasInfix filename) && (hasSuffix filename)
        )) x)

        # Transforms the list of filenames into a list of paths
        (x: builtins.map (filename: (
          "${dirPath}/${filename}"
        )) x)

      ]
    )
  );
}
