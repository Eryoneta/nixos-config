rec {
  # mapDir: ./path -> { "file.nix" = ./path/file.nix; subdir = { "file.nix" = ./path/subdir/file.nix }; }
  /*
    - Gets a path for a directory and returns a set of paths
      - "dirPath": A path to a directory
    - Each set represents a directory, and contains other sets or atributes
    - Each atribute represents a file, and contains a path value for it
  */
  mapDir = dirPath: (
    # mapAttr: { "file.nix" = "regular"; } -> { "file.nix" = ./path/file.nix; }
    builtins.mapAttrs (
      name: value: (
        if (value == "directory") then (
          # Recursive
          mapDir (dirPath + ("/" + name))
        ) else (
          dirPath + ("/" + name)
        )
      )
    ) (
      # ReadDir: ./path -> { "file.nix" = "regular"; subdir = "directory"; }
      builtins.readDir dirPath
    )
  );
}
