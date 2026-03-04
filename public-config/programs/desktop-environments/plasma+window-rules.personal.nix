{ config, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Main panel
  config.modules."plasma+window-rules.personal" = {
    tags = config.modules."plasma.personal".tags;
    attr.workArea = with config.hardware.configuration.screenSize.workArea; { # (From "configurations/screen-size.nix")
      width = builtins.toString (width);
      height = builtins.toString (height);
      halfWidth =  builtins.toString (width / 2);
      halfHeight =  builtins.toString (height / 2);
    };
    attr.mkMatch = config.modules."plasma+window-rules".attr.mkMatch;
    attr.mkValue = config.modules."plasma+window-rules".attr.mkValue;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Window rules
        config.programs.plasma.window-rules = [ # (plasma-manager option)

          # Chromium: Focus
          (utils.mkIf (true) {
            description = "Chromium & Focus: Unfocusable";
            match = { # What target
              window-class = (attr.mkMatch "exact" "chromium-browser Chromium-browser");
            };
            apply = { # What changes
              "fsplevel" = (attr.mkValue "force" 3); # Stops the app from stealing focus
            };
          })

          # Chromium: Start dimension
          (utils.mkIf (true) {
            description = "Chromium & Position/Size: Set start dimension";
            match = { # What target
              window-class = (attr.mkMatch "exact" "chromium chromium-browser");
            };
            apply = { # What changes
              "position" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},0")); # Set the window.position
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
          })

          # Firefox-Dev: PiP on all desktops
          (utils.mkIf (true) {
            description = "Firefox-Dev & OnTop/Desktops: Stick PiP windows on top of all desktops";
            match = { # What target
              window-class = (attr.mkMatch "exact" "firefox-devedition firefox-devedition");
              title = (attr.mkMatch "exact" "Picture-in-Picture");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "above" = (attr.mkValue "initially" true); # Set the window.to be on top
              "desktops" = (attr.mkValue "initially" 0); # Set the window.to be on all virtual desktops
            };
          })

          # Firefox-Dev: Size
          (utils.mkIf (true) {
            description = "Firefox-Dev & Size: Start with a set size";
            match = { # What target
              window-class = (attr.mkMatch "exact" "firefox-devedition firefox-devedition");
              window-types = [ "normal" ]; # Normal window
            };
            apply = { # What changes
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
          })

        ];

      };
    };
  };

}
