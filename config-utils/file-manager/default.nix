{
  nixosModules.file-manager = ({ config, lib, ... }: { # (NixOS Module)
    imports = [
      ./config.nix
      ./options.nix
    ];
    config.system.activationScripts = lib.mkIf (config.file-manager.enable && config.file-manager.autoload) {
      "declareFiles" = (lib.stringAfter [ "etc" ] (
        config.file-manager.output
      ));
      # Note: Executed after the declaration of "/etc"
    };
  });
  homeModules.file-manager = ({ config, lib, ... }: { # (Home-Manager Module)
    imports = [
      ./config.nix
      ./options.nix
    ];
    config.home.activation = lib.mkIf (config.file-manager.enable && config.file-manager.autoload) {
      "declareFiles" = (lib.hm.dag.entryAfter [ "writeBoundary" ] (
        config.file-manager.output
      ));
      # Note: Executed after "writeBoundary" as it creates files and directories
    };
  });
}
