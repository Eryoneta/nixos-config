rec {
  # MergeAttrs: ({ a = "A"; attr = { a = true; }; }, { b = "B"; attr = { b = true; }; }, { attr = {}; })
  #   -> { a = "A"; b = "B"; attr = { a = true; b = true; }; }
  /*
    - Merges defined atributes("attrsToMerge") of two given sets("set1" and "set2")
      - Normally, merging sets results in subsets being overridden
      - "set1": The first set
      - "set2": The second set. It overrides the first
      - "attrsToMerge": A set that defines which atributes are merged from the previous two sets
        - Only sets and empty lists are considered!
        - If a set is not empty, its atributes are recursively considered
    - Basically, "attrsToMerge" has all its atributes filled from values of "set1" and "set2"
  */
  mergeAttrs = set1: set2: attrsToMerge: (
    let

      # Get a value or [] from a set
      getListValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else []
      );

      # Get a value or {} from a set
      getSetValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else {}
      );

    in (

      # MapAttrs
      builtins.mapAttrs (
        name: value: (

          # If its a list
          if (builtins.isList value) then (
            # MapAttrs: { attr = []; } -> { attr = (set1.attr ++ set2.attr); }
            (getListValue set1 name) ++ (getListValue set2 name)
          ) else (

            # If its a set
            if (builtins.isAttrs value) then (
              # MapAttrs: { attr = {}; } -> { attr = (set1.attr // set2.attr); }
              (getSetValue set1 name) // (getSetValue set2 name) // (
                # Recursion
                if (value != {}) then (
                  if (builtins.hasAttr name set1 && builtins.hasAttr name set2) then (
                    # MapAttrs: { attr = { subAttr = []; }; } -> { attr = { subAttr = (set1.attr.subAttr ++ set2.attr.subAttr); }; }
                    # or
                    # MapAttrs: { attr = { subAttr = {}; }; } -> { attr = { subAttr = (set1.attr.subAttr // set2.attr.subAttr); }; }
                    mergeAttrs set1.${name} set2.${name} value
                  ) else value
                ) else {}
              )
            ) else (

              # If its neither
              value

            )

          )

        )
      ) attrsToMerge

    )
  );
}
