{ config, ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."root-user" = {

    # Configuration
    tags = [ "root" ];
    attr.defaultPassword = config.modules."default-user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."default-user".attr.hashedPasswordFilePath;

    setup = { attr }: {
      nixos = { config, ... }: { # (NixOS Module)
        config = {

          # System user
          users.users = (
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
  };
}
