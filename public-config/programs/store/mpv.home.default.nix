{ config, pkgs-bundle, config-domain, pkgs, lib, ... }@args: with args.config-utils; {

  options = {
    profile.programs.mpv = {
      options.enabled = (mkBoolOption true);
      options.packageChannel = (mkPackageOption pkgs-bundle.stable);
    };
  };

  config = with config.profile.programs.mpv; {

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
        #mpvScripts.quality-menu # Quality-Menu: Menu for selecting ytdl video quality
      ];

    } // (
      let 
        volumeStep = "5"; # Volume: 5%
        seekStepSmall = "2"; # Seek: +-2s
        seekStepMedium = "10"; # Seek: +-10s
        seekStepBig = "20"; # Seek: +-20s
        speeds = [ # All available speeds
          "0.03125" "0.0625" "0.125" "0.25" "0.5" "0.75" "1" "1.25" "1.75" "2" "4" "8" "16" 
        ];
        speedMinBoundary = "0.03124"; # Smaller than the smallest speed, triggers the limit
        speedMaxBoundary = "16.00001"; # Bigger than the biggest speed, triggers the limit
        speedsList = (builtins.toString (builtins.concatLists [
          [ speedMinBoundary ]
          speeds
          [ speedMaxBoundary ]
        ]));
      in {

        # Configurations
        config = {

          # Behaviour
          "keep-open" = "yes"; # Do not close when finished
          "loop-file" = "inf"; # Always loop videos
          "loop-playlist" = "no"; # Do not loop playlists
          "volume-max" = 200; # Maximum volume: 200%
          
          # OSD (On-Screen Display)
          "osd" = "yes"; # Messages on screen
          "osd-bar" = "no"; # Do not show volume/time bar
          "osd-duration" = 1000; # Duration on screen
          "osd-playing-msg" = "\${filename}"; # Display filename on start
          "osd-playing-msg-duration" = 3000; # Duration of the start message

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
  # A comma delimited list of controls above the timeline. Set to `never` to disable.
  # Parameter spec: enclosed in `{}` means value, enclosed in `[]` means optional
  # Full item syntax: `[<[!]{disposition1}[,[!]{dispositionN}]>]{element}[:{paramN}][#{badge}[>{limit}]][?{tooltip}]`
  # Common properties:
  #   `{icon}` - parameter used to specify an icon name (example: `face`)
  #            - pick here: https://fonts.google.com/icons?icon.platform=web&icon.set=Material+Icons&icon.style=Rounded
  # `{element}`s and their parameters:
  #   `{shorthand}` - preconfigured shorthands:
  #        `play-pause`, `menu`, `subtitles`, `audio`, `video`, `playlist`,
  #        `chapters`, `editions`, `stream-quality`, `open-file`, `items`,
  #        `next`, `prev`, `first`, `last`, `audio-device`, `fullscreen`,
  #        `loop-playlist`, `loop-file`, `shuffle`
  #   `speed[:{scale}]` - display speed slider, [{scale}] - factor of controls_size, default: 1.3
  #   `command:{icon}:{command}` - button that executes a {command} when pressed
  #   `toggle:{icon}:{prop}[@{owner}]` - button that toggles mpv property. shorthand for yes/no cycle below
  #   `cycle:{default_icon}:{prop}[@{owner}]:{value1}[={icon1}][!]/{valueN}[={iconN}][!]`
  #       - button that cycles mpv property between values, each optionally having different icon and active flag
  #       - presence of `!` at the end will style the button as active
  #       - `{owner}` is the name of a script that manages this property if any. Set to `uosc` to tap into uosc options.
  #   `gap[:{scale}]` - display an empty gap
  #       {scale} - factor of controls_size, default: 0.3
  #   `space` - fills all available space between previous and next item, useful to align items to the right
  #           - multiple spaces divide the available space among themselves, which can be used for centering
  #   `button:{name}` - button whose state, look, and click action are managed by external script
  # Item visibility control:
  #   `<[!]{disposition1}[,[!]{dispositionN}]>` - optional prefix to control element's visibility
  #   - `{disposition}` can be one of:
  #     - `idle` - true if mpv is in idle mode (no file loaded)
  #     - `image` - true if current file is a single image
  #     - `audio` - true for audio only files
  #     - `video` - true for files with a video track
  #     - `has_many_video` - true for files with more than one video track
  #     - `has_image` - true for files with a cover or other image track
  #     - `has_audio` - true for files with an audio track
  #     - `has_many_audio` - true for files with more than one audio track
  #     - `has_sub` - true for files with an subtitle track
  #     - `has_many_sub` - true for files with more than one subtitle track
  #     - `has_many_edition` - true for files with more than one edition
  #     - `has_chapter` - true for files with chapter list
  #     - `stream` - true if current file is read from a stream
  #     - `has_playlist` - true if current playlist has 2 or more items in it
  #   - prefix with `!` to negate the required disposition
  #   Examples:
  #     - `<stream>stream-quality` - show stream quality button only for streams
  #     - `<has_audio,!audio>audio` - show audio tracks button for all files that have
  #                                   an audio track, but are not exclusively audio only files
  # Place `#{badge}[>{limit}]` after the element params to give it a badge. Available badges:
  #   `sub`, `audio`, `video` - track type counters
  #   `{mpv_prop}` - any mpv prop that makes sense to you: https://mpv.io/manual/master/#property-list
  #                - if prop value is an array it'll display its size
  #   `>{limit}` will display the badge only if it's numerical value is above this threshold.
  #   Example: `#audio>1`
  # Place `?{tooltip}` after the element config to give it a tooltip.
  # Example implementations:
  #   menu = command:menu:script-binding uosc/menu-blurred?Menu
  #   subtitles = command:subtitles:script-binding uosc/subtitles#sub?Subtitles
  #   fullscreen = cycle:crop_free:fullscreen:no/yes=fullscreen_exit!?Fullscreen
  #   loop-playlist = cycle:repeat:loop-playlist:no/inf!?Loop playlist
  #   toggle:{icon}:{prop} = cycle:{icon}:{prop}:no/yes!
            "controls" = "menu,gap,<has_many_sub>subtitles,<has_many_audio>audio,<has_many_video>video,<stream>stream-quality,gap,space,shuffle,loop-playlist,loop-file,gap,prev,items,next,gap,fullscreen";
            "controls_size" = 30; # Height
            "controls_margin" = 8; # Margin
            "controls_spacing" = 2; # Space between
            "controls_persistency" = "paused, idle"; # When to not hide
            # TODO: Config controls more

            # Volume
            "volume" = "right"; # Where to show
            "volume_size" = 30; # Width
            "volume_border" = 1; # Border thickness
            "volume_step" = volumeStep; # Step in %, when scrolling
            "volume_persistency" = "paused, idle"; # When to not hide

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
            "top_bar" = "no-border"; # How to show
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

            # Interface
            "scale" = 1; # UI scale
            "scale_fullscreen" = 1.3; # UI scale when fullscreen
            "font_scale" = 1; # Font scale
            "text_border" = 1.2; # Border of text and icons
            "border_radius" = 4; # Border radius of elements
            "color" = ""; # Colors
            "opacity" = ""; # Opacities
            "refine" = ""; # Refinements
            "animation_duration" = 100; # Animation duration in milliseconds

  # Execute command for background clicks shorter than this number of milliseconds, 0 to disable
  # Execution always waits for `input-doubleclick-time` to filter out double-clicks
            "click_threshold" = 0;
            "click_command"= "cycle pause; script-binding uosc/flash-pause-indicator";
            # TODO: Understand this

            "flash_duration" = 1000; # Flash duration of elements in milliseconds
            "proximity_in" = 40; # Distance in pixels before the element is fully visible
            "proximity_out" = 120; # Distance in pixels before the element is fully invisible
            "font_bold" = "no"; # Use bold font
            "destination_time" = "time-remaining"; # How to show the remaining time
            "time_precision" = 3; # Timestamp precision after the second
            "buffered_time_threshold" = 120; # When streaming content, time in seconds before hiding the buffered parts(Ex. >60s)
            "autohide" = "no"; # Hide UI when mpv autohides the cursor

  # Can be: flash, static, manual (controlled by flash-pause-indicator and decide-pause-indicator commands)
            "pause_indicator" = "flash"; # TODO: Understand

            "stream_quality_options" = "1440,1080,720,480,360,240"; # Options offered when streaming

            # Files
            "video_types" = "3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m";
            "audio_types" = "aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv";
            "image_types" = "apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp";
            "subtitle_types" = "aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt";
            "playlist_types" = "m3u,m3u8,pls,url,cue";
            "default_directory" = "~/"; # Default open-file menu directory
            "show_hidden_files" = "yes"; # Show hidden files

  # Move files to trash (recycle bin) when deleting files. Dependencies:
  # - Linux: `sudo apt install trash-cli`
  # - MacOS: `brew install trash`
            "use_trash" = "no";
            # TODO: Check trash-cli

  # Adjusted osd margins based on the visibility of UI elements
            "adjust_osd_margins" = "yes"; #TODO: Understand

  # Adds chapter range indicators to some common chapter types.
  # Additionally to displaying the start of the chapter as a diamond icon on top of the timeline,
  # the portion of the timeline of that chapter range is also colored based on the config below.
  #
  # The syntax is a comma-delimited list of `{type}:{color}` pairs, where:
  # `{type}` => range type. Currently supported ones are:
  #   - `openings`, `endings` => anime openings/endings
  #   - `intros`, `outros` => video intros/outros
  #   - `ads` => segments created by sponsor-block software like https://github.com/po5/mpv_sponsorblock
  # `{color}` => an RGB(A) HEX color code (`rrggbb`, or `rrggbbaa`)
  #
  # To exclude marking any of the range types, simply remove them from the list.
            "chapter_ranges" = "openings:30abf964,endings:30abf964,ads:c54e4e80"; # Markings for types of chapters
            # TODO: Check

            "chapter_range_patterns" = ""; # Lua patterns to identify chapters
            "languages" = "slang,en"; # Prority of languages of the UI
            "disable_elements" = ""; # Elements to disable

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
            "profile-cond" = "speed => ${speedMaxBoundary}"; # If the boundary is reached
            "speed" = (lib.lists.last speeds); # Limit the speed to a maximum
          };
        };

        # Shortcuts
        # "mpv --input-keylist" lists all special keys!
        # "mpv --input-test --force-window --idle" shows all actions for a given input!
        bindings = {

          # Basic
          "MBTN_LEFT" = "cycle pause"; # "mouse_left" = Play/Pause
          "SPACE" = "cycle pause"; # "space" = Play/Pause
          "PLAY" = "cycle pause"; # "media_play" = Play/Pause
          "PAUSE" = "cycle pause"; # "media_play" = Play/Pause
          "PLAYPAUSE" = "cycle pause"; # "media_playpause" = Play/Pause
          "PLAYONLY" = "set pause no"; # "media_playonly" = Play
          "PAUSEONLY" = "set pause yes"; # "media_playonly" = Pause

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
          "RIGHT" = "seek ${seekStepSmall}"; # "right" = Go forward (Small)
          "LEFT" = "seek -${seekStepSmall}"; # "left" = Go back (Small)

          "Ctrl+RIGHT" = "seek ${seekStepMedium}"; # "ctrl+right" = Go forward (Medium)
          "FORWARD" = "seek ${seekStepMedium}"; # "media_forward" = Go forward (Medium)
          "Ctrl+LEFT" = "seek -${seekStepMedium}"; # "ctrl+left" = Go back (Medium)
          "REWIND" = "seek -${seekStepMedium}"; # "media_rewind" = Go back (Medium)

          "Ctrl+Shift+RIGHT" = "seek ${seekStepBig}"; # "ctrl+right" = Go forward (Big)
          "Ctrl+Shift+LEFT" = "seek -${seekStepBig}"; # "ctrl+left" = Go back (Big)

          "." = "frame-step"; # "." = Seek +1 frame and pause
          "," = "frame-back-step"; # "." = Seek -1 frame and pause

          "HOME" = "seek 0 absolute"; # "home" = Start of video

          # Playback speed
          "Ctrl+UP" = "cycle-values speed ${speedsList}"; # "ctrl+up" = Increase speed
          "Ctrl+DOWN" = "cycle-values !reverse speed ${speedsList}"; # "ctrl+down" = Decrease speed

          # After end
          #"Ctrl+Alt+s" = ""; # "ctrl+alt+s" = Suspend after video end
          #"Ctrl+Alt+h" = ""; # "ctrl+alt+h" = Hibernate after video end
          #"Ctrl+Alt+d" = ""; # "ctrl+alt+d" = Shutdown after video end
          # TODO: Shutdown after video end
          # "Ctrl+Alt+d" = ''
          #   run "${pkgs.bash}/bin/sh" "-c" "$MPV_AFTER_SHUTDOWN=true"
          # '';
          # "shutdown" = ""; # TODO: Act by event?

          # Volume
          "m" = "cycle mute"; # "m" = Mute/Unmute
          "MUTE" = "cycle mute"; # "media_mute" = Mute/Unmute

          "WHEEL_UP" = "add volume ${volumeStep}"; # "wheel_up" = Increase volume
          "UP" = "add volume ${volumeStep}"; # "up" = Increase volume
          "VOLUME_UP" = "add volume ${volumeStep}"; # "media_volume_up" = Increase volume

          "WHEEL_DOWN" = "add volume -${volumeStep}"; # "wheel_down" = Decrease volume
          "DOWN" = "add volume -${volumeStep}"; # "down" = Decrease volume
          "VOLUME_DOWN" = "add volume -${volumeStep}"; # "media_volume_down" = Decrease volume

          # Audios
          "a" = "cycle audio up"; # "a" = Next audio
          "A" = "cycle audio down"; # "shift+a" = Previous audio

          # Subtitles
          "s" = "cycle sub up"; # "a" = Next subtitle
          "S" = "cycle sub down"; # "shift+s" = Previous subtitle
          "Ctrl+s" = "cycle sub-visibility"; # "ctrl+s" = Disable/Enable subtitle

          # Playlist
          "NEXT" = "playlist-next"; # "media_next" = Next on the playlist
          "PGUP" = "playlist-next"; # "page_up" = Next on the playlist

          "PREV" = "playlist-prev"; # "media_prev" = Previous on the playlist
          "PGDOWN" = "playlist-prev"; # "page_down" = Next on the playlist

          # Extras
          "r" = "cycle-values loop-file inf no"; # "r" = Loop/Do nothing
          "p" = "cycle ontop"; # "p" = Toggle pin-on-top # TODO: Broken. Check if its working later
          "F5" = "screenshot video"; # "f5" = Screenshot without subtitles
          "Ctrl+r" = "cycle-values video-rotate 90 180 270 0"; # "ctrl+r" = Rotate video clockwise
          #"Ctrl+f" = ""; # "ctrl+f" = Zoom # TODO: Zoom
          "i" = "script-binding stats/display-stats-toggle"; # "i" = Toggle info on screen

        };

      }
    );

  };

}
