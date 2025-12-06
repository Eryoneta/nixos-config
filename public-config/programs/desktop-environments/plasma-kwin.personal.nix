{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # KWin: Window manager for Plasma
  config.modules."plasma-kwin.personal" = {
    tags = config.modules."plasma.personal".tags;
    attr.activities = config.modules."plasma-kwin".attr.activities;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.kwin = { # (plasma-manager option)

          # Dotfile: Virtual desktops
          virtualDesktops.names = [ # List of virtual desktops
            "Primary Desktop"
            "Auxiliary Desktop"
            "Extra Desktop"
          ];

        };

        # Dotfile: Activities
        # Note: Old activities are not removed
        config.programs.plasma.configFile."kactivitymanagerdrc" = ( # (plasma-manager option)
          attr.activities rec {
            list = { # Note: The final result is alfabetically ordered
              "personal" = {
                id = "personal-activity";
                name = "Personal Activity";
                icon = "nix-snowflake-white";
              };
              "public" = {
                id = "public-activity";
                name = "Public Activity";
                icon = "avatar-default-symbolic";
              };
            };
            startId = list."personal".id;
          }
        );

        # Dotfile: Favorites
        # Note: This does not work!
        #   "/home/USERNAME/.config/kactivitymanagerd-statsrc" needs to be manually tweaked
        config.programs.plasma.configFile."kactivitymanagerd-statsrc" = ( # (plasma-manager option)
          let
            appList = [
              "applications:chromium-browser.desktop" # Chromium
              "applications:steam.desktop" # Steam
              "applications:org.pulseaudio.pavucontrol.desktop," # PulseAudio
              "applications:com.github.wwmm.easyeffects.desktop" # Easy Effects
              "applications:io.missioncenter.MissionCenter.desktop" # Mission Center
              "applications:onboard.desktop" # OnBoard
              "applications:org.kde.kwrite.desktop" # KWrite
              "applications:io.github.Qalculate.qalculate-qt.desktop" # Qalculate
              "applications:org.kde.krita.desktop" # Krita
              "applications:org.kde.kolourpaint.desktop" # KolourPaint
              "applications:org.bunkus.mkvtoolnix-gui.desktop" # MKVToolNix
            ];
          in {
            "Favorites-org.kde.plasma.kickoff.favorites.instance-RANDOM_ID-global" = {
              ordering = (utils.joinStr "," appList);
            };
          }
        );

      };
    };
  };

}
