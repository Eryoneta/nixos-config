{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Main panel
  config.modules."plasma+window-rules" = {
    tags = config.modules."plasma".tags;
    attr.workArea = with config.hardware.configuration.screenSize.workArea; { # (From "configurations/screen-size.nix")
      width = builtins.toString (width);
      height = builtins.toString (height);
      halfWidth =  builtins.toString (width / 2);
      halfHeight =  builtins.toString (height / 2);
    };
    attr.mkMatch = type: value: {
      inherit value type;
    };
    attr.mkValue = apply: value: {
      inherit value apply;
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Window rules
        config.programs.plasma.window-rules = [ # (plasma-manager option)

          # VSCodium: Launcher
          (utils.mkIf (true) {
            description = "VSCodium & Launcher: Fix instances";
            match = { # What target
              window-class = (attr.mkMatch "exact" "vscodium VSCodium");
              window-role = (attr.mkMatch "exact" "browser-window");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "desktopfile" = (attr.mkValue "initially" "codium"); # Set the .desktop launcher
            };
          })

          # VSCodium: Start dimension
          (utils.mkIf (true) {
            description = "VSCodium & Position/Size: Set start dimension";
            match = { # What target
              window-class = (attr.mkMatch "exact" "vscodium VSCodium");
              window-role = (attr.mkMatch "exact" "browser-window");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "position" = (with attr.workArea; (attr.mkValue "initially" "0,0")); # Set the window.position
              "size" = (with attr.workArea; (attr.mkValue "initially" "${width},${height}")); # Set the window.size
            };
          })

          # MPV: On top
          (utils.mkIf (true) {
            description = "MPV & OnTop: Stick pinned windows on top";
            match = { # What target
              window-class = (attr.mkMatch "exact" "mpv mpv");
              window-types = [ "normal" ];
              title = (attr.mkMatch "regex" ".* - mpv \\<Pinned\\>$");
            };
            apply = { # What changes
              "above" = (attr.mkValue "force" true); # Set the window.to be on top
            };
          })
          (utils.mkIf (true) {
            description = "MPV & OnTop: Unstick windows from top";
            match = { # What target
              window-class = (attr.mkMatch "exact" "mpv mpv");
              window-types = [ "normal" ];
              title = (attr.mkMatch "regex" ".* - mpv$");
            };
            apply = { # What changes
              "above" = (attr.mkValue "force" false); # Set the window.to not be on top
            };
          })

          # Firefox: PiP on top
          (utils.mkIf (false) { # DISABLED
            description = "Firefox & OnTop: Stick PiP windows on top";
            match = { # What target
              window-class = (attr.mkMatch "exact" "firefox firefox");
              title = (attr.mkMatch "exact" "Picture-in-Picture");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "above" = (attr.mkValue "initially" true); # Set the window.to be on top
            };
          })

          # Firefox: Start size
          (utils.mkIf (false) { # DISABLED
            description = "Firefox & Size: Start with a set size";
            match = { # What target
              window-class = (attr.mkMatch "exact" "firefox firefox");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
          })
          (utils.mkIf (true) {
            description = "Firefox(XWayland) & Size: Start with a set size";
            match = { # What target
              window-class = (attr.mkMatch "exact" "Navigator firefox"); # A Firefox window
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
            # TODO: (KWin/Rules/Firefox) Remove size rule once wayland works for Firefox
          })

          # MPV: Start dimension
          (utils.mkIf (true) {
            description = "MPV & Position/Size: Set start dimension";
            match = { # What target
              window-class = (attr.mkMatch "exact" "mpv mpv");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "position" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},0")); # Set the window.position
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
          })

          # KWrite: Start position
          (utils.mkIf (true) {
            description = "KWrite & Position: Set start position";
            match = { # What target
              window-class = (attr.mkMatch "exact" "kwrite org.kde.kwrite");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "position" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},0")); # Set the window.position
              #"size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
              # TODO: (Plasma/KWin/Rules/KWrite) Whenever it differentiates popups from windows, update the rule to set size too
            };
          })

          # SystemMonitor: Start dimension
          (utils.mkIf (true) {
            description = "SystemMonitor & Position/Size: Set start dimension";
            match = { # What target
              window-class = (attr.mkMatch "exact" "plasma-systemmonitor org.kde.plasma-systemmonitor");
              window-types = [ "normal" ];
            };
            apply = { # What changes
              "position" = (attr.mkValue "initially" "0,0"); # Set the window.position
              "size" = (with attr.workArea; (attr.mkValue "initially" "${halfWidth},${height}")); # Set the window.size
            };
          })

        ];

      };
    };
  };

}
