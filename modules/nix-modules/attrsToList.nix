{
  # AttrsToList: { attr1 = "value1"; } -> [ "value1" ]
  /*
    - Transforms a set into a list
      - Each element is a value of the set
      - "attrSet": The set to be converted
  */
  attrsToList = attrSet: (
    # Map: [ "attr1" ] -> [ "value1" ]
    builtins.map (
      value: attrSet.${value}
    ) (
      # AttrNames: { attr1 = "value1"; } -> [ "attr1" ]
      builtins.attrNames attrSet
    )
  );
}
