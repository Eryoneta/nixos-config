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

        # UOSC
        uosc-flash-pause-indicator = "script-binding uosc/flash-pause-indicator"; # Flashes a big pause icon
        uosc-flash-timeline = "script-binding uosc/flash-timeline"; # Flashes the timeline bar
        uosc-flash-volume = "script-binding uosc/flash-volume"; # Flashes the volume bar
        uosc-next = "script-binding uosc/next"; # Load the next file
        uosc-prev = "script-binding uosc/prev"; # Load the previous file
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
            "controls" = (builtins.concatStringsSep "," [
              "menu" # UOSC menu button
              "gap:0.5"
              (builtins.concatStringsSep "" [ # Speed-up button
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
              (builtins.concatStringsSep "" [ # Speed-up button
                "command" # Type
                ":fast_rewind" # Icon
                ":cycle-values !reverse speed ${speedsList}" # Command
                "?Decrease speed" # Tooltip
              ])
              (builtins.concatStringsSep "" [ # Reset speed button
                "command" # Type
                ":speed" # Icon
                ":set speed 1" # Command
                "?Reset speed" # Tooltip
              ])
              (builtins.concatStringsSep "" [ # Speed-down button
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

          # Basic
          "MBTN_LEFT" = "cycle pause;${uosc-flash-pause-indicator}"; # "mouse_left" = Play/Pause
          "SPACE" = "cycle pause;${uosc-flash-pause-indicator}"; # "space" = Play/Pause
          "PLAY" = "cycle pause;${uosc-flash-pause-indicator}"; # "media_play" = Play/Pause
          "PAUSE" = "cycle pause;${uosc-flash-pause-indicator}"; # "media_play" = Play/Pause
          "PLAYPAUSE" = "cycle pause;${uosc-flash-pause-indicator}"; # "media_playpause" = Play/Pause
          "PLAYONLY" = "set pause no;${uosc-flash-pause-indicator}"; # "media_playonly" = Play
          "PAUSEONLY" = "set pause yes;${uosc-flash-pause-indicator}"; # "media_playonly" = Pause

          #"MBTN_RIGHT" = "context-menu"; # "mouse_right" = Menu # TODO: Create menu?

          "MBTN_LEFT_DBL" = "cycle fullscreen"; # "mouse_left x2" = Toggle fullscreen
          "ENTER" = "cycle fullscreen"; # "enter" = Toggle fullscreen
          "ESC" = "set fullscreen no"; # "esc" = Exit fullscreen

          "Shift+ESC" = "quit"; # "shift+esc" = Exit
          "MBTN_MID" = "quit"; # "mouse_middle" = Exit
          "STOP" = "quit"; # "media_stop" = Exit
          "POWER" = "quit"; # "power" = Exit
          "CLOSE_WIN" = "quit"; # "close window" = Exit

          # Seek
          "RIGHT" = "seek ${seekStepSmall};${uosc-flash-timeline}"; # "right" = Go forward (Small)
          "LEFT" = "seek -${seekStepSmall};${uosc-flash-timeline}"; # "left" = Go back (Small)

          "Ctrl+RIGHT" = "seek ${seekStepMedium};${uosc-flash-timeline}"; # "ctrl+right" = Go forward (Medium)
          "FORWARD" = "seek ${seekStepMedium};${uosc-flash-timeline}"; # "media_forward" = Go forward (Medium)
          "Ctrl+LEFT" = "seek -${seekStepMedium};${uosc-flash-timeline}"; # "ctrl+left" = Go back (Medium)
          "REWIND" = "seek -${seekStepMedium};${uosc-flash-timeline}"; # "media_rewind" = Go back (Medium)

          "Ctrl+Shift+RIGHT" = "seek ${seekStepBig};${uosc-flash-timeline}"; # "ctrl+right" = Go forward (Big)
          "Ctrl+Shift+LEFT" = "seek -${seekStepBig};${uosc-flash-timeline}"; # "ctrl+left" = Go back (Big)

          "." = "frame-step"; # "." = Seek +1 frame and pause
          "," = "frame-back-step"; # "." = Seek -1 frame and pause

          "HOME" = "seek 0 absolute-percent;${uosc-flash-timeline}"; # "home" = Start of video
          "END" = "seek 100 absolute-percent;${uosc-flash-timeline}"; # "end" = End of video

          # Volume
          "m" = "cycle mute;${uosc-flash-volume}"; # "m" = Mute/Unmute
          "MUTE" = "cycle mute;${uosc-flash-volume}"; # "media_mute" = Mute/Unmute

          "WHEEL_UP" = "add volume ${volumeStep};${uosc-flash-volume}"; # "wheel_up" = Increase volume
          "UP" = "add volume ${volumeStep};${uosc-flash-volume}"; # "up" = Increase volume
          "VOLUME_UP" = "add volume ${volumeStep};${uosc-flash-volume}"; # "media_volume_up" = Increase volume

          "WHEEL_DOWN" = "add volume -${volumeStep};${uosc-flash-volume}"; # "wheel_down" = Decrease volume
          "DOWN" = "add volume -${volumeStep};${uosc-flash-volume}"; # "down" = Decrease volume
          "VOLUME_DOWN" = "add volume -${volumeStep};${uosc-flash-volume}"; # "media_volume_down" = Decrease volume

          # Audios
          "a" = "cycle audio up"; # "a" = Next audio
          "Shift+a" = "cycle audio down"; # "shift+a" = Previous audio

          # Subtitles
          "s" = "cycle sub up"; # "a" = Next subtitle
          "Shift+s" = "cycle sub down"; # "shift+s" = Previous subtitle
          "Ctrl+s" = "cycle sub-visibility"; # "ctrl+s" = Disable/Enable subtitle

          # Playlist
          "NEXT" = "${uosc-next}"; # "media_next" = Next on the playlist
          "PGDWN" = "${uosc-next}"; # "page_down" = Next on the playlist

          "PREV" = "${uosc-prev}"; # "media_prev" = Previous on the playlist
          "PGUP" = "${uosc-prev}"; # "page_up" = Next on the playlist

          # Playback speed
          "Ctrl+UP" = "cycle-values speed ${speedsList}"; # "ctrl+up" = Increase speed
          "Ctrl+DOWN" = "cycle-values !reverse speed ${speedsList}"; # "ctrl+down" = Decrease speed

          # Zoom
          "Alt+f" = "add video-zoom ${zoomStep}"; # "ctrl+f" = Zoom
          "Shift+f" = "add video-zoom -${zoomStep}"; # "shift+f" = UnZoom
          "Alt+Shift+f" = "set video-zoom 0;set video-pan-x 0;set video-pan-y 0"; # "ctrl+shift+f" = Reset zoom and offsets

          "Alt+a" = "add video-pan-x ${moveStep}"; # "alt+a" = Move left
          "Alt+d" = "add video-pan-x -${moveStep}"; # "alt+d" = Move right
          "Alt+w" = "add video-pan-y ${moveStep}"; # "alt+w" = Move up
          "Alt+s" = "add video-pan-y -${moveStep}"; # "alt+s" = Move down

          # Rotate
          "Ctrl+r" = "cycle-values video-rotate ${rotationList}"; # "ctrl+r" = Rotate video clockwise
          "Shift+r" = "cycle-values !reverse video-rotate ${rotationList}"; # "shift+r" = Rotate video anti-clockwise
          "Ctrl+Shift+r" = "set video-rotate 0"; # "ctrl+shift+r" = Reset rotation

          # After end
          "Ctrl+Alt+d" = ''
            run "${pkgs.bash}/bin/sh" "-c" "systemctl shutdown";show-text "After playing: Shutdown"
          ''; # "ctrl+alt+d" = Shutdown after video end
          "Ctrl+Alt+s" = ''
            run "${pkgs.bash}/bin/sh" "-c" "systemctl suspend";show-text "After playing: Suspend"
          ''; # "ctrl+alt+s" = Suspend after video end
          "Ctrl+Alt+h" = ''
            run "${pkgs.bash}/bin/sh" "-c" "systemctl hibernate";show-text "After playing: Hibernate"
          ''; # "ctrl+alt+h" = Hibernate after video end
          # TODO: Make it work at the end, somehow...
          # "shutdown" = ""; # TODO: Act by event?

          # Loop
          "r" = "cycle-values loop-file inf no"; # "r" = Loop/Do nothing

          # Reverse
          "Alt+r" = "cycle-values play-direction forward backward;${uosc-flash-timeline}"; # "alt+r" = Reverse video

          # Pin
          "p" = "cycle ontop"; # "p" = Toggle pin-on-top # TODO: Broken. Check if is working later

          # Screenshot
          "F5" = "screenshot video"; # "f5" = Screenshot without subtitles

          # Info
          "i" = "script-binding stats/display-stats-toggle"; # "i" = Toggle info on screen

          # File
          "Ctrl+o" = "${uosc-open-file}"; # "ctrl+o" = Open UOSC file menu
          "Ctrl+v" = "${uosc-paste}";

        };

      }
    );

  };

}
