{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Root user
  config.modules."root" = {
    tags = [ "root" ];
    attr.defaultPassword = config.modules."user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."user".attr.hashedPasswordFilePath;
    setup = { attr }: {
      nixos = { config, ... }: { # (NixOS Module)

        # System user
        config.users.users = (
          let
            username = "root";
          in {
            "${username}" = {
              password = attr.defaultPassword;
              hashedPasswordFile = (attr.hashedPasswordFilePath (
                (config.age.secrets."${username}-userPassword".path or "") # (agenix option)
              ));
            };
          }
        );

      };
    };
  };

}
