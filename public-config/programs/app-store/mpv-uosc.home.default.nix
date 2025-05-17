{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.mpv; (lib.mkIf (options.enabled) {

    home.packages = with options.packageChannel; [

      # Trash-Cli: Interface for Freedesktop.org Trash
      # UOSC uses this to delete files(A menu option), moving them to the trash
      trash-cli

    ];

    # MPV: Multimidia player
    programs.mpv = {

      # Scripts
      scripts = with options.packageChannel; [
        mpvScripts.uosc # UOSC: MPV frontend
      ];

      # Script configurations
      scriptOpts = with options.defaults; {
        # UOSC configuration
        # Defaults: https://github.com/tomasklaen/uosc/blob/main/src/uosc.conf
        "uosc" = {

          # Progress bar (Expanded)
          "timeline_style" = "line"; # Display current position as a line
          "timeline_line_width" = 2; # Line thickness
          "timeline_size" = 20; # Height when fully expanded
          "timeline_border" = 1; # Top border thickness
          "timeline_step" = "-${mpv-config.seekStepSmall}"; # Step in seconds, when scrolling
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
              ":${mpv-config.actions.speedDownNoOSC}" # Command
              "?Decrease speed" # Tooltip
            ])
            (utils.joinStr "" [ # Reset speed button
              "command" # Type
              ":speed" # Icon
              ":${mpv-config.actions.resetSpeedNoOSC}" # Command
              "?Reset speed" # Tooltip
            ])
            (utils.joinStr "" [ # Speed-up button
              "command" # Type
              ":fast_forward" # Icon
              ":${mpv-config.actions.speedUpNoOSC}" # Command
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
          "volume_step" = mpv-config.volumeStep; # Step in %, when scrolling
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
          "flash_duration" = mpv-config.osc-duration; # Duration in ms of the flash

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

    };

  });
}
