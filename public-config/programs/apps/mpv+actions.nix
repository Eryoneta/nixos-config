{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # MPV: Multimidia player
  config.modules."mpv+actions" = {
    # My custom functions, used by "mpv.bindings" or "mpv.scriptOpts.uosc"
    attr.actions = (
      let

        # Args
        mpv-config = config.modules."mpv".configuration;
        pkgs = config.modules."mpv".packageChannel;

        # UOSC
        uosc-flash-pause-indicator = "script-binding uosc/flash-pause-indicator"; # Flashes a big pause icon
        uosc-flash-timeline = "script-binding uosc/flash-timeline"; # Flashes the timeline bar
        uosc-flash-volume = "script-binding uosc/flash-volume"; # Flashes the volume bar
        uosc-next = "script-binding uosc/next"; # Load the next file
        uosc-prev = "script-binding uosc/prev"; # Load the previous file
        uosc-open-menu = "script-binding uosc/menu-blurred"; # Open menu
        uosc-open-playlist = "script-binding uosc/playlist"; # Open playlist
        uosc-open-subtitles = "script-binding uosc/subtitles"; # Open subtitles
        uosc-open-audio = "script-binding uosc/audio"; # Open audios
        uosc-open-file = "script-binding uosc/open-file"; # Open file menu
        uosc-paste = "script-binding uosc/paste"; # Load file path/URL in the clipboard

        # Speed
        speedsList = (utils.joinStr " " (builtins.concatLists [
          [ mpv-config.speedMinBoundary ]
          mpv-config.speeds
          [ mpv-config.speedMaxBoundary ]
        ]));

        # Rotation
        rotationList = (utils.joinStr " " mpv-config.rotations);

      in {

        # All Features:
        #   Basics: Play/Pause, Volume, Fullscreen/Windowed, Playlist, Exit
        #   Seek; Small, medium, big, and start/end
        #   Audios: Switch and menu
        #   Subtitles: Switch and menu
        #   Playback speed: Up/Down, and pitch correction
        #   Zoom: In/Out, and move
        #   Rotation: Cycle
        #   After playing: close, next, suspend, hiberntate, shutdown
        #   Utils: Pin window, loop, screeenshot, info, file copy/paste

        # Play/Pause
        togglePause = (utils.joinStr ";" [ # Play/Pause
          "no-osd cycle pause"
          uosc-flash-pause-indicator
        ]);
        play = (utils.joinStr ";" [ # Play
          "no-osd set pause no"
          uosc-flash-pause-indicator
        ]);
        pause = (utils.joinStr ";" [ # Pause
          "no-osd set pause yes"
          uosc-flash-pause-indicator
        ]);

        # Fullscreen
        toggleFullscreen = (utils.joinStr ";" [ # Toggle fullscreen
          "no-osd cycle fullscreen"
        ]);
        exitFullscreen = (utils.joinStr ";" [ # Exit fullscreen
          "no-osd set fullscreen no"
        ]);

        # Menu
        openMenu = (utils.joinStr ";" [ # Open menu
          uosc-open-menu
        ]);
        # openContextMenu = (utils.joinStr ";" [ # Menu
        #   "context-menu"
        # ]);
        # TODO: (MPV) Create custom context menu?

        # Exit
        exit = (utils.joinStr ";" [ # = Exit
          "quit"
        ]);

        # Seek
        goForward = {
          frame = (utils.joinStr ";" [ # Go +1 frame and pause
            "no-osd frame-step"
            ''show-text "Step: +1 frame"''
            uosc-flash-timeline
          ]);
          small = (utils.joinStr ";" [ # Go forward (Small)
            "no-osd seek ${mpv-config.seekStepSmall}"
            uosc-flash-timeline
          ]);
          medium = (utils.joinStr ";" [ # Go forward (Medium)
            "no-osd seek ${mpv-config.seekStepMedium}"
            uosc-flash-timeline
          ]);
          big = (utils.joinStr ";" [ # Go forward (Big)
            "no-osd seek ${mpv-config.seekStepBig}"
            uosc-flash-timeline
          ]);
          end = (utils.joinStr ";" [ # End of video
            "no-osd seek 100 absolute-percent"
            uosc-flash-timeline
          ]);
        };
        goBack = {
          frame = (utils.joinStr ";" [ # Go -1 frame and pause
            "no-osd frame-back-step"
            ''show-text "Step: -1 frame"''
            uosc-flash-timeline
          ]);
          small = (utils.joinStr ";" [ # Go back (Small)
            "no-osd seek -${mpv-config.seekStepSmall}"
            uosc-flash-timeline
          ]);
          medium = (utils.joinStr ";" [ # Go back (Medium)
            "no-osd seek -${mpv-config.seekStepMedium}"
            uosc-flash-timeline
          ]);
          big = (utils.joinStr ";" [ # Go back (Big)
            "no-osd seek -${mpv-config.seekStepBig}"
            uosc-flash-timeline
          ]);
          start = (utils.joinStr ";" [ # Start of video
            "no-osd seek 0 absolute-percent"
            uosc-flash-timeline
          ]);
        };

        # Volume
        toggleMute = (utils.joinStr ";" [ # Mute/Unmute
          "no-osd cycle mute"
          uosc-flash-volume
        ]);
        volumeUp = (utils.joinStr ";" [ # Increase volume
          "no-osd add volume ${mpv-config.volumeStep}"
          uosc-flash-volume
        ]);
        volumeDown = (utils.joinStr ";" [ # Decrease volume
          "no-osd add volume -${mpv-config.volumeStep}"
          uosc-flash-volume
        ]);

        # Audios
        openAudioMenu = (utils.joinStr ";" [ # Open audio menu
          uosc-open-audio
        ]);
        nextAudio = (utils.joinStr ";" [ # Next audio
          "no-osd cycle audio up"
          ''show-text "Audio: ''${audio}"''
        ]);
        prevAudio = (utils.joinStr ";" [ # Previous audio
          "no-osd cycle audio down"
          ''show-text "Audio: ''${audio}"''
        ]);

        # Subtitles
        openSubtitleMenu = (utils.joinStr ";" [ # Open subtitle menu
          uosc-open-subtitles
        ]);
        nextSubtitle = (utils.joinStr ";" [ # Next subtitle
          "no-osd cycle sub up"
          ''show-text "Subtitle: ''${sub}"''
        ]);
        prevSubtitle = (utils.joinStr ";" [ # Previous subtitle
          "no-osd cycle sub down"
          ''show-text "Subtitle: ''${sub}"''
        ]);
        toggleSubtitle = (utils.joinStr ";" [ # Disable/Enable subtitle
          "no-osd cycle sub-visibility"
          ''show-text "Subtitle: ''${sub}"''
        ]);

        # Playlist
        openPlaylistMenu = (utils.joinStr ";" [ # Open playlist menu
          uosc-open-playlist
        ]);
        nextFile = (utils.joinStr ";" [ # Next on the playlist
          uosc-next
        ]);
        prevFile = (utils.joinStr ";" [ # Previous on the playlist
          uosc-prev
        ]);

        # Playback speed
        speedUp = (utils.joinStr ";" [ # Increase speed
          "no-osd cycle-values speed ${speedsList}"
          ''show-text "Speed: ''${speed}x"''
        ]);
        speedDown = (utils.joinStr ";" [ # Decrease speed
          "no-osd cycle-values !reverse speed ${speedsList}"
          ''show-text "Speed: ''${speed}x"''
        ]);
        resetSpeed = (utils.joinStr ";" [ # Reset speed
          "no-osd set speed 1"
          ''show-text "Speed: ''${speed}x"''
        ]);
        togglePitchCorrection = (utils.joinStr ";" [ # How the video speed affects the sound
          "no-osd cycle audio-pitch-correction"
          ''show-text "Audio pitch correction: ''${audio-pitch-correction}"''
        ]);
        speedUpNoOSC = "no-osd cycle-values speed ${speedsList}"; # Increase speed (For UOSC)
        speedDownNoOSC = "no-osd cycle-values !reverse speed ${speedsList}"; # Decrease speed (For UOSC)
        resetSpeedNoOSC = "no-osd set speed 1"; # Reset speed (For UOSC)

        # Zoom
        zoomIn = (utils.joinStr ";" [ # Zoom in
          "no-osd add video-zoom ${mpv-config.zoomStep}"
          ''show-text "Zoom: ''${video-zoom}"''
        ]);
        zoomOut = (utils.joinStr ";" [ # Zoom out
          "no-osd add video-zoom -${mpv-config.zoomStep}"
          ''show-text "Zoom: ''${video-zoom}"''
        ]);
        resetZoom = (utils.joinStr ";" [ # Reset zoom and offsets
          "no-osd set video-zoom 0"
          "no-osd set video-pan-x 0"
          "no-osd set video-pan-y 0"
          ''show-text "Zoom: Reset"''
        ]);
        moveLeft = (utils.joinStr ";" [ # Move left
          "no-osd add video-pan-x ${mpv-config.moveStep}"
          ''show-text "Move left"''
        ]);
        moveRight = (utils.joinStr ";" [ # Move right
          "no-osd add video-pan-x -${mpv-config.moveStep}"
          ''show-text "Move right"''
        ]);
        moveUp = (utils.joinStr ";" [ # Move up
          "no-osd add video-pan-y ${mpv-config.moveStep}"
          ''show-text "Move up"''
        ]);
        moveDown = (utils.joinStr ";" [ # Move down
          "no-osd add video-pan-y -${mpv-config.moveStep}"
          ''show-text "Move down"''
        ]);

        # Rotate
        rotateClockwise = (utils.joinStr ";" [ # Rotate video clockwise
          "no-osd cycle-values video-rotate ${rotationList}"
          ''show-text "Rotation: ''${video-rotate}°"''
        ]);
        rotateAntiClockwise = (utils.joinStr ";" [ # Rotate video anti-clockwise
          "no-osd cycle-values !reverse video-rotate ${rotationList}"
          ''show-text "Rotation: ''${video-rotate}°"''
        ]);
        resetRotation = (utils.joinStr ";" [ # Reset rotation
          "no-osd set video-rotate 0"
          ''show-text "Rotation: Reset"''
        ]);

        # After Playing
        afterPlaying = {
          exit = (utils.joinStr ";" [ # Exit/Do nothing after video end
            "no-osd set keep-open no"
            "no-osd set keep-open-pause no"
            "no-osd set loop-file no"
            "playlist-clear"
            ''show-text "After playing: Exit"''
          ]);
          playNext = (utils.joinStr ";" [ # Play next/Do nothing after video end
            "no-osd set keep-open no"
            "no-osd set keep-open-pause no"
            "no-osd set loop-file no"
            ''show-text "After playing: Load next file"''
          ]);
          shutdown = (utils.joinStr ";" [ # Shutdown after video end
            # Note: It's good practice to ask KDE Plasma to shutdown
            #''no-osd run "${pkgs.bash}/bin/sh" "-c" "systemctl poweroff"'' # Works, but is not safe!
            ''no-osd run "${pkgs.bash}/bin/sh" "-c" "qdbus org.kde.Shutdown /Shutdown logoutAndShutdown"'' # Shutdown now
            #''no-osd run "${pkgs.bash}/bin/sh" "-c" "qdbus org.kde.LogoutPrompt /LogoutPrompt promptShutDown"'' # Ask for shutdown
            ''show-text "After playing: Shutdown"''
          ]);
          suspend = (utils.joinStr ";" [ # Suspend after video end
            ''no-osd run "${pkgs.bash}/bin/sh" "-c" "systemctl suspend"''
            ''show-text "After playing: Suspend"''
          ]);
          hibernate = (utils.joinStr ";" [ # Hibernate after video end
            ''no-osd run "${pkgs.bash}/bin/sh" "-c" "systemctl hibernate"''
            ''show-text "After playing: Hibernate"''
          ]);
          # TODO: (MPV) Make "After playing" work, somehow...
          # TODO: (MPV) Act by event? Check
        };

        # Loop
        toggleLoop = (utils.joinStr ";" [ # Loop/Do nothing
          "no-osd cycle-values loop-file inf no"
          ''show-text "Loop: ''${loop-file}"''
          uosc-flash-timeline
        ]);

        # Reverse
        toggleReverse = (utils.joinStr ";" [ # Toggle Reverse video
          "no-osd cycle-values play-direction forward backward"
          ''show-text "Play direction: ''${play-direction}"''
          uosc-flash-timeline
        ]);

        # Pin
        togglePin = (utils.joinStr ";" [ # Toggle pin-on-top
          "no-osd cycle ontop"
          ''no-osd set title "''${filename} - mpv''${?ontop==yes: <Pinned>}"''
          ''show-text "Pinned: ''${ontop}"''
        ]);

        # Screenshot
        takeScreenshot = (utils.joinStr ";" [ # Screenshot without subtitles
          "no-osd screenshot video"
          ''show-text "Screenshot taken"''
        ]);

        # Info
        toggleInfo = (utils.joinStr ";" [ # Toggle info on screen
          "script-binding stats/display-stats-toggle"
        ]);

        # File
        openFileMenu = (utils.joinStr ";" [ # Open UOSC file menu
          uosc-open-file
        ]);
        copyFilePath = (utils.joinStr ";" [ # Copy file path
          ''no-osd run "${pkgs.bash}/bin/sh" "-c" "echo -n \"''${path}\" | xclip -i -selection clipboard"''
          ''show-text "Copied file path to clipboard"''
        ]);
        openFileInClipboard = (utils.joinStr ";" [ # Paste file path to play
          uosc-paste
        ]);

      }
    );
    tags = config.modules."mpv".tags;
  };

}

