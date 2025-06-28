{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # User home
  config.modules."user-home.personal" = {
    tags = [ "personal-setup" ];
    setup = {
      home = { config, ... }: { # (Home-Manager Module)

        # Personal directory
        config.xdg.userDirs.extraConfig = {
          "XDG_PERSONAL_DIR" = "${config.home.homeDirectory}/Personal";
        };

      };
    };
  };

}
