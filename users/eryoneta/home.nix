{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Eryoneta user
  config.modules."eryoneta" = {
    attr.profileIcon = config.modules."user".attr.profileIcon;
    attr.defaultPassword = config.modules."user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."user".attr.hashedPasswordFilePath;
    tags = [ "eryoneta" ];
    includeTags = [ "default-setup" ];
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Profile
        config.home.file.".face.icon" = (attr.profileIcon config.home.username);

      };
      nixos = { config, users, ... }: { # (NixOS Module)

        # System user
        config.users.users = (
          let
            user = users."eryoneta";
            hashedFilePath = config.age.secrets."${user.username}-userPassword".path or null; # (agenix option)
          in {
            "${user.username}" = {
              description = user.name;
              isNormalUser = true;
              password = (attr.defaultPassword user.username hashedFilePath);
              hashedPasswordFile = (attr.hashedPasswordFilePath user.username hashedFilePath);
              extraGroups = [ "wheel" "networkmanager" ];
            };
          }
        );

      };
    };
  };

}
