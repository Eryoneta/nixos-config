{
  # AddToList
  /*
    - Adds a element to a list before/after a given element
      - "addToList.before": Before the given element
      - "addToList.after": After the given element
  */
  addToList = (
    let
      addToList = func: elem: list: (
        # ConcatLists: [ [ "value1" ] [ "newValue" "value2" ] ] -> [ "value1" "newValue" "value2" ]
        builtins.concatLists (
          # Map: [ "value1" "value2" ] -> [ [ "value1" ] [ "newValue" "value2" ] ]
          builtins.map (
            value: (
              if (value == elem) then (
                func value
              ) else (
                [ value ]
              )
            )
          ) list
        )
      );
    in {

      # AddToList.Before: ("B" "C" [ "A" "C" ] ) -> [ "A" "B" "C" ]
      /*
        - Adds a element to a list before a given element
          - "content": The value to add
          - "elem": The element to consider
          - "list": The list to add to
        - Warning: All elements that matches "elem" will have "content" added before!
      */
      before = content: elem: list: (
        addToList (
          value: [ content value ]
        ) elem list
      );

      # AddToList.After: ("B" "A" [ "A" "C" ] ) -> [ "A" "B" "C" ]
      /*
        - Adds a element to a list after a given element
          - "content": The value to add
          - "elem": The element to consider
          - "list": The list to add to
        - Warning: All elements that matches "elem" will have "content" added after!
      */
      after = content: elem: list: (
        addToList (
          value: [ value content ]
        ) elem list
      );

    }
  );
}
