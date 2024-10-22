{ config, pkgs-bundle, config-domain, pkgs, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpv = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.mpv; {

    home.packages = mkIf (options.enabled) (
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
      enable = mkDefault options.enabled;
      package = mkDefault options.packageChannel.mpv;
      # package = mkDefault (options.packageChannel.mpv.override {
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
        joinStr = str: list: (builtins.concatStringsSep str list);

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
        speedsList = (builtins.toString (builtins.concatLists [
          [ speedMinBoundary ]
          speeds
          [ speedMaxBoundary ]
        ]));

        # Zoom
        zoomStep = "0.05"; # Zoom: +-5%
        moveStep = "0.01"; # Move screen: +-1%

        # Rotation
        rotationList = (builtins.toString [
          "0" "90" "180" "270"
        ]);

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
          "drag-and-drop" = "auto"; # Drop to replace current video
          "autocreate-playlist" = "filter"; # Create playlist with files from the same folder
          "directory-filter-types" = "video,audio"; # Accept only videos and audios
          "window-dragging" = "yes"; # Dragging moves the window

          "vo" = "wlshm"; # Video output
          # TODO: UOSC: Change to another "vo" later?

          # URLs
          "ytdl" = "yes"; # Uses "youtube-dl" or similars to open URLs
          "ytdl_path" = "yt-dlp"; # Uses "yt-dlp" to open URLs
          
          # OSD (On-Screen Display)
          "osc" = "yes"; # Controll on screen
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
            "timeline_persistency" = "paused, idle"; # When to not hide

            # Progress bar (Minimized)
            "progress" = "windowed"; # When to always show the minimized bar
            "progress_size" = 2; # Height
            "progress_line_width" = 10; # Width

            # Control bar
            # Doc: https://github.com/tomasklaen/uosc/blob/main/src/uosc.conf#L24-L82
            "controls" = (joinStr "," [
              "menu" # UOSC menu button
              "gap:0.5"
              (joinStr "" [ # Speed-up button
                "cycle" # Type
                ":rotate_left" # Icon
                ":play-direction" # Property
                ":forward=rotate_left" # Value 1 & Icon
                "/backward=close" # Value 2 & Icon
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
              (joinStr "" [ # Speed-up button
                "command" # Type
                ":fast_rewind" # Icon
                ":cycle-values !reverse speed ${speedsList}" # Command
                "?Decrease speed" # Tooltip
              ])
              (joinStr "" [ # Reset speed button
                "command" # Type
                ":speed" # Icon
                ":set speed 1" # Command
                "?Reset speed" # Tooltip
              ])
              (joinStr "" [ # Speed-down button
                "command" # Type
                ":fast_forward" # Icon
                ":cycle-values speed ${speedsList}" # Command
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
            "top_bar_persistency" = "paused, idle"; # When to not hide

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
            "video_types" = "3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m";
            "audio_types" = "aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv";
            "image_types" = "apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp";
            "subtitle_types" = "aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt";
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
          "MBTN_LEFT" = (joinStr ";" [ # "mouse_left" = Play/Pause
            "cycle pause"
            uosc-flash-pause-indicator
          ]);
          "SPACE" = (joinStr ";" [ # "space" = Play/Pause
            "cycle pause"
            uosc-flash-pause-indicator
          ]);
          "PLAY" = (joinStr ";" [ # "media_play" = Play/Pause
            "cycle pause"
            uosc-flash-pause-indicator
          ]);
          "PAUSE" = (joinStr ";" [ # "media_pause" = Play/Pause
            "cycle pause"
            uosc-flash-pause-indicator
          ]);
          "PLAYPAUSE" = (joinStr ";" [ # "media_playpause" = Play/Pause
            "cycle pause"
            uosc-flash-pause-indicator
          ]);
          "PLAYONLY" = (joinStr ";" [ # "media_playonly" = Play
            "set pause no"
            uosc-flash-pause-indicator
          ]);
          "PAUSEONLY" = (joinStr ";" [ # "media_pauseonly" = Pause
            "set pause yes"
            uosc-flash-pause-indicator
          ]);
          
          # Menu
          "MBTN_RIGHT" = (joinStr ";" [ # "mouse_right" = Open menu
            uosc-open-menu
          ]);
          # "MBTN_RIGHT" = (joinStr ";" [ # "mouse_right" = Menu
          #   context-menu
          # ]); # TODO: Create menu?
          "o" = (joinStr ";" [ # "o" = Open menu
            uosc-open-menu
          ]);

          # Fullscreen
          "MBTN_LEFT_DBL" = (joinStr ";" [ # "mouse_left_x2" = Toggle fullscreen
            "cycle fullscreen"
          ]);
          "ENTER" = (joinStr ";" [ # "enter" = Toggle fullscreen
            "cycle fullscreen"
          ]);
          "ESC" = (joinStr ";" [ # "esc" = Exit fullscreen
            "set fullscreen no"
          ]);

          # Exit
          "Shift+ESC" = (joinStr ";" [ # "shift+esc" = Exit
            "quit"
          ]);
          "MBTN_MID" = (joinStr ";" [ # "mouse_middle" = Exit
            "quit"
          ]);
          "STOP" = (joinStr ";" [ # "media_stop" = Exit
            "quit"
          ]);
          "POWER" = (joinStr ";" [ # "power" = Exit
            "quit"
          ]);
          "CLOSE_WIN" = (joinStr ";" [ # "close-window" = Exit
            "quit"
          ]);

          # Seek
          "RIGHT" = (joinStr ";" [ # "right" = Go forward (Small)
            "seek ${seekStepSmall}"
            uosc-flash-timeline
          ]);
          "LEFT" = (joinStr ";" [ # "left" = Go back (Small)
            "seek -${seekStepSmall}"
            uosc-flash-timeline
          ]);
          "Ctrl+RIGHT" = (joinStr ";" [ # "ctrl+right" = Go forward (Medium)
            "seek ${seekStepMedium}"
            uosc-flash-timeline
          ]);
          "Ctrl+LEFT" = (joinStr ";" [ # "ctrl+left" = Go back (Medium)
            "seek -${seekStepMedium}"
            uosc-flash-timeline
          ]);
          "FORWARD" = (joinStr ";" [ # "media_forward" = Go forward (Medium)
            "seek ${seekStepMedium}"
            uosc-flash-timeline
          ]);
          "REWIND" = (joinStr ";" [ # "media_rewind" = Go back (Medium)
            "seek -${seekStepMedium}"
            uosc-flash-timeline
          ]);
          "Ctrl+Shift+RIGHT" = (joinStr ";" [ # "ctrl+shift+right" = Go forward (Big)
            "seek ${seekStepBig}"
            uosc-flash-timeline
          ]);
          "Ctrl+Shift+LEFT" = (joinStr ";" [ # "ctrl+shift+left" = Go back (Big)
            "seek -${seekStepBig}"
            uosc-flash-timeline
          ]);
          "." = (joinStr ";" [ # "." = Seek +1 frame and pause
            "frame-step"
            ''show-text "Step +1 frame"''
          ]);
          "," = (joinStr ";" [ # "," = Seek -1 frame and pause
            "frame-back-step"
            ''show-text "Step -1 frame"''
          ]);
          "HOME" = (joinStr ";" [ # "home" = Start of video
            "seek 0 absolute-percent"
            uosc-flash-timeline
          ]);
          "END" = (joinStr ";" [ # "end" = End of video
            "seek 100 absolute-percent"
            uosc-flash-timeline
          ]);

          # Volume
          "m" = (joinStr ";" [ # "m" = Mute/Unmute
            "cycle mute"
            uosc-flash-volume
          ]);
          "MUTE" = (joinStr ";" [ # "media_mute" = Mute/Unmute
            "cycle mute"
            uosc-flash-volume
          ]);
          "WHEEL_UP" = (joinStr ";" [ # "wheel_up" = Increase volume
            "add volume ${volumeStep}"
            uosc-flash-volume
          ]);
          "WHEEL_DOWN" = (joinStr ";" [ # "wheel_down" = Decrease volume
            "add volume -${volumeStep}"
            uosc-flash-volume
          ]);
          "UP" = (joinStr ";" [ # "up" = Increase volume
            "add volume ${volumeStep}"
            uosc-flash-volume
          ]);
          "DOWN" = (joinStr ";" [ # "down" = Decrease volume
            "add volume -${volumeStep}"
            uosc-flash-volume
          ]);
          "VOLUME_UP" = (joinStr ";" [ # "media_volume_up" = Increase volume
            "add volume ${volumeStep}"
            uosc-flash-volume
          ]);
          "VOLUME_DOWN" = (joinStr ";" [ # "media_volume_down" = Decrease volume
            "add volume -${volumeStep}"
            uosc-flash-volume
          ]);

          # Audios
          "Ctrl+Shift+a" = (joinStr ";" [ # "ctrl+shift+a" = Open audios menu
            uosc-open-audio
          ]);
          "a" = (joinStr ";" [ # "a" = Next audio
            "cycle audio up"
            ''show-text ""''
          ]);
          "Shift+a" = (joinStr ";" [ # "shift+a" = Previous audio
            "cycle audio down"
            ''show-text ""''
          ]);

          # Subtitles
          "Ctrl+Shift+s" = (joinStr ";" [ # "ctrl+shift+s" = Open subtitles menu
            uosc-open-subtitles
          ]);
          "s" = (joinStr ";" [ # "s" = Next subtitle
            "cycle sub up"
            ''show-text ""''
          ]);
          "Shift+s" = (joinStr ";" [ # "shift+s" = Previous subtitle
            "cycle sub down"
            ''show-text ""''
          ]);
          "Ctrl+s" = (joinStr ";" [ # "ctrl+s" = Disable/Enable subtitle
            "cycle sub-visibility"
            ''show-text ""''
          ]);

          # Playlist
          "l" = (joinStr ";" [ # "l" = Open playlist menu
            uosc-open-playlist
          ]);
          "PGDWN" = (joinStr ";" [ # "page_down" = Next on the playlist
            uosc-next
          ]);
          "PGUP" = (joinStr ";" [ # "page_up" = Previous on the playlist
            uosc-prev
          ]);
          "NEXT" = (joinStr ";" [ # "media_next" = Next on the playlist
            uosc-next
          ]);
          "PREV" = (joinStr ";" [ # "media_prev" = Previous on the playlist
            uosc-prev
          ]);

          # Playback speed
          "Ctrl+UP" = (joinStr ";" [ # "ctrl+up" = Increase speed
            "cycle-values speed ${speedsList}"
            ''show-text ""''
          ]);
          "Ctrl+DOWN" = (joinStr ";" [ # "ctrl+down" = Decrease speed
            "cycle-values !reverse speed ${speedsList}"
            ''show-text ""''
          ]);
          "Ctrl+0" = (joinStr ";" [ # "ctrl+0" = Reset speed
            "set speed 1"
            ''show-text ""''
          ]);

          # Zoom
          "Alt+f" = (joinStr ";" [ # "ctrl+f" = Zoom
            "add video-zoom ${zoomStep}"
            ''show-text ""''
          ]);
          "Shift+f" = (joinStr ";" [ # "shift+f" = UnZoom
            "add video-zoom -${zoomStep}"
            ''show-text ""''
          ]);
          "Alt+Shift+f" = (joinStr ";" [ # "ctrl+shift+f" = Reset zoom and offsets
            "set video-zoom 0"
            "set video-pan-x 0"
            "set video-pan-y 0"
            ''show-text ""''
          ]);
          "Alt+a" = (joinStr ";" [ # "alt+a" = Move left
            "add video-pan-x ${moveStep}"
            ''show-text ""''
          ]);
          "Alt+d" = (joinStr ";" [ # "alt+d" = Move right
            "add video-pan-x -${moveStep}"
            ''show-text ""''
          ]);
          "Alt+w" = (joinStr ";" [ # "alt+w" = Move up
            "add video-pan-y ${moveStep}"
            ''show-text ""''
          ]);
          "Alt+s" = (joinStr ";" [ # "alt+s" = Move down
            "add video-pan-y -${moveStep}"
            ''show-text ""''
          ]);

          # Rotate
          "Ctrl+r" = (joinStr ";" [ # "ctrl+r" = Rotate video clockwise
            "cycle-values video-rotate ${rotationList}"
            ''show-text ""''
          ]);
          "Shift+r" = (joinStr ";" [ # "shift+r" = Rotate video anti-clockwise
            "cycle-values !reverse video-rotate ${rotationList}"
            ''show-text ""''
          ]);
          "Ctrl+Shift+r" = (joinStr ";" [ # "ctrl+shift+r" = Reset rotation
            "set video-rotate 0"
            ''show-text ""''
          ]);

          # After end
          # "t" = (joinStr ";" [ # "t" = Exit/Do nothing after video end
          #   ""
          #   ''show-text ""''
          # ]);
          # "g" = (joinStr ";" [ # "g" = Play next/Do nothing after video end
          #   ""
          #   ''show-text ""''
          # ]);
          "Ctrl+Alt+d" = (joinStr ";" [ # "ctrl+alt+d" = Shutdown after video end
            ''run "${pkgs.bash}/bin/sh" "-c" "systemctl poweroff"''
            ''show-text "After playing: Shutdown"''
          ]);
          "Ctrl+Alt+s" = (joinStr ";" [ # "ctrl+alt+s" = Suspend after video end
            ''run "${pkgs.bash}/bin/sh" "-c" "systemctl suspend"''
            ''show-text "After playing: Suspend"''
          ]);
          "Ctrl+Alt+h" = (joinStr ";" [ # "ctrl+alt+h" = Hibernate after video end
            ''run "${pkgs.bash}/bin/sh" "-c" "systemctl hibernate"''
            ''show-text "After playing: Hibernate"''
          ]);
          # TODO: Make it work at the end, somehow...
          # "shutdown" = ""; # TODO: Act by event?

          # Loop
          "r" = (joinStr ";" [ # "r" = Loop/Do nothing
            "cycle-values loop-file inf no"
            ''show-text ""''
            uosc-flash-timeline
          ]);

          # Reverse
          "Alt+r" = (joinStr ";" [ # "alt+r" = Reverse video
            "cycle-values play-direction forward backward"
            ''show-text ""''
            uosc-flash-timeline
          ]);

          # Pin
          "p" = (joinStr ";" [ # "p" = Toggle pin-on-top
            "cycle ontop"
            ''show-text ""''
          ]);
          # TODO: Broken. Check if it's working later

          # Screenshot
          "F5" = (joinStr ";" [ # "f5" = Screenshot without subtitles
            "screenshot video"
            ''show-text ""''
          ]);

          # Info
          "i" = (joinStr ";" [ # "i" = Toggle info on screen
            "script-binding stats/display-stats-toggle"
          ]);

          # File
          "Ctrl+o" = (joinStr ";" [ # "ctrl+o" = Open UOSC file menu
            uosc-open-file
          ]);
          "Ctrl+c" = (joinStr ";" [ # "ctrl+c" = Copy file path
            ''run "${pkgs.bash}/bin/sh" "-c" "echo -n \"''${path}\" | xclip -i -selection clipboard"''
            ''show-text "Copied File Path to Clipboard"''
          ]);
          "Ctrl+v" = (joinStr ";" [ # "ctrl+v" = Paste file path to play
            uosc-paste
          ]);

        };

      }
    );

  };

}
