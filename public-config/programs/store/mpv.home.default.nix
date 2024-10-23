{ config, pkgs-bundle, config-domain, pkgs, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpv = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.mpv; {

    home.packages = utils.mkIf (options.enabled) (
      with options.packageChannel; [

        # Trash-Cli: Interface for Freedesktop.org Trash
        # UOSC uses this to delete files(A menu option), moving them to the trash
        trash-cli

        # yt-dlp: YouTube downloader script
        # MPV uses this to open online videos
        yt-dlp

        # xclip: Simple clipboard manager
        # MPV uses this to copy a file path
        xclip

      ]
    );

    # MPV: Multimidia player
    programs.mpv = {
      enable = utils.mkDefault options.enabled;
      package = utils.mkDefault options.packageChannel.mpv;
      # package = utils.mkDefault (options.packageChannel.mpv.override {
      #   # Scripts
      #   scripts = with options.packageChannel; [
      #     mpvScripts.uosc # UOSC: MPV frontend
      #     #mpvScripts.modernx-zydezu # ModernX: MPV frontend
      #     mpvScripts.mpris # MPRIS: Protocol for media control(Ex.: Media start/pause)
      #     mpvScripts.thumbfast # Thumbafast: Previews in the trackbar
      #     #mpvScripts.mpv-notify-send # Notify-Send: Inform about the media
      #     #mpvScripts.quality-menu # Quality-Menu: Menu for selecting ytdl video quality
      #   ];
      # }); # "package" with "unstable" ins incompatible...?

      # Scripts
      scripts = with options.packageChannel; [
        mpvScripts.uosc # UOSC: MPV frontend
        #mpvScripts.modernx-zydezu # ModernX: MPV frontend # TODO: (24.11) Testar quando atualizar
        mpvScripts.mpris # MPRIS: Protocol for media control(Ex.: Media start/pause)
        mpvScripts.thumbfast # Thumbafast: Previews in the trackbar
        #mpvScripts.mpv-notify-send # Notify-Send: Inform about the media
      ];

    } // (
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

        # UI
        osc-duration = "1000";

        # Volume
        volumeStep = "5"; # Volume: 5%

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
        speedsList = (utils.joinStr " " (builtins.concatLists [
          [ speedMinBoundary ]
          speeds
          [ speedMaxBoundary ]
        ]));

        # Zoom
        zoomStep = "0.05"; # Zoom: +-5%
        moveStep = "0.01"; # Move screen: +-1%

        # Rotation
        rotationList = (utils.joinStr " " [
          "0" "90" "180" "270"
        ]);

        # Custom functions
        action = {

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
              "seek ${seekStepSmall}"
              uosc-flash-timeline
            ]);
            medium = (utils.joinStr ";" [ # Go forward (Medium)
              "seek ${seekStepMedium}"
              uosc-flash-timeline
            ]);
            big = (utils.joinStr ";" [ # Go forward (Big)
              "seek ${seekStepBig}"
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
              "seek -${seekStepSmall}"
              uosc-flash-timeline
            ]);
            medium = (utils.joinStr ";" [ # Go back (Medium)
              "seek -${seekStepMedium}"
              uosc-flash-timeline
            ]);
            big = (utils.joinStr ";" [ # Go back (Big)
              "seek -${seekStepBig}"
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
            "add volume ${volumeStep}"
            uosc-flash-volume
          ]);
          volumeDown = (utils.joinStr ";" [ # Decrease volume
            "add volume -${volumeStep}"
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
            "add video-zoom ${zoomStep}"
            ''show-text "Zoom: ''${video-zoom}"''
          ]);
          zoomOut = (utils.joinStr ";" [ # Zoom out
            "add video-zoom -${zoomStep}"
            ''show-text "Zoom: ''${video-zoom}"''
          ]);
          resetZoom = (utils.joinStr ";" [ # Reset zoom and offsets
            "set video-zoom 0"
            "set video-pan-x 0"
            "set video-pan-y 0"
            ''show-text "Zoom: Reset"''
          ]);
          moveLeft = (utils.joinStr ";" [ # Move left
            "add video-pan-x ${moveStep}"
            ''show-text "Move left"''
          ]);
          moveRight = (utils.joinStr ";" [ # Move right
            "add video-pan-x -${moveStep}"
            ''show-text "Move right"''
          ]);
          moveUp = (utils.joinStr ";" [ # Move up
            "add video-pan-y ${moveStep}"
            ''show-text "Move up"''
          ]);
          moveDown = (utils.joinStr ";" [ # Move down
            "add video-pan-y -${moveStep}"
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

        };

      in {

        # Configurations
        # Doc: https://mpv.io/manual/stable
        config = {

          # Behaviour
          "keep-open" = "yes"; # Do not close when finished
          "keep-open-pause" = "yes"; # Pause once the end is reached
          "loop-file" = "inf"; # Always loop videos
          "loop-playlist" = "no"; # Do not loop playlists
          "volume-max" = 200; # Maximum volume in %
          "stop-screensaver" = "yes"; # Do not sleep when playing video
          "cursor-autohide" = osc-duration; # Time in ms before hiding the cursor
          "window-dragging" = "yes"; # Dragging moves the window
          "drag-and-drop" = "auto"; # Drop to replace current video
          "autocreate-playlist" = "filter"; # Create playlist with files from the same folder
          "directory-filter-types" = "video,audio"; # Accept only videos and audios

          "vo" = "wlshm"; # Video output
          # TODO: UOSC: Change to another "vo" later?

          # URLs
          "ytdl" = "yes"; # Uses "youtube-dl" or similars to open URLs
          "ytdl_path" = "yt-dlp"; # Uses "yt-dlp" to open URLs
          
          # OSD (On-Screen Display)
          "osc" = "no"; # Control on screen
          "osd-bar" = "no"; # Do not show volume/time bar
          "osd-duration" = osc-duration; # Duration in ms on screen
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

        # Script configurations
        scriptOpts = {
          # UOSC configuration
          # Defaults: https://github.com/tomasklaen/uosc/blob/main/src/uosc.conf
          uosc = {

            # Progress bar (Expanded)
            "timeline_style" = "line"; # Display current position as a line
            "timeline_line_width" = 2; # Line thickness
            "timeline_size" = 20; # Height when fully expanded
            "timeline_border" = 1; # Top border thickness
            "timeline_step" = "-${seekStepSmall}"; # Step in seconds, when scrolling
            "timeline_cache" = "yes"; # For stream content, show loaded parts
            "timeline_persistency" = "paused,idle"; # When to not hide

            # Progress bar (Minimized)
            "progress" = "windowed"; # When to always show the minimized bar
            "progress_size" = 2; # Height
            "progress_line_width" = 10; # Width

            # Control bar
            # Doc: https://github.com/tomasklaen/uosc/blob/main/src/uosc.conf#L24-L82
            "controls" = (utils.joinStr "," [
              "menu" # UOSC menu button
              "gap:0.5"
              (utils.joinStr "" [ # Speed-up button
                "cycle" # Type
                ":rotate_left" # Icon
                ":play-direction" # Property
                  ":forward" # Value 1
                    "=rotate_left" # Icon 1
                  "/backward" # Value 2
                    "=close" # Icon 2
                "?Play backwards" # Tooltip
              ])
              "gap:0.5"
              "loop-file" # Loop button
              "gap"
              "loop-playlist" # Loop playlist button
              "shuffle" # Shuffle button
              "gap"
              "prev" # Playlist-previous button
              "items" # Playlist menu button
              "next" # Playlist-next button
              "space"
              (utils.joinStr "" [ # Speed-down button
                "command" # Type
                ":fast_rewind" # Icon
                ":${action.speedDown}" # Command
                "?Decrease speed" # Tooltip
              ])
              (utils.joinStr "" [ # Reset speed button
                "command" # Type
                ":speed" # Icon
                ":${action.resetSpeed}" # Command
                "?Reset speed" # Tooltip
              ])
              (utils.joinStr "" [ # Speed-up button
                "command" # Type
                ":fast_forward" # Icon
                ":${action.speedUp}" # Command
                "?Increase speed" # Tooltip
              ])
              "space"
              "<has_sub>subtitles" # Subtitle selector menu button
              "<has_many_audio>audio" # Audio selector menu button
              "<has_many_video>video" # Video selector menu button
              "<stream>stream-quality" # Quality selector menu button
              "gap"
              "fullscreen" # Fullscreen button
            ]);
            "controls_size" = 30; # Height
            "controls_margin" = 8; # Margin
            "controls_spacing" = 2; # Space between
            "controls_persistency" = "idle"; # When to not hide

            # Volume
            "volume" = "left"; # Where to show
            "volume_size" = 30; # Width
            "volume_border" = 1; # Border thickness
            "volume_step" = volumeStep; # Step in %, when scrolling
            "volume_persistency" = ""; # When to not hide

            # Playback speed
            "speed_step" = 0; # Step in %, when scrolling
            "speed_step_is_factor" = "no"; # If is added(no) or multiplied(yes)
            "speed_persistency" = "never"; # When to not hide

            # Menus
            "menu_item_height" = 40; # Height
            "menu_min_width" = 260; # Min width
            "menu_padding" = 4; # Internal space
            "menu_type_to_search" = "no"; # Type anything to search options

            # Top bar
            "top_bar" = "never"; # How to show
            "top_bar_size" = 30; # Height
            "top_bar_controls" = "right"; # Buttons position
            "top_bar_title" = "yes"; # Show title
            "top_bar_alt_title" = ""; # Show alternative title
            "top_bar_alt_title_place" = "below"; # Alternative title position
            "top_bar_flash_on" = "video,audio"; # When to quickly show the top bar
            "top_bar_persistency" = "paused,idle"; # When to not hide

            # Window
            "window_border_size" = 1; # Border thickness, when in no-border mode

            # Behaviour
            "autoload" = "yes"; # No playlist and file ends = Load next file in the directory
            "autoload_types" = "video,audio"; # What to autoload
            "shuffle" = "no"; # Shuffle
            # "click_command"= "cycle pause;${uosc-flash-pause-indicator}"; # Command executed by mouse click
            # "click_threshold" = 500; # Execute only for clicks shorter than this

            # Interface
            "scale" = 1; # UI scale
            "scale_fullscreen" = 1.3; # UI scale when fullscreen
            "font_scale" = 1; # Font scale
            "font_bold" = "no"; # Use bold font
            "text_border" = 1.2; # Border of text and icons
            "border_radius" = 4; # Border radius of elements
            "autohide" = "no"; # Hide UI when mpv autohides the cursor
            "destination_time" = "time-remaining"; # How to show the remaining time
            "time_precision" = 3; # Timestamp precision after the second
            "buffered_time_threshold" = 120; # When streaming content, time in seconds before hiding the buffered parts(Ex. >60s)
            "adjust_osd_margins" = "yes"; # Adjust margins
            "color" = ""; # Colors
            "opacity" = ""; # Opacities
            "refine" = ""; # Refinements

            # Animations
            "animation_duration" = 200; # Animation duration in ms
            "proximity_in" = 40; # Distance in pixels before the element is fully visible
            "proximity_out" = 120; # Distance in pixels before the element is fully invisible
            "pause_indicator" = "static"; # How to animate the pause indicator
            "flash_duration" = osc-duration; # Duration in ms of the flash

            # Extras
            "stream_quality_options" = "1440,1080,720,480,360,240"; # Options offered when streaming
            "chapter_ranges" = "intros:30abf964,outros:30abf964,ads:c54e4e80"; # Colors for each chapter type (RRGGBBAA)
            "chapter_range_patterns" = ""; # Lua patterns to identify chapters
            "languages" = "slang,en"; # Prority of languages of the UI
            "disable_elements" = ""; # Elements to disable

            # Files
            "video_types" = "3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,utils.mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m";
            "audio_types" = "aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,utils.mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv";
            "image_types" = "apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp";
            "subtitle_types" = "aqt,ass,gsub,idx,jss,lrc,utils.mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt";
            "playlist_types" = "m3u,m3u8,pls,url,cue";
            "default_directory" = "~/"; # Default open-file menu directory
            "show_hidden_files" = "yes"; # Show hidden files
            "use_trash" = "yes"; # Uses "trash-cli" to "delete files"

          };
        };

        # Profiles
        profiles = {
          "min_speed_limit" = {
            "profile-desc" = "Limits the minimum speed";
            "profile-cond" = "speed <= ${speedMinBoundary}"; # If the boundary is reached
            "speed" = (builtins.head speeds); # Limit the speed to a minimum
          };
          "max_speed_limit" = {
            "profile-desc" = "Limits the maximum speed";
            "profile-cond" = "speed >= ${speedMaxBoundary}"; # If the boundary is reached
            "speed" = (lib.lists.last speeds); # Limit the speed to a maximum
          };
        };

        # Shortcuts
        # Doc: https://mpv.io/manual/stable/#command-interface
        # Defaults: https://github.com/mpv-player/mpv/blob/master/etc/input.conf
        # "mpv --input-keylist" lists all special keys!
        # "mpv --input-test --force-window --idle" shows all actions for a given input!
        bindings = {

          # Play/Pause
          "MBTN_LEFT" = action.togglePause; # mouse_left
          "Space" = action.togglePause; # space
          "PLAY" = action.togglePause; # media_play
          "PAUSE" = action.togglePause; # media_pause
          "PLAYPAUSE" = action.togglePause; # media_play_pause

          "PLAYONLY" = action.play; # media_play_only
          "PAUSEONLY" = action.pause; # media_pause_only

          # Fullscreen
          "MBTN_LEFT_DBL" = action.toggleFullscreen; # mouse_left_x2
          "Enter" = action.toggleFullscreen; # enter
          "Esc" = action.exitFullscreen; # esc

          # Menu
          "MBTN_RIGHT" = action.openMenu; # mouse_right
          "o" = action.openMenu; # o

          # Exit
          "Shift+Esc" = action.exit; # shift+esc
          "MBTN_MID" = action.exit; # mouse_middle
          "STOP" = action.exit; # media_stop
          "POWER" = action.exit; # power
          "CLOSE_WIN" = action.exit; # close-window

          # Seek
          "Right" = action.goForward.small; # right
          "Left" = action.goBack.small; # left

          "Ctrl+Right" = action.goForward.medium; # ctrl+right
          "Ctrl+Left" = action.goBack.medium; # ctrl+left
          
          "FORWARD" = action.goForward.medium; # media_forward
          "REWIND" = action.goBack.medium; # media_rewind

          "Ctrl+Shift+Right" = action.goForward.big; # ctrl+shift+right
          "Ctrl+Shift+Left" = action.goBack.big; # ctrl+shift+left

          "." = action.goForward.frame; # .
          "," = action.goBack.frame; # ,
          
          "End" = action.goForward.end; # end
          "Home" = action.goBack.start; # home

          # Volume
          "m" = action.toggleMute; # m
          "MUTE" = action.toggleMute; # media_mute

          "WHEEL_UP" = action.volumeUp; # wheel_up
          "WHEEL_DOWN" = action.volumeDown; # wheel_down

          "up" = action.volumeUp; # up
          "down" = action.volumeDown; # down

          "VOLUME_UP" = action.volumeUp; # media_volume_up
          "VOLUME_DOWN" = action.volumeDown; # media_volume_down

          # Audios
          "Ctrl+Shift+a" = action.openAudioMenu; # ctrl+shift+a

          "a" = action.nextAudio; # a
          "Shift+a" = action.prevAudio; # shift+a

          # Subtitles
          "Ctrl+Shift+s" = action.openSubtitleMenu; # ctrl+shift+s
          "Ctrl+s" = action.toggleSubtitle; # ctrl+s

          "s" = action.nextSubtitle; # s
          "Shift+s" = action.prevSubtitle; # shift+s

          # Playlist
          "l" = action.openPlaylistMenu; # l

          "PgDwn" = action.nextFile; # page_down
          "PgUp" = action.prevFile; # page_up

          "NEXT" = action.nextFile; # media_next
          "PREV" = action.prevFile; # media_prev

          # Playback speed
          "Ctrl+0" = action.resetSpeed; # ctrl+0

          "Ctrl+Up" = action.speedUp; # ctrl+up
          "Ctrl+Down" = action.speedDown; # ctrl+down

          # Zoom
          "Alt+Shift+f" = action.resetZoom; # ctrl+shift+f

          "Alt+f" = action.zoomIn; # ctrl+f
          "Shift+f" = action.zoomOut; # shift+f

          "Ctrl+WHEEL_UP" = action.zoomIn; # ctrl+wheel_up
          "Ctrl+WHEEL_DOWN" = action.zoomOut; # ctrl+wheel_down

          "Alt+a" = action.moveLeft; # alt+a
          "Alt+d" = action.moveRight; # alt+d
          "Alt+w" = action.moveUp; # alt+w
          "Alt+s" = action.moveDown; # alt+s

          # Rotate
          "Ctrl+Shift+r" = action.resetRotation; # ctrl+shift+r

          "Ctrl+r" = action.rotateClockwise; # ctrl+r
          "Shift+r" = action.rotateAntiClockwise; # shift+r

          # After end
          "t" = action.afterPlaying.exit; # t
          "g" = action.afterPlaying.playNext; # g
          "Ctrl+Alt+d" = action.afterPlaying.shutdown; # ctrl+alt+d
          "Ctrl+Alt+s" = action.afterPlaying.suspend; # ctrl+alt+s
          "Ctrl+Alt+h" = action.afterPlaying.hibernate; # ctrl+alt+h

          # Loop
          "r" = action.toggleLoop; # r

          # Reverse
          "Alt+r" = action.toggleReverse; # alt+r

          # Pin
          "p" = action.togglePin; # p

          # Screenshot
          "F5" = action.takeScreenshot; # f5

          # Info
          "i" = action.toggleInfo; # i

          # File
          "Ctrl+o" = action.openFileMenu; # ctrl+o

          "Ctrl+c" = action.copyFilePath; # ctrl+c
          "Ctrl+v" = action.openFileInClipboard; # ctrl+v

        };

      }
    );

  };

}
