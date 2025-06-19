{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Yo user
  config.modules."yo" = {
    tags = [ "yo" ];
    includeTags = [
      "personal-setup"
      "developer-setup"
      "sysdev-setup"
    ];
    attr.profileIcon = config.modules."user".attr.profileIcon;
    attr.defaultPassword = config.modules."user".attr.defaultPassword;
    attr.hashedPasswordFilePath = config.modules."user".attr.hashedPasswordFilePath;
    attr.firefox-devedition.packageChannel = config.modules."firefox-devedition".attr.packageChannel;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Profile
        config.home.file.".face.icon" = (attr.profileIcon config.home.username);

        # Variables
        config.home.sessionVariables = {
          "DEFAULT_BROWSER" = with attr.firefox-devedition; (
            "${packageChannel.firefox-devedition}/bin/firefox" # Default Browser
          );
        };

        # Personal directory
        config.xdg.userDirs.extraConfig = {
          "XDG_PERSONAL_DIR" = "${config.home.homeDirectory}/Personal";
        };

      };
      nixos = { config, users, ... }: { # (NixOS Module)

        # System user
        config.users.users = (
          let
            user = users."yo";
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
              ];
            };
          }
        );

      };
    };
  };

}
