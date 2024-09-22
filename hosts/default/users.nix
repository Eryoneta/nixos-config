{ config, config-domain, host, ... }@args: with args.config-utils; {
    config = {

      # Users
      users.users = (
        let
          defaultPassword = with config-domain; (
            mkIf (!(mkFunc.pathExists private.secrets)) (
              "nixos"
            )
          );
          hashedPasswordFilePath = username: with config-domain; (
            mkIf (mkFunc.pathExists private.secrets) (
              config.age.secrets."${username}-userPassword".path
            )
          );
        in {
          root = {
            password = defaultPassword;
            hashedPasswordFile = (hashedPasswordFilePath "root");
          };
          ${host.user.username} = {
            description = host.user.name;
            isNormalUser = true;
            password = defaultPassword;
            hashedPasswordFile = (hashedPasswordFilePath host.user.username);
            extraGroups = [ "wheel" "networkmanager" ];
          };
        }
      );

    };
  }
