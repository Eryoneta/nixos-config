{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Eryoneta user
  config.modules."eryoneta" = {
    tags = [ "eryoneta" ];
    includeTags = [
      "work-setup"
      "developer-setup"
    ];
    attr.profileIcon = config.modules."user".attr.profileIcon;
    attr.defaultPassword = config.modules."user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."user".attr.hashedPasswordFilePath;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Profile
        config.home.file.".face.icon" = (attr.profileIcon config.home.username);

        # Variables
        config.home.sessionVariables = {};

      };
      nixos = { config, users, ... }: { # (NixOS Module)

        # System user
        config.users.users = (
          let
            user = users."eryoneta";
          in {
            "${user.username}" = {
              description = user.name;
              isNormalUser = true;
              password = attr.defaultPassword;
              hashedPasswordFile = (attr.hashedPasswordFilePath (
                (config.age.secrets."${user.username}-userPassword".path or "") # (agenix option)
              ));
              extraGroups = [
                "wheel" # Can use commands with sudo
                "networkmanager" # Can change networking settings
                "adbusers" # Can debug Android devices
                "scanner" "lp" # Can use the scanner or scanner&printer
              ];
            };
          }
        );

      };
    };
  };

}
