{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."yo-user" = {

    # Configuration
    tags = [ "yo" ];
    includeTags = [ "default-setup" ];

    setup = {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Profile
          home.file.".face.icon" = with args.config-domain; {
            # Check for "./private-config/resources"
            enable = (utils.pathExists private.resources);
            source = with private; (
              "${resources}/profiles/${config.home.username}/.face.icon"
            );
          };

        };
      };
    };
  };
}
