{
  # CollapseAttrs: ( { ... }, [ { ... } { ... } ], { attr1 = ...; attr2 = ...; } ) -> { ...; attr1 = ...; attr2 = ...; }
  /*
    - Collapses many sets into one
      - "firstAttrSet": The first set. The base. The one to be overrided by all others
      - "attrSets": A list of sets that will override the first one
      - "attrsToOverride": The atributes that should be merged between all sets, instead of overridden
      - Normally, sets and lists are overrided
        - Ex.: ''
          { a = { b = true; }; } // { a = { c = true; }; } -> { a = { c = true; }; }
        ''
          - Here, "a.b" is lost, overridden by "a.c"!
      - But here,some of them are chosen to be merged
        - Ex.: ''
          collapseAttrs { a = {}; b = "B"; } [
            { a = { b = true; }; }
            { a = { c = true; }; }
          ] { a = {}; }
            -> { a = { b = true; c = true; }; b = "B"; }
        ''
          - Here, both "a.b" and "a.c" are kept
  */
  collapseAttrs = firstAttrSet: attrSets: attrsToOverride: (
    let

      # mergeAttrs
      mergeAttrs = (import ./mergeAttrs.nix).mergeAttrs;

    in
      # Foldl': ( { ... }, [ { ... } { ... } ] ) -> { ... }
      builtins.foldl' (
        accumulator: modifier: (
          # Return = Accumulator + (Modifier + Set)
          # (Accumulator might have some other attr too! It should be included in Return!)
          accumulator // (
            # Modifier = Modifier + Set
            # (Modifier might have some other attr too! It should be included in Return!)
            modifier // (
              # Set = Variables to be overrided
              mergeAttrs accumulator modifier attrsToOverride
            )
          )
        )
      ) firstAttrSet attrSets
    );
}
