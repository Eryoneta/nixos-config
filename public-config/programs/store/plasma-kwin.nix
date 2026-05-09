{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # KWin: Window manager for Plasma
  config.modules."plasma-kwin" = {
    tags = config.modules."plasma".tags;
    attr.activities = { list ? [], startId ? "" }: (
      let
        activityIds = (
          builtins.listToAttrs (builtins.map (
            activity: {
              name = activity.id;
              value = {
                name = activity.name;
                icon = activity.icon;
              };
            }
          ) (builtins.attrValues list))
        );
      in {
        "activities" = (
          builtins.mapAttrs (activityId: activity: (
            activity.name
          )) activityIds
        );
        "activities-icons" = (
          builtins.mapAttrs (activityId: activity: (
            activity.icon
          )) activityIds
        );
        "main" = {
          "currentActivity" = startId;
        };
      }
    );
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.plasma.kwin = { # (plasma-manager option)

          # Windows
          borderlessMaximizedWindows = (utils.mkDefault) false; # Show borders even when full size
          titlebarButtons = {
            left = (utils.mkDefault) [
              "keep-above-windows"
            ];
            right = (utils.mkDefault) [
              "minimize"
              "maximize"
              "close"
            ];
          };

          # Barriers
          cornerBarrier = (utils.mkDefault) false; # Do not stop cursor from crossing screens at corners
          edgeBarrier = (utils.mkDefault) 0; # Extra space between screens

          # Virtual desktops
          virtualDesktops.names = (utils.mkDefault) [ # List of virtual desktops
            "Main Desktop"
            "Secondary Desktop"
          ];

          # Effects
          effects = {
            desktopSwitching.animation = (utils.mkDefault) "slide"; # Virtual desktop animation
            minimization.animation = (utils.mkDefault) "squash"; # Minimzation animation
            windowOpenClose.animation = (utils.mkDefault) "glide"; # Open/Close window animation
            shakeCursor.enable = (utils.mkDefault) true; # Shaking the cursor increase its size
            dimAdminMode.enable = (utils.mkDefault) true; # Dim screen when requesting root privileges
            dimInactive.enable = (utils.mkDefault) true; # Dim inactive screens
          };

          # Night light
          nightLight = {
            enable = (utils.mkDefault) true;
            mode = (utils.mkDefault) "times"; # Chenge by time
            temperature = {
              day = (utils.mkDefault) 6500; # Day light temperature
              night = (utils.mkDefault) 4500; # Night light temperature
            };
            time = {
              morning = (utils.mkDefault) "07:45"; # Morning time
              evening = (utils.mkDefault)  "18:45"; # Night time
            };
            transitionTime = (utils.mkDefault) 30; # Time in minutes for the transition
          };

        };

        # Dotfile: Activities
        # Note: Old activities are not removed
        config.programs.plasma.configFile."kactivitymanagerdrc" = ( # (plasma-manager option)
          (utils.mkDefault) (attr.activities rec {
            list = { # Note: The final result is alfabetically ordered
              "main" = {
                id = "main-activity";
                name = "Main Activity";
                icon = "nix-snowflake-white";
              };
              "secondary" = {
                id = "secondary-activity";
                name = "Secondary Activity";
                icon = "kde-symbolic";
              };
            };
            startId = list."main".id;
          })
        );

        # Dotfile: Virtual desktops
        config.programs.plasma.configFile."kwinrc" = { # (plasma-manager option)
          "Desktops" = {
            "Rows" = 1; # Order in a singular row
          };
          "Windows" = {
            "ElectricBorders" = 1; # Move between virtual desktops only when dragging a window
            "ElectricBorderDelay" = 350; # Delay in ms before the border action running
            "ElectricBorderCooldown" = 1000; # Delay in ms before doing another action
          };
          "Plugins" = {
            "screenedgeEnabled" = false; # Disable the glow effect from screen edges
          };
        };

      };
    };
  };

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
            "Extra Desktop"
            "Primary Desktop"
            "Auxiliary Desktop"
          ];

        };

        # Autostart: Set the virtual desktop to be the middle one
        # Note: This allows to move windows either to the left or to the right, when moving between VirtDesks
        config.xdg.configFile."autostart/pick-middle-virtual-desktop.desktop" = {
          text = utils.toINI {
            "Desktop Entry" = {
              "Name" = "Use Middle Virtual Desktop";
              "Icon" = "dialog-scripts-symbolic";
              "Exec" = (
                let
                  desktopIndex = "2";
                in ''
                  qdbus org.kde.kglobalaccel /VirtualDesktopManager org.kde.KWin.VirtualDesktopManager.current "Desktop_${desktopIndex}"
                ''
              );
              "Type" = "Application";
              "Terminal" = false;
            };
          };
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
