{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Firefox: Internet browser
  config.modules."firefox" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.unstable;
    attr.template = {
      extensions = with pkgs-bundle.firefox-addons.pkgs; [
        ublock-origin # UBlock-Origin: Adblocker
        plasma-integration # Plasma Integration: Integrates Plasma Desktop
      ];
      settings = {

        # UI (User Interface)
        "intl.locale.requested" = "pt-BR, en-US"; # UI language

        # UX (User experience)
        "browser.shell.checkDefaultBrowser" = false; # Do not check if the browser is the default
        "general.autoScroll" = true; # Enable autoscroll(Middle-click)
        "browser.tabs.warnOnClose" = true; # Warn before closing more than 1 tab
        "browser.tabs.maxOpenBeforeWarn" = 10; # Warn before opening too many bookmarks at once
        "browser.urlbar.suggest.calculator" = true; # Suggest results for math equations
        "browser.tabs.hoverPreview.enabled" = true; # Show a preview of the tab content on hover
        "extensions.autoDisableScopes" = 0; # Enable extensions by default
        # Updates
        "app.update.auto" = false; # Do not auto-update
        "app.update.service.enabled" = false; # Do not update on background
        "app.update.silent" = false; # Alert if an update happens
        "extensions.update.autoUpdateDefault" = false; # Do not auto-update by default

        # Privacy
        "permissions.default.geo" = 0; # Always ask
        "permissions.default.camera" = 0; # Always ask
        "permissions.default.microphone" = 0; # Always ask
        "permissions.default.desktop-notification" = 0; # Always ask

      };
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Configuration
        config.programs.firefox = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).firefox;

          # Languages
          languagePacks = [ "pt-BR" "en-US" ];

          # Policies
          # More at: "about:policies#documentaion"
          policies = {
            "DisableAppUpdate" = true; # Do not update
            "AppAutoUpdate" = false; # Do not auto-update
            "BackgroundAppUpdate" = false; # Do not update on background
            "DisableFirefoxAccounts" = true; # Disable user account("Firefox Sync")
            "DisableFirefoxStudies" = true; # Disable "Shield"
            "DisablePocket" = true; # Disable "Pocket"
            "DisableTelemetry" = true; # Disable telemetry
            "DontCheckDefaultBrowser" = true; # Do not check if the browser is the default
          };

          # Messaging Hosts
          nativeMessagingHosts = with attr.packageChannel; [
            kdePackages.plasma-browser-integration # Plasma Browser Integration
          ];

          # Default profile
          # This profile should be as "vanilla" as possible, the "new user experience"
          profiles."default" = {
            id = 0;
            isDefault = true;

            # Search engines
            search = {
              force = true;
              engines = {
                "Google" = {
                  "metaData"."alias" = "@g";
                };
              };
              default = "Google";
            };

            # Extensions
            extensions = (utils.mkDefault) (attr.template).extensions;

            # Settings
            settings = (utils.mkDefault) (attr.template).settings;

          };

        };

        # Plasma Browser Integration: Integrate browsers into Plasma Desktop
        config.home.packages = with attr.packageChannel; [
          kdePackages.plasma-browser-integration
        ];

      };
    };
  };

}
