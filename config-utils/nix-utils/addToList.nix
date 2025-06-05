nix-lib: {
  # AddToList
  /*
    - Adds a element to a list before/after a given element
      - "addToList.before": Before the given element
      - "addToList.after": After the given element
  */
  addToList = (
    let
      addToList = operation: elem: list: (
        nix-lib.pipe list [

          # Transforms each item into a list, and calls "operation" for the chosen element
          (x: builtins.map (element: (
            if (element == elem) then (
              operation element
            ) else (
              [ element ]
            )
          )) x)

          # Transforms the list of lists into a single list
          (x: builtins.concatLists x)

        ]
      );
    in {

      # AddToList-Before
      /*
        - Adds a element to a list before a given element
          - "content": The value to add
          - "elem": The element to consider
          - "list": The list to add to
        - Warning: All elements that matches "elem" will have "content" added before!
      */
      before = content: elem: list: (
        addToList (value: (
          [ content value ]
        )) elem list
      );

      # AddToList-After
      /*
        - Adds a element to a list after a given element
          - "content": The value to add
          - "elem": The element to consider
          - "list": The list to add to
        - Warning: All elements that matches "elem" will have "content" added after!
      */
      after = content: elem: list: (
        addToList (value: (
          [ value content ]
        )) elem list
      );

    }
  );
}
