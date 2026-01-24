{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Firefox Developer Edition: Internet browser for developers
  config.modules."firefox-devedition" = {
    tags = [ "personal-setup" "developer-setup" ];
    attr.packageChannel = pkgs-bundle.firefox-dev-fix;
    attr.fx-autoconfig = pkgs-bundle.fx-autoconfig;
    attr.firefox-scripts = pkgs-bundle.firefox-scripts;
    attr.template = {
      extensions = with (pkgs-bundle.firefox-addons).pkgs; (
        (config.modules."firefox".attr.template).extensions ++ [
          tab-stash # Tab Stash: Easily stash tabs inside a bookmark folder
          sidebery # Sidebery: Sidebar with vertical tabs
        ]
      );
      settings = config.modules."firefox-devedition+settings".attr.template.settings;
    };
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [
          (utils.higherPriority (firefox-devedition.override {
            extraPrefsFiles = [
              # FX-AutoConfig: Custom JavaScript loader
              "${attr.fx-autoconfig}/program/config.js"
            ];
          }))
          # Note: Allows "firefox" to coexist with "firefox-devedition"!
          #   Some files from "firefox-devedition" will override files from "firefox"!
          #   "firefox-devedition" is a version ahead of "firefox". Hopefully that isn't a problem
        ];

        # Configuration
        # The profile configuration is shared with regular Firefox
        config.programs.firefox = {

          # Personal profile
          # This profile is personal. Customization without limits!
          profiles."dev-edition-default" = {
            # Note: It NEEDS to be "dev-edition-default"!
            #   This way "firefox-devedition" doesn't complain about "missing profiles"
            #   If it doesn't find it, then it creates a new one, but it can't edit "profiles.ini", throws an error
            id = 1;
            #name = "Yo"; # HAS to be "dev-edition-default"
            isDefault = false;  # Only one can be the default

            # Search engines
            search = {
              force = true;
              engines = {
                "nix-packages" = {
                  "name" = "Nix Packages";
                  "urls" = [
                    {
                      "template" = "https://search.nixos.org/packages";
                      "params" = [
                        { "name" = "type"; "value" = "packages"; }
                        { "name" = "query"; "value" = "{searchTerms}"; }
                      ];
                    }
                  ];
                  "icon" = "${(attr.packageChannel).nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  "definedAliases" = [ "@np" ];
                };
                "nixos-wiki" = {
                  "name" = "NixOS Wiki";
                  "urls" = [
                    {
                      "template" = "https://nixos.wiki/index.php?search={searchTerms}";
                    }
                  ];
                  "icon" = "https://nixos.wiki/favicon.png";
                  "updateInterval" = 24 * 60 * 60 * 1000; # Every day
                  "definedAliases" = [ "@nw" ];
                };
                "google"."metaData"."alias" = "@g";
                "bing"."metaData"."hidden" = true;
                "amazon"."metaData"."hidden" = true;
                "ebay"."metaData"."hidden" = true;
                "wikipedia"."metaData"."hidden" = true;
              };
              default = "ddg"; # DuckDuckGo is more reliable than Google
              order = [
                "ddg"
                "google"
              ];
            };

            # Extensions
            extensions.packages = (attr.template).extensions;

          };

        };

        # Dotfiles: Scripts
        config.home.file = (
          let
            fx-autoconfig = attr.fx-autoconfig;
            scripts = attr.firefox-scripts;
            profilePath = ".mozilla/firefox/dev-edition-default";
            mapDirContent = src: dest: (utils.pipe src [

              # Gets the path and returns a set. It only considers the first level
              (x: builtins.readDir x)

              # Transforms the set into a list of filenames
              (x: builtins.attrNames x)

              # Prepare the list to be turned into a set
              (x: builtins.map (filename: {
                name = "${dest}/${filename}";
                value = {
                  source = "${src}/${filename}";
                };
              }) x)

              # Transforms the list into a set
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
          } // (
            # Dotfiles: My Firefox styles
            mapDirContent "${scripts}/chrome/CSS" "${profilePath}/chrome/CSS"
          ) // (
            # Dotfiles: My Firefox scripts
            mapDirContent "${scripts}/chrome/JS" "${profilePath}/chrome/JS"
          ) // {
            # Modified dotfile: Custom accent color
            "${profilePath}/chrome/CSS/addAccentColor.uc.css" = {
              source = ((attr.packageChannel).runCommand "customize-accent-color" {} (with config.lib.stylix.colors; ''
                sed \
                  -e 's/--accent-color: .*/--accent-color: #${base0D};/' \
                  -e 's/--inactive-color: .*/--inactive-color: #${base01};/' \
                  "${scripts}/chrome/CSS/addAccentColor.uc.css" \
                  > $out
              ''));
            };
            # Modified dotfile: Also hide Tab-Stash icon
            "${profilePath}/chrome/CSS/improveSearchBarButtons.uc.css" = {
              source = ((attr.packageChannel).runCommand "add-extra-item" {} ''
                sed \
                  -e 's/#picture-in-picture-button /#picture-in-picture-button, #pageAction-urlbar-tab-stash_condordes_net /' \
                  "${scripts}/chrome/CSS/improveSearchBarButtons.uc.css" \
                  > $out
              '');
            };
          }
        );

      };
    };
  };

}
