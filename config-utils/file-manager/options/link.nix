{ lib, ... }: { # (NixOS/Home-Manager Module)
  options = {

    # Symlink type
    _type = lib.mkOption {
      type = (lib.types.enum [ "symlink" "hardlink" ]);
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

    # Symlink path
    _path = lib.mkOption {
      type = lib.types.path;
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

  };
}
