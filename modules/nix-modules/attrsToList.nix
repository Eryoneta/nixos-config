nix-lib: {
  # attrsToList: { attr1 = "value1"; } -> [ "value1" ]
  #   attrSet: The set to be converted
  # Transforms a set into a list
  #   Each element is a value of the set
  attrsToList = attrSet: (
    let
      setNamesList = (builtins.attrNames attrSet);
    in (
      # Map: [ "attr1" ] -> [ "attr1_value" ]
      builtins.map (
        value: attrSet.${value}
      ) setNamesList
    )
  );
}
