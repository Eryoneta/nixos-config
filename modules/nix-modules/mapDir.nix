rec {
  # mapDir: ./path -> { "file.nix" = ./path/file.nix; subdir = { "file.nix" = ./path/subdir/file.nix }; }
  #   ./path: A path that points to a folder
  # Transforms a folder into a series of sets and atributes
  #   Each set represents a folder, and contains other sets or atributes
  #   Each atribute represents a file, and contains a path value for it
  mapDir = dirPath: (
    # mapAttr: { "file.nix" = "regular"; } -> { "file.nix" = ./path/file.nix; }
    builtins.mapAttrs (
      name: value: (
        if (value == "directory") then (
          mapDir (dirPath + ("/" + name))
        ) else (
          dirPath + ("/" + name)
        )
      )
    ) (builtins.readDir dirPath)
  );
}
