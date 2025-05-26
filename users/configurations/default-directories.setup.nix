{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-directories" = {

    tags = [ "default-user" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # XDG Base Directory
          xdg = {
            enable = true;
            userDirs = {
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
          };

        };
      };
    };
  };
}
