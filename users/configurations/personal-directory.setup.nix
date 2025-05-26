{ ... }@args: with args.config-utils; { # (Setup Module)

  imports = [ ./default-directories.setup.nix ];

  config.modules."personal-directory" = {

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
