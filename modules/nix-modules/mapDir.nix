rec {
  mapDir = dirPath: (
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
