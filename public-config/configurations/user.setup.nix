{ config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # User
  config.modules."user" = {
    attr.profileIcon = username: (with config-domain; { # Requires "resources/profiles/USERNAME/.face.icon" to exist!
      # Check for "./private-config/resources"
      enable = (utils.pathExists private.resources);
      source = with private; (
        "${resources}/profiles/${username}/.face.icon"
      );
    });
    attr.defaultPassword = username: hashedFilePath: (with config-domain; ( # Sets a default password if there is no hashedFile
      # Check for "./private-config/secrets"
      utils.mkIf (!(utils.pathExists private.secrets) || hashedFilePath == null) (
        "nixos"
      )
    ));
    attr.hashedPasswordFilePath = username: hashedFilePath: (with config-domain; ( # Uses a hashedFile if it exists
      # Check for "./private-config/secrets"
      utils.mkIf ((utils.pathExists private.secrets) && hashedFilePath != null) (
        hashedFilePath
      )
    ));
  };

}
