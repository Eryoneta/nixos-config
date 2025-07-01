{ lib, ... }: { # (NixOS/Home-Manager Module)
  options = {

    # File system declaration
    content = lib.mkOption {
      type = (lib.types.oneOf [
        (lib.types.functionTo (lib.types.attrsOf (lib.types.submodule (builtins.import ./content.nix)))) # Directory
        (lib.types.attrsOf (lib.types.submodule (builtins.import ./content.nix))) # Directory
        (lib.types.submodule (builtins.import ./link.nix)) # Symlink/Hardlink
        lib.types.str # Text file
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
