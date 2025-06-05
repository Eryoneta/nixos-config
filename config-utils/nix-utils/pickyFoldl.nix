{
  # PickyFoldl
  /*
    - Folds a list of sets into a single set
      - "firstAttrSet": The first set. The base. The one to be overrided by all others
      - "attrSets": A list of sets that will override the first one
      - "attrsToMerge": The atributes that should be merged between all sets
  */
  pickyFoldl = firstAttrSet: attrSets: attrsToMerge: (
    let

      # PickyMergeAttrs
      pickyMergeAttrs = (builtins.import ./pickyMergeAttrs.nix).pickyMergeAttrs;

    in
      # Merges all sets into one
      builtins.foldl' (finalSet: set: (
        (finalSet // set) // (
          pickyMergeAttrs finalSet set attrsToMerge
        )
      )) firstAttrSet attrSets
    );
}
