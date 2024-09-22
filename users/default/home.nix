{ config, user, ... }@args: with args.config-utils; {

  imports = [
    ./programs.nix
    ./variables.nix
    ./xdg-base-directory.nix
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

  };
}
