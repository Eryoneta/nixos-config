{
  # CollapseAttrs: ( { ... }, [ { ... } { ... } ], { attr1 = ...; attr2 = ...; } ) -> { ...; attr1 = ...; attr2 = ...; }
  #   firstAttrSet: The first set. The base. The one to be overrided by all others.
  #   attrSets: The sets that will override the first one.
  #   attrsToOverride: The atributes that should be merged between all sets
  # Normally, atributes are overrided:
  #   (Ex.: ( { a = { b = true; }; } // { a = { c = true; }; } ) -> { a = { c = true; }; }. Here, "a.b" is lost!)
  # But here, some of them are chosen to be merged:
  #   (Ex.: ( { a = { b = true; }; } // { a = { c = true; }; } ) -> { a = { b = true; c = true; }; }. Here, "a.b" is kept)
  collapseAttrs = firstAttrSet: attrSets: attrsToOverride: (
    let

      # Utils
      utils = (import ./mergeAttrs.nix);

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
              utils.mergeAttrs accumulator modifier attrsToOverride
            )
          )
        )
      ) firstAttrSet attrSets
    );
}
