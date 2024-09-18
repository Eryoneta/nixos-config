{ config, user, ... }@args: with args.config-utils; {

  imports = [
    ./programs.nix
    ./xdg-base-directory.nix
    ./variables.nix
  ];

  config = {

    # Home-Manager
    home = {

      # User
      username = user.username;
      homeDirectory = "/home/${user.username}";

      # Start version
      stateVersion = "24.05"; # Home-Manager start version. (Default options).

    };

    # AutoInstall command "home-manager"
    # Only works for standalone!
    # As a module, it needs to be included at "environment.systemPackages"
    programs.home-manager.enable = true;

    # XDG Base Directory
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
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
}
