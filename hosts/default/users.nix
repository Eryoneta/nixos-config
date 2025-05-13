{ config, ... }@args: with args.config-utils; {
    config = {

      # Users
      users.users = (
        let
          hashedFilePath = username: config.age.secrets."${username}-userPassword".path or null; # (Agenix secret)
          defaultPassword = username: with args.config-domain; (
            # Check for "./private-config/secrets"
            utils.mkIf (!(utils.pathExists private.secrets) || (hashedFilePath username) == null) (
              "nixos"
            )
          );
          hashedPasswordFilePath = username: with args.config-domain; (
            # Check for "./private-config/secrets"
            utils.mkIf (utils.pathExists private.secrets && (hashedFilePath username) != null) (
              hashedFilePath username
            )
          );
        in (utils.pipe (utils.attrsToList args.hostArgs.users) [
          # Set the value of each user to be a valid configuration
          (x: builtins.map (user: {
            name = "${user.username}";
            value = {
              description = user.name;
              isNormalUser = true;
              password = (defaultPassword user.username);
              hashedPasswordFile = (hashedPasswordFilePath user.username);
              extraGroups = [ "wheel" "networkmanager" ];
            };
          }) x)

          # Merge all items into a single set
          (x: builtins.listToAttrs x)
          
          # Add root user configuration
          (x: x // {
            root = {
              password = (defaultPassword "root");
              hashedPasswordFile = (hashedPasswordFilePath "root");
            };
          })
        ])
      );

    };
  }
