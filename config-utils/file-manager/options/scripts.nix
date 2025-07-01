{ lib, ... }: { # (NixOS/Home-Manager Module)
  options = {

    # Script executed after creating a file
    onCreate = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

    # Script executed after modifying a file
    onModify = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

    # Script executed after deleting a file
    onDelete = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
      '';
      example = ''
      '';
    };

  };
}
