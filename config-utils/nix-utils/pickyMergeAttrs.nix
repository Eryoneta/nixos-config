rec {
  # PickyMergeAttrs
  /*
    - Merges defined atributes("attrsToMerge") of two given sets("set1" and "set2")
      - "set1": The first set
      - "set2": The second set. It overrides the first
      - "attrsToMerge": A set that defines which atributes are merged from the previous two sets
        - Only sets and empty lists are considered!
        - If a set is not empty, its atributes are recursively considered
    - Basically, "attrsToMerge" has all its atributes filled from values of "set1" and "set2"
    - Note:
      - Here, "{ a = { b = "B";}; } // { a = {}; }" results in "a.b" being overriden
      - But here, "lib.recursiveUpdate { a = { b = "B";}; } { a = {}; }" results in "a.b" NOT being overriden
      - There is no choice in which set gets merged and which are overriden
      - "pickyMergeAttrs" allows that
  */
  pickyMergeAttrs = set1: set2: attrsToMerge: (
    let

      # Get a value or [] from a set
      getListValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else []
      );

      # Get a value or {} from a set
      getSetValue = set: attrName: (
        if (builtins.hasAttr attrName set) then set.${attrName} else {}
      );

      # Merges two lists
      mergeLists = set1: set2: listName: (
        (getListValue set1 listName) ++ (getListValue set2 listName)
      );

      # Merges two sets
      mergeSets = set1: set2: setName: (
        (getSetValue set1 setName) // (getSetValue set2 setName)
      );

    in (

      # PickyMergeAttrs
      # It uses 'attrsToMerge' to create the final set
      builtins.mapAttrs (attrName: attrValue: (

        # If it's a list
        if (builtins.isList attrValue) then (
          # Having found a list, the value is the lists from 'set1' and 'set2' merged
          # { attr = []; } -> { attr = (set1.attr ++ set2.attr); }
          (mergeLists set1 set2 attrName)
        ) else (

          # If it's a set
          if (builtins.isAttrs attrValue) then (
            # Having found a set, the value is the sets from 'set1' and 'set2' merged
            # { attr = {}; } -> { attr = (set1.attr // set2.attr); }
            (mergeSets set1 set2 attrName) // (

              # If this set from 'attrsToMerge' is not empty, recurse into it
              if (attrValue != {}) then (
                # Before, check if 'set1' and 'set2' have the set
                if (builtins.hasAttr attrName set1 && builtins.hasAttr attrName set2) then (
                  # Do a recursion
                  # { attr = { subAttr = []; }; } -> { attr = { subAttr = (set1.attr.subAttr ++ set2.attr.subAttr); }; }
                  # or
                  # { attr = { subAttr = {}; }; } -> { attr = { subAttr = (set1.attr.subAttr // set2.attr.subAttr); }; }
                  pickyMergeAttrs set1.${attrName} set2.${attrName} attrValue
                ) else attrValue
              ) else attrValue

            )
          ) else (

            # If it's neither
            attrValue

          )

        )

      )) attrsToMerge

    )
  );
}
