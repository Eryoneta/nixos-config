{ config, user, ... }@args: with args.config-utils; {

  imports = [
    ./programs.nix
    ./variables.nix
    ./stylix.nix
    ./xdg-base-directory.nix
    ./xdg-mime-apps.nix
    ./xdg-desktop-entries.nix
  ];

  options = {
    hardware.configuration.screensize = {
      baseWidth = utils.mkIntOption 1366;
      baseHeigth = utils.mkIntOption 768;
      horizontalBars = utils.mkIntListOption [];
      verticalBars = utils.mkIntListOption [];
    };
  };

  config = {

    # Screen size
    lib.hardware.configuration.screensize = with config.hardware.configuration.screensize; {
      width = builtins.foldl' (
        x: y: x - y
      ) baseWidth horizontalBars;
      height = builtins.foldl' (
        x: y: x - y
      ) baseHeigth verticalBars;
    };

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

    # Home-Manager News
    # A necessary file to run "home-manager news"
    xdg.configFile."home-manager/home.nix" = {
      text = ''
        {
          home.username = "${config.home.username}";
          home.homeDirectory = "${config.home.homeDirectory}";
          home.stateVersion = "${config.home.stateVersion}";
        }
      '';
    };

  };
}
