{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; { # (Setup Module)

  # SDDM: Display Manager
  config.modules."sddm+theme" = {
    tags = [ "default-setup" ];
    attr.packageChannel = config.modules."sddm".attr.packageChannel;
    attr.backgroundPath = with config-domain; (
      # Check for "./private-config/programs"
      if ((utils.pathExists private.programs) && config.includedModules."sddm+theme.personal") then (
        config.modules."sddm+theme.personal".attr.backgroundPath # Uses a attr defined by another module
      ) else (
        "${pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"}" # Default background image
      )
    );
    setup = { attr }: {
      nixos = { # (NixOS Module)

        # Packages
        config.environment.systemPackages = with attr.packageChannel; [
          kdePackages.sddm-kcm # SDDM-KCM: Lets KDE Plasma configure SDDM
          (writeTextDir "share/sddm/themes/breeze/theme.conf.user" (utils.toINI {
            "General" = {
              "background" = (attr.backgroundPath);
            };
          }))
        ];
        # To test a theme: "sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/breeze"
        #   Note: It's just a fullscreen window! It does not actually work

        # User profile icons
        config.systemd.services."sddm-user-profile" = {
          description = "Copy or update user profiles at startup";
          serviceConfig = {
            "Type" = "simple";
            "User" = "root";
          };
          wantedBy = [ "multi-user.target" ];
          before = [ "sddm.service" ];
          script = ''
            set -eu
            for user in /home/*; do
              username=$(basename "$user")
              # If there is a profile present
              if [ -f "$user/.face.icon" ]; then
                # If there is not a profile copied
                if [ ! -f "/var/lib/AccountsService/icons/$username" ]; then
                  # Copy it
                  cp "$user/.face.icon" "/var/lib/AccountsService/icons/$username"
                else
                  # If profile was modified (Is newer than its copy)
                  if [ "$user/.face.icon" -nt "/var/lib/AccountsService/icons/$username" ]; then
                    # Copy it
                    cp "$user/.face.icon" "/var/lib/AccountsService/icons/$username"
                  fi
                fi
              fi
            done
          '';
        };
        config.systemd.services."sddm" = {
          after = [ "sddm-user-profile.service" ]; # "sddm-user-profile" is run before "sddm"
        };

      };
    };
  };

}
