{ lib, ... }: { # (NixOS/Home-Manager Module)
  options = {

    # File-Manager
    file-manager = lib.mkOption {
      type = (lib.types.submodule {
        options = {

          # Enabler
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
            '';
            example = ''
            '';
          };

          # Output
          output = lib.mkOption {
            type = lib.types.lines;
            readOnly = true;
            description = ''
            '';
          };

          # Autoload via NixOS/Home-Manager activation script
          autoload = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
            '';
            example = ''
            '';
          };

          # Base path
          baseDirectory = lib.mkOption {
            type = lib.types.path;
            default = "";
            description = ''
            '';
            example = ''
            '';
          };

          # File system declaration
          fileSystem = lib.mkOption {
            type = (lib.types.oneOf [
              (lib.types.functionTo (lib.types.submodule (builtins.import ./options/content.nix))) # Directory
              (lib.types.submodule (builtins.import ./options/content.nix)) # Directory
              (lib.types.submodule (builtins.import ./options/link.nix)) # Symlink/Hardlink
              lib.types.str # Text file
            ]);
            default = {};
            description = ''
            '';
            example = ''
            '';
          };

        };
      });
      default = {};
      description = ''
      '';
      example = ''
      '';
    };

  };
}
