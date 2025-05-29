{ config, lib, pkgs, ... }@args: with args.config-utils; {

  options = {
    profile.programs.firefox-devedition = {
      options.enabled = (utils.mkBoolOption true);
      options.packageChannel = (utils.mkPackageOption args.pkgs-bundle.unstable);
      options.defaults = (utils.mkDefaultsOption {
        "settings" = (import ./firefox-dev+settings.nix);
      });
    };
  };

  config = with config.profile.programs.firefox-devedition; (lib.mkIf (options.enabled) {

    # Firefox Developer Edition: Browser
    # Can be used alonside regular "Firefox" (With a trick!)

    # Note: Added with override below (With FX-AutoConfig)

    # The profiles configuration are shared with regular "Firefox" (Convenient!)
    programs.firefox = {

      # Personal profile
      # This profile is personal. Customization without limits!
      profiles."dev-edition-default" = {
        # It NEEDS to be "dev-edition-default"!
        #   This way "firefox-devedition" doesn't complain about "missing profiles"
        #   If it doesn't find it, then it creates a new one, but it can't edit "profiles.ini", throws an error
        id = 1;
        #name = "Yo"; # HAS to be "dev-edition-default"
        isDefault = false;  # Only one can be the default

        # Search engines
        search = {
          force = true;
          engines = {
            "Google" = {
              "metaData"."alias" = "@g";
            };
            "Nix Packages" = {
              "urls" = [
                {
                  "template" = "https://search.nixos.org/packages";
                  "params" = [
                    { "name" = "type"; "value" = "packages"; }
                    { "name" = "query"; "value" = "{searchTerms}"; }
                  ];
                }
              ];
              "icon" = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              "definedAliases" = [ "@np" ];
            };
            "NixOS Wiki" = {
              "urls" = [
                {
                  "template" = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
              "iconUpdateURL" = "https://nixos.wiki/favicon.png";
              "updateInterval" = 24 * 60 * 60 * 1000; # Every day
              "definedAlias" = [ "@nw" ];
            };
          };
          default = "DuckDuckGo"; # Is more reliable than Google
          order = [
            "DuckDuckGo"
            "Google"
          ];
        };

        # Extensions
        extensions = (
          config.programs.firefox.profiles."template-profile".extensions
          ++
          (with args.pkgs-bundle.firefox-addons.pkgs; [
            tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
            sidebery # Sidebery: Sidebar with vertical tabs
          ])
        );

        # Settings
        settings = (config.programs.firefox.profiles."template-profile".settings // (
          options.defaults."settings"
        ));

      };

    };

    # FX-AutoConfig: Custom JavaScript loader
    home = (
      let
        fx-autoconfig = args.pkgs-bundle.fx-autoconfig;
        profilePath = ".mozilla/firefox/dev-edition-default";
        scripts = args.pkgs-bundle.firefox-scripts;
      in {

        # Firefox Developer Edition: Browser
        packages = with options.packageChannel; [
          (
            let
              firefox-devedition-pkg = (firefox-devedition.override {
                extraPrefsFiles = [
                  # Enable "userChromeJS"
                  "${fx-autoconfig}/program/config.js"
                ];
              });
            in (
              lib.hiPrio firefox-devedition-pkg
              # Note: Allows firefox to coexist with firefox-devedition!
              #   All files from firefox-devedition will override files from firefox!
              #   Warning: Uhh, firefox might not be compatible with some stuffs from firefox-devedition...! Watch out!
            )
          )
        ];

        file = (
          let

            mapDirContent = src: dest: (utils.pipe "${src}" [
              # ReadDir: dirPath -> { "file1.ext" = "regular"; "file2.ext" = "regular"; }
              (x: builtins.readDir x)

              # AttrNames: { "file1.ext" = "regular"; "file2.ext" = "regular"; } -> [ "file1.ext" "file2.ext" ]
              (x: builtins.attrNames x)

              # Map: [ "file1.ext" ] -> [ { name = ".../file1.ext"; value = { source = ".../file1.ext" }; } ]
              (x: builtins.map (
                value: {
                  name = "${dest}/${value}";
                  value = {
                    source = "${src}/${value}";
                  };
                }
              ) x)

              # ListToAttrs: [ { name = ".../file1.ext"; value = { source = ".../file1.ext" }; } ] -> { ".../file1.ext" = { source = ".../file1.ext" }; }
              (x: builtins.listToAttrs x)
            ]);

          in {

            # Dotfile: Load scripts and styles
            "${profilePath}/chrome/utils" = {
              source = "${fx-autoconfig}/profile/chrome/utils";
            };

            # Dotfile: Small example
            "${profilePath}/chrome/CSS/small_dot_example.uc.css" = {
              source = "${fx-autoconfig}/profile/chrome/CSS/author_style.uc.css";
            };

          }
          # My Firefox styles
          // (mapDirContent "${scripts}/chrome/CSS" "${profilePath}/chrome/CSS")
          # My Firefox scripts
          // (mapDirContent "${scripts}/chrome/JS" "${profilePath}/chrome/JS")
          // {

            # Modified dotfile: Custom accent color
            "${profilePath}/chrome/CSS/addAccentColor.uc.css" = {
              source = with config.lib.stylix.colors; (pkgs.runCommand "customize-accent-color" {} ''
                sed \
                  -e 's/--accent-color: .*/--accent-color: #${base0D};/' \
                  -e 's/--inactive-color: .*/--inactive-color: #${base01};/' \
                  "${scripts}/chrome/CSS/addAccentColor.uc.css" \
                   > $out
              '');
            };

          }
        );

      }
    );

  });

}
