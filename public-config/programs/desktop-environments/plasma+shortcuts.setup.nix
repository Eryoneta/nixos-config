{ ... }@args: with args.config-utils; { # (Setup Module)

  # Main panel
  config.modules."plasma+shortcuts" = {
    tags = config.modules."plasma".tags;
    setup = {
      home = { # (Home-Manager Module)

        # Shortcuts
        config.programs.plasma.shortcuts = (utils.mkDefault) { # (plasma-manager option)
          # Sesssion actions
          "ksmserver"."Lock Session" = [ "Meta+L" "Ctrl+Alt+L" ]; # Lock screen
          "ksmserver"."Log Out" = "Ctrl+Alt+Del"; # Logout
          # Volume actions
          "kmix"."increase_volume" = "Volume Up"; # Volume up
          "kmix"."decrease_volume" = "Volume Down"; # Volume down
          "kmix"."increase_volume_small" = "Shift+Volume Up"; # Volume up small
          "kmix"."decrease_volume_small" = "Shift+Volume Down"; # Volume down small
          "kmix"."mute" = "Volume Mute"; # Mute
          # Microphone actions
          "kmix"."increase_microphone_volume" = "Microphone Volume Up"; # Microphone volume up
          "kmix"."decrease_microphone_volume" = "Microphone Volume Down"; # Microphone volume down
          "kmix"."mic_mute" = "Alt+Volume Mute"; # Microphone mute
          # Media control
          "mediacontrol"."playmedia" = "none"; # Play media (Play is used to toggle)
          "mediacontrol"."pausemedia" = "Media Pause"; # Pause media
          "mediacontrol"."playpausemedia" = "Media Play"; # Toggle media play
          "mediacontrol"."stopmedia" = "Media Stop"; # Stop media
          "mediacontrol"."nextmedia" = "Media Next"; # Switch to next media
          "mediacontrol"."previousmedia" = "Media Previous"; # Switch to previous media
          "mediacontrol"."mediavolumeup" = "none"; # Volume up (Controlled by KMix)
          "mediacontrol"."mediavolumedown" = "none"; # Volume down (Controlled by KMix)
          # Desktop actions
          "kwin"."Overview" = "Meta+W"; # Toggle show all windows, grouped by virtual desktops
          "kwin"."Show Desktop" = "Meta+D"; # Toggle hide all windows to show desktop
          # Activity actions
          "plasmashell"."manage activities" = "Meta+Q"; # Show activity menu
          "plasmashell"."next activity" = "Meta+Tab"; # Next activity
          "plasmashell"."previous activity" = "Meta+Shift+Tab"; # Previous activity
          # Virtual desktop actions
          "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up"; # Switch to virtual desktop above
          "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down"; # Switch to virtual desktop below
          "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left"; # Switch to virtual desktop at left
          "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right"; # Switch to virtual desktop at right
          # Window actions
          "kwin"."Kill Window" = "Meta+Ctrl+Esc"; # Force close window
          "kwin"."Window Close" = "Alt+F4"; # Close window
          "kwin"."Window Operations Menu" = "Alt+F1"; # Show window menu
          # Window actions (Size)
          "kwin"."Window Maximize" = "Meta+PgUp"; # Maximize window
          "kwin"."Window Minimize" = "Meta+PgDown"; # Minimize window
          # Window actions (Move)
          "kwin"."Window Move Center" = "Meta+alt+C"; # Move window to the center
          "kwin"."Window Quick Tile Top" = "Meta+Up"; # Snap window to top
          "kwin"."Window Quick Tile Bottom" = "Meta+Down"; # Snap window to bottom
          "kwin"."Window Quick Tile Left" = "Meta+Left"; # Snap window to left
          "kwin"."Window Quick Tile Right" = "Meta+Right"; # Snap window to right
          "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up"; # Move window to the virtual desktop above
          "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down"; # Move window to the virtual desktop below
          "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left"; # Move window to the virtual desktop at left
          "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right"; # Move window to the virtual desktop at right
          # Window actions (Switch)
          "kwin"."Switch Window Up" = "Meta+Alt+Up"; # Switch to the window above
          "kwin"."Switch Window Down" = "Meta+Alt+Down"; # Switch to the window below
          "kwin"."Switch Window Left" = "Meta+Alt+Left"; # Switch to the window at left
          "kwin"."Switch Window Right" = "Meta+Alt+Right"; # Switch to the window at right
          "kwin"."Walk Through Windows" = "Alt+Tab"; # Switch through a list of windows
          "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
          # Features
          "kwin"."Toggle Night Color" = []; # Toggle night color
          "kwin"."ToggleCurrentThumbnail" = "Meta+Ctrl+T"; # Toggle small floating image of the current window
          "kwin"."view_zoom_in" = "Meta+="; # Zoom in
          "kwin"."view_zoom_out" = "Meta+-"; # Zoom out
          "kwin"."view_actual_size" = "Meta+0"; # Reset zoom
          "plasmashell"."show-on-mouse-pos" = "Meta+V"; # Show Klipper
          # TODO: (Plasma/Shortcuts) Test all shortcuts! Change, if necessary
        };

      };
    };
  };

}
