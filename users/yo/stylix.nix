{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = {

    # Stylix: Themes and colors manager
    stylix = {

      # Wallpaper
      image = ( # Wallpaper
        "${config-domain.private.resources}/wallpapers/Window/006.png"
      );
      imageScalingMode = "fill"; # Fill background

      # Cursor
      cursor = {
        package = pkgs-bundle.stable.afterglow-cursors-recolored;
        name = "Afterglow-Recolored-Original-joris2";
        size = 24;
      };

      # Fonts
      fonts = {
        emoji = {
          name = "Noto Color Emoji";
          package = (pkgs-bundle.stable).noto-fonts-color-emoji;
        };
        monospace = {
          name = "Noto Sans Mono";
          package = (pkgs-bundle.stable).noto-fonts;
        };
        sansSerif = {
          name = "Noto Sans";
          package = (pkgs-bundle.stable).noto-fonts;
        };
        serif = {
          name = "Noto Serif";
          package = (pkgs-bundle.stable).noto-fonts;
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
}
