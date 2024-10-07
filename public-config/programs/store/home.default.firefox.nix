{ pkgs-bundle, user, ... }@args: with args.config-utils; {
  config = {

    # Firefox: Browser
    programs.firefox = {
      enable = mkDefault true;
      package = mkDefault pkgs-bundle.stable.firefox;

      # Language
      # TODO: Enable once the option is included
      #languagePacks = [ "pt-BR" "en-US" ];

      # Policies
      # More at: "about:policies#documentaion"
      policies = {
        DisableAppUpdate = true; # Do not update
        AppAutoUpdate = false; # Do not auto-update
        BackgroundAppUpdate = false; # Do not update on background
        DisableFirefoxAccounts = true; # Disable user account("Firefox Sync")
        DisableFirefoxStudies = true; # Disable "Shield"
        DisablePocket = true; # Disable "Pocket"
        DisableTelemetry = true; # Disable telemetry
        DontCheckDefaultBrowser = true; # Do not check if the browser is the default
      };

      # Template profile
      # This profile should carry a basic, reasonable configuration. Its a template for others
      profiles."template-profile" = {
        id = 2;
        name = "Template";
        isDefault = false;

        # Extensions
        extensions = with pkgs-bundle.firefox-addons; [
          ublock-origin # UBlock-Origin: Adblocker
        ];

        # Default Settings
        settings = {

          # UI (User Interface)
          "intl.locale.requested" = "pt-BR, en-US"; # UI language
          "intl.accept_languages" = "en-US, en, pt-BR, pt"; # Priority of languages when accessing pages

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

    };

  };
}
