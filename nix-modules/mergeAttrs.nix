rec {
  # MergeAttrs: ( { ...; attr = { a = true; }; }, { ...; attr = { b = true; }; }, { attr = {}; } ) -> { attr = { a = true; b = true; }; }
  #   set1, set2: The sets to merge atributes of
  #   attrsToMerge: A set which atributes are merged from the previous two sets
  #     Only sets and empty lists are considered!
  #     If a set is not empty, its atributes are recursively considered
  # Merges the defined atributes("attrsToMerge") of two given sets("set1" and "set2")
  mergeAttrs = set1: set2: attrsToMerge: (
    let

      # Get list value or [] from a set
      getListValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else []
      );

      # Get set value or {} from a set
      getSetValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else {}
      );

    in (

      # MapAttrs
      builtins.mapAttrs (
        name: value: (
          if (builtins.isList value) then (
            # MapAttrs: { attr = []; } -> { attr = (set1.attr ++ set2.attr); }
            (getListValue set1 name) ++ (getListValue set2 name)
          ) else if (builtins.isAttrs value) then (
            # MapAttrs: { attr = {}; } -> { attr = (set1.attr // set2.attr); }
            (getSetValue set1 name) // (getSetValue set2 name) // (
              if (value != {}) then (
                if (builtins.hasAttr name set1 && builtins.hasAttr name set2) then (
                  # MapAttrs: { attr = { subAttr = []; }; } -> { attr = { subAttr = (set1.attr.subAttr ++ set2.attr.subAttr); }; }
                  # MapAttrs: { attr = { subAttr = {}; }; } -> { attr = { subAttr = (set1.attr.subAttr // set2.attr.subAttr); }; }
                  mergeAttrs set1.${name} set2.${name} value
                ) else value
              ) else {}
            )
          ) else value
        )
      ) attrsToMerge

    )
  );
}
