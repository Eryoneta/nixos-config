{ ... }@args: with args.config-utils; { # (Setup Module)

  config.modules."basic-directories" = {

    # Configuration
    tags = [ "basic-setup" ];

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

  config.modules."personal-directory" = {

    # Configuration
    tags = [ "yo" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # XDG Base Directory
          xdg = {
            userDirs = (
              let
                homePath = config.home.homeDirectory;
              in {
                extraConfig = {
                  "XDG_PERSONAL_DIR" = "${homePath}/Personal";
                };
              }
            );
          };

        };
      };
    };
  };

}
