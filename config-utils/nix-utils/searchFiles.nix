nix-lib: rec {
  # SearchFiles: (./path "pre-" "text" ".ext") -> [ "./path/pre-text.ext" "./path/subDir/pre-mytext.ext" ]
  /*
    - List files that matches all filters
      - "dirPath": A path to a directory
      - "withPrefix": A text prefix
      - "withInfix": A text infix. Can be also a list of texts
      - "withSuffix": A text suffix
    - Is the same as "listFiles", but it also includes sub-directories!
  */
  #   
  searchFiles = dirPath: withPrefix: withInfix: withSuffix: (
    let

      # HasPrefix: ("text" "pre-text.ext") -> true
      hasPrefix = value: (nix-lib.strings.hasPrefix withPrefix value);

      # HasInfix: ("pre" "pre-text") -> true
      hasInfix = value: (
        if (builtins.isString withInfix) then (
          # HasInfix: ("pre" "pre-text") -> true
          nix-lib.strings.hasInfix withInfix value
        ) else if (builtins.isList withInfix) then (
            # All: [ true true ] -> true
            builtins.all (
              infixValue: (
                # HasInfix: ("pre" "pre-text") -> true
                nix-lib.strings.hasInfix infixValue value
              )
            ) withInfix
        ) else false
      );

      # HasSuffix: (".ext" "text.ext") -> true
      hasSuffix = value: (nix-lib.strings.hasSuffix withSuffix value);

      # Current directory
      directory = (builtins.readDir dirPath);

    in (
      # ConcatLists: [ [ "dirPath/file1.ext" ] [ "dirPath/subDir/file2.ext" ] ] -> [ "dirPath/file1.ext" "dirPath/subDir/file2.ext" ]
      builtins.concatLists (
        # Map: [ "file1.ext" "subDir" ] -> [ [ "dirPath/file1.ext" ] [ "dirPath/subDir/file2.ext" ] ]
        builtins.map (value:
          if (directory.${value} == "directory") then (
            # [ "dirPath/subDir/file2.ext" ]
            # Recursive
            searchFiles ("${dirPath}/${value}") withPrefix withInfix withSuffix
          ) else (
            # [ "dirPath/file1.ext" ]
            if ((hasPrefix value) && (hasInfix value) && (hasSuffix value)) then (
              [ "${dirPath}/${value}" ]
            ) else []
          )
        ) (
          # AttrNames: { "file1.ext" = "regular"; subDir = "directory"; } -> [ "file1.ext" "subDir" ]
          builtins.attrNames (
            # ReadDir: dirPath -> { "file1.ext" = "regular"; subDir = "directory"; }
            directory
          )
        )
      )
    )
  );
}
