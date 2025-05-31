{
  # ReadJSONFile
  /*
    - Reads a JSON file and return its content
      - "filePath": A path to a JSON file
  */
  readJSONFile = filePath: (
    # Read a file, then convert the JSON content into nix
    builtins.fromJSON (builtins.readFile filePath)
  );
}
