{ config, lib, pkgs, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpv = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.stable);
      options.defaults = (utils.mkDefaultsOption rec {
        mpv-config = {

          # UI
          osc-duration = "1000";

          # Volume
          startVolume = "60"; # Start volume: 60%
          volumeStep = "5"; # Volume: 5%
          volumeMax = "200"; # Max-volume: 200%

          # Seek
          seekStepSmall = "2"; # Seek: +-2s
          seekStepMedium = "10"; # Seek: +-10s
          seekStepBig = "20"; # Seek: +-20s

          # Speed
          speeds = [ # All available speeds
            "0.03125" "0.0625" "0.125" "0.25" "0.5" "0.75"
              "1"
                "1.25" "1.75" "2" "4" "8" "16"
          ];
          speedMinBoundary = "0.03124"; # Smaller than the smallest speed, triggers the limit
          speedMaxBoundary = "16.00001"; # Bigger than the biggest speed, triggers the limit

          # Zoom
          zoomStep = "0.05"; # Zoom: +-5%
          moveStep = "0.01"; # Move screen: +-1%

          # Rotation
          rotations = [
            "0" "90" "180" "270"
          ];

          # Actions
          actions = (import ./mpv+actions.nix {
            inherit mpv-config; # The same "mpv-config" from above
            inherit utils; # My "utils" from "config-utils"
            inherit pkgs;
          });

        };
      });
    };
  };

  config = with config.profile.programs.mpv; (lib.mkIf (options.enabled) {

    home.packages = with options.packageChannel; [

      # yt-dlp: YouTube downloader script
      # MPV uses this to open online videos
      #yt-dlp
      # Note: Already included

      # xclip: Simple clipboard manager
      # MPV uses this to copy a file path
      xclip

    ];

    # MPV: Multimidia player
    programs.mpv = with options.defaults; {
      enable = options.enabled;
      package = (utils.mkDefault) (options.packageChannel).mpv;

      # Configurations
      # Doc: https://mpv.io/manual/stable
      config = {

        # Window
        "force-window" = "yes"; # Open an empty window, if no file is provided
        "geometry" = with config.lib.hardware.configuration.screensize; (
          "${builtins.toString (width / 2)}x${builtins.toString (height - 34)}-0-0" # Start size
        );
        "keepaspect-window" = "no"; # Use black bars to center video
        "window-dragging" = "yes"; # Dragging moves the window
        "drag-and-drop" = "auto"; # Drop to replace current video
        "title" = "\${filename} - mpv"; # Window title

        # Behaviour
        "keep-open" = "yes"; # Do not close when finished
        "keep-open-pause" = "yes"; # Pause once the end is reached
        "loop-file" = "inf"; # Always loop videos
        "stop-screensaver" = "yes"; # Do not sleep when playing video
        "cursor-autohide" = mpv-config.osc-duration; # Time in ms before hiding the cursor
        "input-doubleclick-time" = 180; # Reduced click delay (Script/inputevent causes the delay)

        # Playlist
        "loop-playlist" = "no"; # Do not loop playlists
        "directory-mode" = "ignore"; # Ignore subfolders
        "autocreate-playlist" = "filter"; # Create playlist with files from the same folder
        "directory-filter-types" = "video,audio"; # Accept only videos and audios

        # Sound
        "volume" = mpv-config.startVolume; # Initial volume in %
        "volume-max" = mpv-config.volumeMax; # Maximum volume in %
        "af" = "scaletempo2=${utils.joinStr ":" [ # Audio engine
          "min-speed=${mpv-config.speedMinBoundary}"
          "max-speed=${mpv-config.speedMaxBoundary}"
        ]}";
        "audio-pitch-correction" = "no"; # Pitch correction

        # URLs
        "ytdl" = "yes"; # Uses "youtube-dl" or similars to open URLs
        "ytdl_path" = "yt-dlp"; # Uses "yt-dlp" to open URLs
        
        # OSD (On-Screen Display)
        "osc" = "no"; # Control on screen
        "osd-bar" = "no"; # Do not show volume/time bar
        "osd-duration" = mpv-config.osc-duration; # Duration in ms on screen
        "osd-playing-msg" = "\${filename}"; # Display filename on start
        "osd-playing-msg-duration" = 3000; # Duration in ms of the start message

        # Screenshot
        "screenshot-format" = "png"; # Save screenshots as ".png"
        "screenshot-template" = "[%P] %F"; # Format: "[HH:MM:SS.mmmm] filename-without-ext"
        "screenshot-dir" = "${config.xdg.userDirs.pictures}"; # Save in "Picture" directory

        # Terminal
        "terminal" = "yes"; # Show messages in the terminal
        "msg-color" = "yes"; # Show with colors

        # Bindings
        "input-default-bindings" = "no"; # Disable default shortcuts

      };

      # Profiles
      profiles = {
        "min_speed_limit" = {
          "profile-desc" = "Limits the minimum speed";
          "profile-cond" = "speed <= ${mpv-config.speedMinBoundary}"; # If the boundary is reached
          "speed" = (builtins.head mpv-config.speeds); # Limit the speed to a minimum
        };
        "max_speed_limit" = {
          "profile-desc" = "Limits the maximum speed";
          "profile-cond" = "speed >= ${mpv-config.speedMaxBoundary}"; # If the boundary is reached
          "speed" = (lib.lists.last mpv-config.speeds); # Limit the speed to a maximum
        };
      };

      # Shortcuts
      # Doc: https://mpv.io/manual/stable/#command-interface
      # Defaults: https://github.com/mpv-player/mpv/blob/master/etc/input.conf
      # "mpv --input-keylist" lists all special keys!
      # "mpv --input-test --force-window --idle" shows all actions for a given input!
      bindings = (import ./mpv+inputs.nix mpv-config.actions);

      # Scripts
      scripts = with options.packageChannel; [
        mpvScripts.mpris # MPRIS: Protocol for media control(Ex.: Media start/pause)
        mpvScripts.thumbfast # Thumbafast: Previews in the trackbar
      ];

    };

    # Scripts/InputEvent: More control over the inputs
    xdg.configFile."mpv/scripts/inputevent.lua" = {
      source = "${args.pkgs-bundle.mpv-input-event}/inputevent.lua";
    };

  });

}
