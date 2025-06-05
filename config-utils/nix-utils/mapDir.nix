nix-lib: rec {
  # MapDir
  /*
    - Gets a path for a directory and returns a set of paths representing the file structure
      - "dirPath": A path to a directory
    - Each set represents a directory, and contains other sets or atributes
    - Each atribute represents a file, and contains a path value for it
  */
  mapDir = dirPath: (
    nix-lib.pipe dirPath [

      # Gets the path and returns a set. It only considers the first level
      # ./path -> { "file.nix" = "regular"; subdir = "directory"; }
      (x: builtins.readDir x)

      # For each file, injects its path. For each directory, recurse to get its set
      # { "file.nix" = "regular"; subdir = "directory"; } -> { "file.nix" = ./path/file.nix; subdir = { ... }; }
      (x: builtins.mapAttrs (filename: filetype: (
        if (filetype == "directory") then (
          # Do a recursion
          mapDir (dirPath + ("/" + filename))
        ) else (
          dirPath + ("/" + filename)
        )
      )) x)

    ]
  );
}
