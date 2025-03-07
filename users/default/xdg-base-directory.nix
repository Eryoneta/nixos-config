{ config, ... }@args: with args.config-utils; {
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
          extraConfig = {
            "XDG_PERSONAL_DIR" = "${homePath}/Personal";
          };
        }
      );
    };

  };
}
