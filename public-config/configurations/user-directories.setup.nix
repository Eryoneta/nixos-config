{ ... }@args: with args.config-utils; { # (Setup Module)

  # User directories
  config.modules."user-directories" = {
    tags = [ "basic-setup" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # XDG Base Directory
        config.xdg = {
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

  # Personal directory
  config.modules."personal-directory" = {
    tags = [ "yo" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # XDG Base Directory
        config.xdg = {
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

}
