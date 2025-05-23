{
  # ReadJSONFile: ./path -> { fileField1 = "A"; fileField2 = "B"; }
  /*
    - Reads a JSON file and return its contents
      - "filePath": A path to a JSON file
  */
  readJSONFile = filePath: (
    builtins.fromJSON (builtins.readFile filePath)
  );
}
