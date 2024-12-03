{ lib, config, pkgs-bundle, ... }@args: with args.config-utils; {
  
  options = {
    profile.programs.sddm = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
      options.defaults = (utils.mkDefaultsOption {
        "theme" = {
          "backgroundPath" = "";
        };
      });
    };
  };

  config = with config.profile.programs.sddm; (lib.mkIf (options.enabled) {

    # SDDM: Display Manager
    services.displayManager.sddm = {
      enable = options.enabled;
      package = (utils.mkDefault) options.packageChannel.kdePackages.sddm;

      # Wayland
      wayland.enable = (utils.mkDefault) true; # Wayland support

    };

    # Packages
    environment.systemPackages = with options.packageChannel; [
      kdePackages.sddm-kcm # SDDM-KCM: Lets KDE Plasma configure SDDM
      (writeTextDir "share/sddm/themes/breeze/theme.conf.user" (utils.toINI {
        "General" = {
          "background" = options.defaults."theme"."backgroundPath";
        };
      }))
    ];
    # To test a theme: "sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/breeze"
    #   Warning: It's just a window! It does not actually work

    # Theme
    profile.programs.sddm = {
      options.defaults = (utils.mkDefault) {
        "theme" = {
          "backgroundPath" = (
            "${pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"}"
          );
        };
      };
    };

    # User profile icons
    systemd.services."sddm-user-profile" = {
      description = "Copy or update user profiles at startup";
      wantedBy = [ "multi-user.target" ];
      before = [ "sddm.service" ];
      serviceConfig = {
        "Type" = "simple";
        "User" = "root";
      };
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
    systemd.services."sddm" = {
      after = [ "sddm-user-profile.service" ]; # "sddm-user-profile" is run before "sddm"
    };

  });

}
