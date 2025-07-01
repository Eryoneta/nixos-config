lib: {
  # All custom lib functions are loaded here
  file-manager = (lib.pipe ./. [

    # List all files as a set
    (x: builtins.readDir x)

    # Get the filenames
    (x: builtins.attrNames x)

    # Do not include "default.nix"
    (x: builtins.filter (filename:
      (filename != "default.nix")
    ) x)

    # Import each function
    (x: builtins.map (filename: (
      builtins.import "${./.}/${filename}"
    )) x)

    # For each function, if its a function itself, call it with "lib"
    (x: builtins.map (function: (
      if (builtins.isFunction function) then (
        function lib
      ) else function
    )) x)

    # Merges everything into one huge set
    (x: builtins.foldl' (finalLib: libFunction: (
      finalLib // libFunction
    )) {} x)

  ]);
}