{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # User Home
  config.modules."user-home" = {
    tags = [ "default-setup" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # XDG Specification
        config.xdg.enable = true;

        # XDG Base Directory
        config.xdg.userDirs = {
          enable = true;
          createDirectories = true; # Auto-create directories
        } // (
          let
            homePath = config.home.homeDirectory;
          in {
            desktop = "${homePath}/Área de Trabalho";
            documents = "${homePath}/Documentos";
            download = "${homePath}/Downloads";
            music = "${homePath}/Músicas";
            pictures = "${homePath}/Imagens";
            videos = "${homePath}/Vídeos";
            publicShare = "${homePath}/Público";
            templates = "${homePath}/Modelos";
          }
        );

        # XDG Desktop Entries
        config.xdg.desktopEntries = {

          # Hide "NixOS Manual" entry
          "nixos-manual" = {
            name = "NixOS Manual";
            exec = "nixos-help";
            noDisplay = true;
          };

        };

      };
    };
  };

}
