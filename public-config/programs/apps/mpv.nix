{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # MPV: Multimidia player
  config.modules."mpv" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.yt-dlp.packageChannel = (
      if (config.includedModules."yt-dlp" or false) then (
        config.modules."yt-dlp".attr.packageChannel
      ) else (
        pkgs-bundle.unstable
      )
    );
    attr.configuration = {

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

      # Pitch
      pitches = [ # All available pitches
        "0.1" "0.3" "0.5" "0.7" "0.8" "0.9"
          "1"
            "1.1" "1.2" "1.3" "1.5" "1.8" "2"
      ];
      pitchMinBoundary = "0.09999"; # Smaller than the smallest pitch, triggers the limit
      pitchMaxBoundary = "2.00001"; # Bigger than the biggest pitch, triggers the limit

      # Zoom
      zoomStep = "0.05"; # Zoom: +-5%
      moveStep = "0.01"; # Move screen: +-1%

      # Rotation
      rotations = [
        "0" "90" "180" "270"
      ];

    };
    attr.actions = config.modules."mpv+actions".attr.actions;
    attr.windowPosition = with config.hardware.configuration.screenSize.workArea; { # (From "configurations/screen-size.nix")
      width =  builtins.toString (width / 2);
      height = builtins.toString (height - 32);
    };
    setup = { attr }: {
      home = { config, lib, ... }: { # (Home-Manager Module)

        config.home.packages = with attr.packageChannel; [

          (attr.yt-dlp).packageChannel.yt-dlp # yt-dlp: YouTube downloader script
          # MPV uses this to open online videos

          xclip # xclip: Simple clipboard manager
          # MPV uses this to copy a file path

        ];

        # Configuration
        config.programs.mpv = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).mpv;

          # Configurations
          # Doc: https://mpv.io/manual/stable
          config = {

            # Window
            "force-window" = "yes"; # Open an empty window, if no file is provided
            "geometry" = with attr.windowPosition; (
              "${width}x${height}-0-0" # Start size
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
            "cursor-autohide" = attr.configuration.osc-duration; # Time in ms before hiding the cursor
            "input-doubleclick-time" = 180; # Reduced click delay (Script/inputevent causes the delay)

            # Playlist
            "loop-playlist" = "no"; # Do not loop playlists
            "directory-mode" = "ignore"; # Ignore subfolders
            "autocreate-playlist" = "filter"; # Create playlist with files from the same folder
            "directory-filter-types" = "video,audio"; # Accept only videos and audios

            # Sound
            "volume" = attr.configuration.startVolume; # Initial volume in %
            "volume-max" = attr.configuration.volumeMax; # Maximum volume in %
            "af" = "scaletempo2=${utils.joinStr ":" [ # Audio engine
              "min-speed=${attr.configuration.speedMinBoundary}"
              "max-speed=${attr.configuration.speedMaxBoundary}"
            ]}";
            "audio-pitch-correction" = "no"; # Pitch correction

            # URLs
            "ytdl" = "yes"; # Uses "youtube-dl" or similars to open URLs
            "ytdl_path" = "yt-dlp"; # Uses "yt-dlp" to open URLs

            # OSD (On-Screen Display)
            "osc" = "no"; # Control on screen
            "osd-bar" = "no"; # Do not show volume/time bar
            "osd-duration" = attr.configuration.osc-duration; # Duration in ms on screen
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
              "profile-cond" = "speed <= ${attr.configuration.speedMinBoundary}"; # If the boundary is reached
              "speed" = (builtins.head attr.configuration.speeds); # Limit the speed to a minimum
            };
            "max_speed_limit" = {
              "profile-desc" = "Limits the maximum speed";
              "profile-cond" = "speed >= ${attr.configuration.speedMaxBoundary}"; # If the boundary is reached
              "speed" = (lib.lists.last attr.configuration.speeds); # Limit the speed to a maximum
            };
            "min_pitch_limit" = {
              "profile-desc" = "Limits the minimum pitch";
              "profile-cond" = "pitch <= ${attr.configuration.pitchMinBoundary}"; # If the boundary is reached
              "pitch" = (builtins.head attr.configuration.pitches); # Limit the pitch to a minimum
            };
            "max_pitch_limit" = {
              "profile-desc" = "Limits the maximum pitch";
              "profile-cond" = "pitch >= ${attr.configuration.pitchMaxBoundary}"; # If the boundary is reached
              "pitch" = (lib.lists.last attr.configuration.pitches); # Limit the pitch to a maximum
            };
          };

          # Scripts
          scripts = with attr.packageChannel; [
            mpvScripts.mpris # MPRIS: Protocol for media control(Ex.: Media start/pause)
            mpvScripts.thumbfast # Thumbfast: Previews in the trackbar
          ];

        };

      };
    };
  };

}
