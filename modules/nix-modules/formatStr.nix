nix-lib: {
  # formatStr: "Configuration of João, today" -> "Configuration_of_Joao._today"
  #   text: The text to be formatted
  # Formats a text so that it can be used safely
  #   Very useful for the option "config.system.nixos.label"!
  formatStr = text: (
    let

      # All accepted characters and their respective valid counterparts
      # Ex.: " " -> "_", as space is not allowed
      characterMap = {
        " " = "_";
        "_" = "_";
        "-" = "-";
        ":" = ":";
        "." = ".";
        "," = ".";
        "0" = "0";
        "1" = "1";
        "2" = "2";
        "3" = "3";
        "4" = "4";
        "5" = "5";
        "6" = "6";
        "7" = "7";
        "8" = "8";
        "9" = "9";
        "a" = "a"; "A" = "A";
        "b" = "b"; "B" = "B";
        "c" = "c"; "C" = "C";
        "d" = "d"; "D" = "D";
        "e" = "e"; "E" = "E";
        "f" = "f"; "F" = "F";
        "g" = "g"; "G" = "G";
        "h" = "h"; "H" = "H";
        "i" = "i"; "I" = "I";
        "j" = "j"; "J" = "J";
        "k" = "k"; "K" = "K";
        "l" = "l"; "L" = "L";
        "m" = "m"; "M" = "M";
        "n" = "n"; "N" = "N";
        "o" = "o"; "O" = "O";
        "p" = "p"; "P" = "P";
        "q" = "q"; "Q" = "Q";
        "r" = "r"; "R" = "R";
        "s" = "s"; "S" = "S";
        "t" = "t"; "T" = "T";
        "u" = "u"; "U" = "U";
        "v" = "v"; "V" = "V";
        "w" = "w"; "W" = "W";
        "x" = "x"; "X" = "X";
        "y" = "y"; "Y" = "Y";
        "z" = "z"; "Z" = "Z";
        accentedChars = {
          "ç" = "c"; "Ç" = "C";
          "ñ" = "n"; "Ñ" = "N";
          "á" = "a"; "Á" = "A";
          "à" = "a"; "À" = "A";
          "ã" = "a"; "Ã" = "A";
          "â" = "a"; "Â" = "A";
          "ä" = "a"; "Ä" = "A";
          "é" = "e"; "É" = "E";
          "è" = "e"; "È" = "E";
          "ẽ" = "e"; "Ẽ" = "E";
          "ê" = "e"; "Ê" = "E";
          "ë" = "e"; "Ë" = "E";
          "í" = "i"; "Í" = "I";
          "ì" = "i"; "Ì" = "I";
          "ĩ" = "i"; "Ĩ" = "I";
          "î" = "i"; "Î" = "I";
          "ï" = "i"; "Ï" = "I";
          "ó" = "o"; "Ó" = "O";
          "ò" = "o"; "Ò" = "O";
          "õ" = "o"; "Õ" = "O";
          "ô" = "o"; "Ô" = "O";
          "ö" = "o"; "Ö" = "O";
          "ú" = "u"; "Ú" = "U";
          "ù" = "u"; "Ù" = "U";
          "ũ" = "u"; "Ũ" = "U";
          "û" = "u"; "Û" = "U";
          "ü" = "u"; "Ü" = "U";
        };
      };

      # Character that replaces non-valid characters
      replacementChar = "-";

      # Replace Invalid Characters
      # Makes sure to only allow allowed characters. Others are replaced with 'replacementChar'
      replaceInvalidChars = text: (
        # StringAsChars: "A B!" -> "${characterMap."A"}${characterMap." "}${characterMap."B"}-" -> "A_B-"
        nix-lib.strings.stringAsChars (
          char: (
            if (builtins.hasAttr "${char}" characterMap) then
              characterMap."${char}"
            else replacementChar
          )
        ) text
      );

      # Replace Accented Characters
      # Accented chars are actually multiple characters! Thus, stringAsChars can't understand them
      replaceAccentedChars = text: (
        let
          accentedCharsList = (builtins.attrNames characterMap.accentedChars);
          validCharsList = (builtins.map (char: characterMap.accentedChars."${char}") accentedCharsList);
        in (
          # ReplaceStrings: [ "ã" ] [ "a" ] "cão" -> "cao"
          builtins.replaceStrings accentedCharsList validCharsList text
        )
      );

    in (
      # Format string
      replaceInvalidChars (replaceAccentedChars text)
    )
  );
}
