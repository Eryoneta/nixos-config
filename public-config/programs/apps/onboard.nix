{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # OnBoard: Virtual keyboard
  config.modules."onboard" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ onboard ];

        # GSettings
        config.dconf.settings = {
          "org/onboard/keyboard" = {
            "input-event-source" = "GTK";
            "key-synth" = "uinput";
          };
          "org/onboard/window" = {
            "docking-enabled" = false;
            "force-to-top" = true;
            "window-decoration" = true;
          };
        };
        # Note: "dconf dump / > dconf.settings" can be used to list all settings into a file "./dconf.settings"
        #   `dconf dump / > dconf.settings && nix-shell -p dconf2nix --run "dconf2nix -i dconf.settings -o dconf.nix"`
        #   This one get all the settings and uses "dconf2nix" to create a valid "dconf.nix". Very convenient!

        # Desktop Entry: Set to use X11
        config.xdg.desktopEntries."onboard" = {
          name = "Onboard";
          exec = "GDK_BACKEND=x11 onboard";
          icon = "onboard";
          categories = [ "Utility" "Accessibility" ];
          type = "Application";
          terminal = false;
          mimeType = [
            "application/x-onboard"
          ];
          settings = {
            "GenericName" = "Onboard onscreen keyboard";
            "GenericName[pt_BR]" = "Teclado virtual Onboard";
            "Comment" = "Flexible onscreen keyboard";
            "Comment[pt_BR]" = "Teclado no ecrã flexível";
          };
          # Note: As defined by the package
          #   (Can be seen at "~/.local/state/nix/profiles/home-manager-<GENERATION>-link/home-path/share/applications/")
        };

        # Desktop Entry: Hide settings entry (It's redundant)
        config.xdg.desktopEntries."onboard-settings" = {
          name = "Onboard Settings";
          exec = "onboard-settings";
          noDisplay = true; # Hide
        };

      };
    };
  };

}
