{ ... }@args: with args.config-utils; { # (Setup Module)

  # Plasma: A Desktop Environment focused on customization
  config.modules."plasma+yo" = {
    tags = [ "yo" ];
    setup = {
      home = { config, pkgs-bundle, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.plasma = { # (plasma-manager option)

          # Workspace
          workspace = {
            # Behaviour
            enableMiddleClickPaste = false; # Do not paste with middle-click (Too many accidents!)
            # Cursor
            cursor = {
              theme = null; # Managed by Stylix
              size = null; # Managed by Stylix
            };
            # Wallpaper
            wallpaper = null; # Managed by Stylix
            wallpaperFillMode = null; # Managed by Stylix
            # Themes
            theme = null; # Managed by Stylix
            lookAndFeel = null; # Managed by Stylix
            colorScheme = null; # Managed by Stylix
            iconTheme = "Papirus-Colors-Dark"; # Icons theme
            soundTheme = "Ocean"; # Sound theme
          };

          # Mouse
          input.mice = [
            {
              enable = true;
              accelerationProfile = "none"; # Do not accelerate mouse
              acceleration = 1.00; # Max speed
              leftHanded = false; # Right handed
              middleButtonEmulation = false; # Left + Right should do nothing
              scrollSpeed = 1.0; # It's actually: "defaultSpeed * scrollSpeed"
              # Found in "/proc/bus/input/devices"
              name = "Gaming Mouse";
              productId = "2533";
              vendorId = "093a";
            }
          ];
          configFile."kcminputrc" = {
            "ButtonRebinds/Mouse" = {
              "ExtraButton1" = "Key,Meta+Space"; # Button 9 = Meta + Space
              "ExtraButton2" = "Key,Ctrl+S"; # Button 8 = Ctrl + S
            };
          };

          # Border colors
          configFile."kdeglobals" = {
            # Reference: https://stylix.danth.me/configuration.html
            "WM" = with config.lib.stylix.colors; {
              "frame" = "${base0D-rgb-r},${base0D-rgb-g},${base0D-rgb-b}"; # Border color of active window
              "inactiveFrame" = "${base01-rgb-r},${base01-rgb-g},${base01-rgb-b}"; # Border color of inactive window
            };
          };

          # Button size
          configFile."breezerc" = {
            "Windeco" = {
              "ButtonSize" = "ButtonLarge"; # Size of window buttons
            };
          };

          # KWin Window manager for Plasma
          kwin = {
            effects.dimInactive.enable = false; # Dim inactive screens
          };

        };

        # Icon theme
        config.xdg.dataFile."icons/Papirus-Colors-Dark" = {
          source = with pkgs-bundle; (
            papirus-colors-icons."Papirus-Colors-Dark"
          );
        };

      };
    };
  };

}
