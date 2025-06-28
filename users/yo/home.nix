{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

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
    attr.includedModules = config.includedModules;
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Assert the presence of the default apps
        config.assertions = [
          {
            assertion = (attr.includedModules."firefox-devedition" or false);
            message = "The configuration of session variables for \"${config.home.username}\" requires the module \"firefox-devedition\" to be included";
          }
        ];

        # Profile
        config.home.file.".face.icon" = (attr.profileIcon config.home.username);

        # Variables
        config.home.sessionVariables = {
          "DEFAULT_BROWSER" = with attr.firefox-devedition; (
            "${packageChannel.firefox-devedition}/bin/firefox" # Default Browser
          );
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
                "adbusers" # Can debug Android devices
              ];
            };
          }
        );

      };
    };
  };

}
