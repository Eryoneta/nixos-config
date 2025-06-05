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
            hashedFilePath = config.age.secrets."${username}-userPassword".path or null; # (agenix option)
          in {
            "${username}" = {
              password = (attr.defaultPassword username hashedFilePath);
              hashedPasswordFile = (attr.hashedPasswordFilePath username hashedFilePath);
            };
          }
        );

      };
    };
  };

}
