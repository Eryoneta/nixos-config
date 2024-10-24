# My custom functions, used by "mpv.bindings" or "mpv.scriptOpts.uosc"
{ mpv-config, utils, pkgs }: (
  let

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

    # Play/Pause
    togglePause = (utils.joinStr ";" [ # Play/Pause
      "cycle pause"
      uosc-flash-pause-indicator
    ]);
    play = (utils.joinStr ";" [ # Play
      "set pause no"
      uosc-flash-pause-indicator
    ]);
    pause = (utils.joinStr ";" [ # Pause
      "set pause yes"
      uosc-flash-pause-indicator
    ]);

    # Fullscreen
    toggleFullscreen = (utils.joinStr ";" [ # Toggle fullscreen
      "cycle fullscreen"
    ]);
    exitFullscreen = (utils.joinStr ";" [ # Exit fullscreen
      "set fullscreen no"
    ]);

    # Menu
    openMenu = (utils.joinStr ";" [ # Open menu
      uosc-open-menu
    ]);
    # openContextMenu = (utils.joinStr ";" [ # Menu
    #   "context-menu"
    # ]); # TODO: Create menu?

    # Exit
    exit = (utils.joinStr ";" [ # = Exit
      "quit"
    ]);
    
    # Seek
    goForward = {
      frame = (utils.joinStr ";" [ # Go +1 frame and pause
        "frame-step"
        ''show-text "Step: +1 frame"''
        uosc-flash-timeline
      ]);
      small = (utils.joinStr ";" [ # Go forward (Small)
        "seek ${mpv-config.seekStepSmall}"
        uosc-flash-timeline
      ]);
      medium = (utils.joinStr ";" [ # Go forward (Medium)
        "seek ${mpv-config.seekStepMedium}"
        uosc-flash-timeline
      ]);
      big = (utils.joinStr ";" [ # Go forward (Big)
        "seek ${mpv-config.seekStepBig}"
        uosc-flash-timeline
      ]);
      end = (utils.joinStr ";" [ # End of video
        "seek 100 absolute-percent"
        uosc-flash-timeline
      ]);
    };
    goBack = {
      frame = (utils.joinStr ";" [ # Go -1 frame and pause
        "frame-back-step"
        ''show-text "Step: -1 frame"''
        uosc-flash-timeline
      ]);
      small = (utils.joinStr ";" [ # Go back (Small)
        "seek -${mpv-config.seekStepSmall}"
        uosc-flash-timeline
      ]);
      medium = (utils.joinStr ";" [ # Go back (Medium)
        "seek -${mpv-config.seekStepMedium}"
        uosc-flash-timeline
      ]);
      big = (utils.joinStr ";" [ # Go back (Big)
        "seek -${mpv-config.seekStepBig}"
        uosc-flash-timeline
      ]);
      start = (utils.joinStr ";" [ # Start of video
        "seek 0 absolute-percent"
        uosc-flash-timeline
      ]);
    };

    # Volume
    toggleMute = (utils.joinStr ";" [ # Mute/Unmute
      "cycle mute"
      uosc-flash-volume
    ]);
    volumeUp = (utils.joinStr ";" [ # Increase volume
      "add volume ${mpv-config.volumeStep}"
      uosc-flash-volume
    ]);
    volumeDown = (utils.joinStr ";" [ # Decrease volume
      "add volume -${mpv-config.volumeStep}"
      uosc-flash-volume
    ]);

    # Audios
    openAudioMenu = (utils.joinStr ";" [ # Open audio menu
      uosc-open-audio
    ]);
    nextAudio = (utils.joinStr ";" [ # Next audio
      "cycle audio up"
      ''show-text "Audio: ''${audio}"''
    ]);
    prevAudio = (utils.joinStr ";" [ # Previous audio
      "cycle audio down"
      ''show-text "Audio: ''${audio}"''
    ]);

    # Subtitles
    openSubtitleMenu = (utils.joinStr ";" [ # Open subtitle menu
      uosc-open-subtitles
    ]);
    nextSubtitle = (utils.joinStr ";" [ # Next subtitle
      "cycle sub up"
      ''show-text "Subtitle: ''${sub}"''
    ]);
    prevSubtitle = (utils.joinStr ";" [ # Previous subtitle
      "cycle sub down"
      ''show-text "Subtitle: ''${sub}"''
    ]);
    toggleSubtitle = (utils.joinStr ";" [ # Disable/Enable subtitle
      "cycle sub-visibility"
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
      "cycle-values speed ${speedsList}"
      # ''show-text "Speed: ''${speed}x"''
    ]);
    speedDown = (utils.joinStr ";" [ # Decrease speed
      "cycle-values !reverse speed ${speedsList}"
      # ''show-text "Speed: ''${speed}x"''
    ]);
    resetSpeed = (utils.joinStr ";" [ # Reset speed
      "set speed 1"
      # ''show-text "Speed: ''${speed}x"''
    ]);
    # TODO: "speed" var breaks UOSC. Fix?

    # Zoom
    zoomIn = (utils.joinStr ";" [ # Zoom in
      "add video-zoom ${mpv-config.zoomStep}"
      ''show-text "Zoom: ''${video-zoom}"''
    ]);
    zoomOut = (utils.joinStr ";" [ # Zoom out
      "add video-zoom -${mpv-config.zoomStep}"
      ''show-text "Zoom: ''${video-zoom}"''
    ]);
    resetZoom = (utils.joinStr ";" [ # Reset zoom and offsets
      "set video-zoom 0"
      "set video-pan-x 0"
      "set video-pan-y 0"
      ''show-text "Zoom: Reset"''
    ]);
    moveLeft = (utils.joinStr ";" [ # Move left
      "add video-pan-x ${mpv-config.moveStep}"
      ''show-text "Move left"''
    ]);
    moveRight = (utils.joinStr ";" [ # Move right
      "add video-pan-x -${mpv-config.moveStep}"
      ''show-text "Move right"''
    ]);
    moveUp = (utils.joinStr ";" [ # Move up
      "add video-pan-y ${mpv-config.moveStep}"
      ''show-text "Move up"''
    ]);
    moveDown = (utils.joinStr ";" [ # Move down
      "add video-pan-y -${mpv-config.moveStep}"
      ''show-text "Move down"''
    ]);

    # Rotate
    rotateClockwise = (utils.joinStr ";" [ # Rotate video clockwise
      "cycle-values video-rotate ${rotationList}"
      ''show-text "Rotation: ''${video-rotate}°"''
    ]);
    rotateAntiClockwise = (utils.joinStr ";" [ # Rotate video anti-clockwise
      "cycle-values !reverse video-rotate ${rotationList}"
      ''show-text "Rotation: ''${video-rotate}°"''
    ]);
    resetRotation = (utils.joinStr ";" [ # Reset rotation
      "set video-rotate 0"
      ''show-text "Rotation: Reset"''
    ]);

    # After Playing
    afterPlaying = {
      exit = (utils.joinStr ";" [ # Exit/Do nothing after video end
        ""
        ''show-text "After playing: Exit"''
      ]);
      playNext = (utils.joinStr ";" [ # Play next/Do nothing after video end
        ""
        ''show-text "After playing: Load next file"''
      ]);
      shutdown = (utils.joinStr ";" [ # Shutdown after video end
        # Note: It's good practice to ask KDE Plasma to shutdown
        #''run "${pkgs.bash}/bin/sh" "-c" "systemctl poweroff"'' # Works, but is not safe!
        ''run "${pkgs.bash}/bin/sh" "-c" "qdbus org.kde.Shutdown /Shutdown logoutAndShutdown"'' # Shutdown now
        # ''run "${pkgs.bash}/bin/sh" "-c" "qdbus org.kde.LogoutPrompt /LogoutPrompt promptShutDown"'' # Ask for shutdown
        ''show-text "After playing: Shutdown"''
      ]);
      suspend = (utils.joinStr ";" [ # Suspend after video end
        ''run "${pkgs.bash}/bin/sh" "-c" "systemctl suspend"''
        ''show-text "After playing: Suspend"''
      ]);
      hibernate = (utils.joinStr ";" [ # Hibernate after video end
        ''run "${pkgs.bash}/bin/sh" "-c" "systemctl hibernate"''
        ''show-text "After playing: Hibernate"''
      ]);
      # TODO: Make it work at the end, somehow...
      # "shutdown" = ""; # TODO: Act by event?
    };

    # Loop
    toggleLoop = (utils.joinStr ";" [ # Loop/Do nothing
      "cycle-values loop-file inf no"
      ''show-text "Loop: ''${loop-file}"''
      uosc-flash-timeline
    ]);

    # Reverse
    toggleReverse = (utils.joinStr ";" [ # Toggle Reverse video
      "cycle-values play-direction forward backward"
      ''show-text "Play direction: ''${play-direction}"''
      uosc-flash-timeline
    ]);

    # Pin
    togglePin = (utils.joinStr ";" [ # Toggle pin-on-top
      "cycle ontop"
      ''show-text "Pinned: ''${ontop}"''
    ]);
    # TODO: Broken. Check if it's working later

    # Screenshot
    takeScreenshot = (utils.joinStr ";" [ # Screenshot without subtitles
      "screenshot video"
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
      ''run "${pkgs.bash}/bin/sh" "-c" "echo -n \"''${path}\" | xclip -i -selection clipboard"''
      ''show-text "Copied file path to clipboard"''
    ]);
    openFileInClipboard = (utils.joinStr ";" [ # Paste file path to play
      uosc-paste
    ]);

  }
)