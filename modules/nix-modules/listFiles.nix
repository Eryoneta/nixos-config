nix-lib: {
  # listFiles: (./path "pre-" "text" ".ext") -> [ "./path/pre-text.ext" "./path/pre-mytext.ext" ]
  #   dirPath: A path that points to a folder
  #   withPrefix: A text prefix
  #   withInFix: A text infix
  #   withSuffix: A text suffix
  # List files that matches all filters
  listFiles = dirPath: withPrefix: withInFix: withSuffix: (
    builtins.map (
      value: "${dirPath}/${value}"
    ) (
      let

        # HasPrefix: ("text" "pre-text.ext") -> true
        hasPrefix = value: (nix-lib.strings.hasPrefix withPrefix value);

        # HasInfix: ("pre" "pre-text") -> true
        hasInfix = value: (nix-lib.strings.hasInfix withInFix value);

        # HasSuffix: (".ext" "text.ext") -> true
        hasSuffix = value: (nix-lib.strings.hasSuffix withSuffix value);

      in
      # Filter: [ "valid" "invalid" ] -> [ "valid" ]
      builtins.filter (
        value: (
          if ((hasPrefix value) && (hasInfix value) && (hasSuffix value)) then (
            true
          ) else false
        )
      ) (
        builtins.attrNames (builtins.readDir dirPath)
      )
    )
  );
}
