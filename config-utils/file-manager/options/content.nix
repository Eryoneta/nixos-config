{ lib, ... }: { # (NixOS/Home-Manager Module)
  options = {

    # File system declaration
    content = lib.mkOption {
      type = (lib.types.oneOf [
        (lib.types.functionTo (lib.types.attrsOf (lib.types.oneOf [
          (lib.types.enum [ "symlink" "hardlink" "copy" ]) # Symlink/Hardlink
          (lib.types.path) # Symlink/Hardlink
          (lib.types.submodule (builtins.import ./content.nix)) # Directory
        ])))
        (lib.types.attrsOf (lib.types.oneOf [
          (lib.types.enum [ "symlink" "hardlink" "copy" ]) # Symlink/Hardlink/Copy
          (lib.types.path) # Symlink/Hardlink
          (lib.types.submodule (builtins.import ./content.nix)) # Directory
        ]))
        (lib.types.functionTo (lib.types.str)) # Text file
        (lib.types.str) # Text file
        # Note: "content" can have three different values:
        #   Set = Directory or Link
        #   Text = File
        # The type cannot differentiate between a link and a directory
        # A link should have "_type" and "_path"
      ]);
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

    # Scripts
    scripts = lib.mkOption {
      type = (lib.types.submodule (builtins.import ./scripts.nix));
      description = ''
      '';
      example = ''
      '';
    };

    # Method of comparison
    compareMode = lib.mkOption {
      type = (lib.types.enum [ "date" "checksum" ]);
      default = "date";
      description = ''
      '';
      example = ''
      '';
    };

    # Undeclared files
    undeclared = lib.mkOption {
      type = (lib.types.enum [ "complain" "ignore" "override" ]);
      default = "complain";
      description = ''
      '';
      example = ''
      '';
    };

  };
}
