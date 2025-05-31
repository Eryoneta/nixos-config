{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Yo dark theme
  config.modules."theme+yo-dark" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "yo" ];
    setup =  { attr }: {
      home = { config-domain, ... }: { # (Home-Manager Module)

        # Stylix: Themes and colors manager
        config.stylix = {

          # Wallpaper
          image = with config-domain; ( # Wallpaper
            "${private.resources}/wallpapers/Window/006.png"
          );
          imageScalingMode = "fill"; # Fill background

          # Cursor
          cursor = {
            package = (attr.packageChannel).afterglow-cursors-recolored;
            name = "Afterglow-Recolored-Original-joris2";
            size = 24;
          };

          # Fonts
          fonts = {
            emoji = {
              name = "Noto Color Emoji";
              package = (attr.packageChannel).noto-fonts-color-emoji;
            };
            monospace = {
              name = "Envy Code R";
              package = ((attr.packageChannel).nerdfonts.override {
                fonts = [ "EnvyCodeR" ];
              });
            };
            sansSerif = {
              name = "Noto Sans";
              package = (attr.packageChannel).noto-fonts;
            };
            serif = {
              name = "Noto Serif";
              package = (attr.packageChannel).noto-fonts;
            };
            sizes = { # Font sizes
              desktop = 9; # Window titles, bars, widgets, etc
              applications = 9; # Apps UIs
              terminal = 8; # Terminals
              popups = 10; # Popups and notifications
            };
          };

          # Theme
          polarity = "dark"; # Theme
          # Reference: https://github.com/chriskempson/base16/blob/main/styling.md
          base16Scheme = ( # Colors
            utils.toFile "yo-theme.yaml" ( # Custom colors
              utils.toYAML {
                "system" = "base16";
                "name" = "Yo Dark";
                "author" = "Yo";
                "variant" = "dark";
                "palette" = {
                  "base00" = ( # Default Background
                    "161616" # Very Black
                  );
                  "base01" = ( # Lighter Background (Used for Status Bars, Line Number and Folding Marks)
                    "262626" # Dark Black
                  );
                  "base02" = ( # Selection Background
                    "393939" # Lesser Black
                  );
                  "base03" = ( # Comments, Invisibles, Line Highlighting
                    "606060" # Ligher Black
                  );
                  "base04" = ( # Dark Foreground (Used for Status Bars)
                    "dde1e6" # Gray
                  );
                  "base05" = ( # Default Foreground, Caret, Delimiters, Operators
                    "f2f4f8" # Light
                  );
                  "base06" = ( # Light Foreground (Not often used)
                    "ffffff" # White
                  );
                  "base07" = ( # Light Background (Not often used)
                    "1f2273" # Blue Beam
                  );
                  "base08" = ( # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
                    "30b0ae" # Bland Light Blue
                  );
                  "base09" = ( # Integers, Boolean, Constants, XML Attributes, Markup Link Url
                    "2486ff" # Default Blue
                  );
                  "base0A" = ( # Classes, Markup Bold, Search Text Background
                    "9455fa" # Live Purple
                  );
                  "base0B" = ( # Strings, Inherited Class, Markup Code, Diff Inserted
                    "c39eff" # Dead Purple
                  );
                  "base0C" = ( # Support, Regular Expressions, Escape Characters, Markup Quotes
                    "aa00ff" # Strong Purple
                  );
                  "base0D" = ( # Functions, Methods, Attribute IDs, Headings
                    "00fbec" # Blue Star
                  );
                  "base0E" = ( # Keywords, Storage, Selector, Markup Italic, Diff Changed
                    "82cfff" # Pale Blue
                  );
                  "base0F" = ( # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
                    "e1cfff" # Pale Purple
                  );
                };
              }
            )
          );

        };

      };
    };
  };

}
