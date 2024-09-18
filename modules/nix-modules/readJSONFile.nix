{
  # readJSONFile: ./path -> { fileField1 = "A"; fileField2 = "B"; }
  #   ./path: A path that points to a JSON file
  # Reads a JSON file and return its contents
  readJSONFile = filePath: (
    builtins.fromJSON (builtins.readFile filePath)
  );
}
