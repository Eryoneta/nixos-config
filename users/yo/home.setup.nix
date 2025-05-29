{ config, ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."yo-user" = {

    # Configuration
    tags = [ "yo" ];
    includeTags = [
      "default-setup"
      "development"
      "tool"
    ];
    attr.profileIcon = config.modules."default-user".attr.profileIcon;
    attr.defaultPassword = config.modules."default-user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."default-user".attr.hashedPasswordFilePath;

    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)
        config = {

          # Profile
          home.file.".face.icon" = (attr.profileIcon config.home.username);

        };
      };
      nixos = { config, users, ... }: { # (NixOS Module)
        config = {

          # System user
          users.users = (
            let
              user = users."yo";
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
  };
}
