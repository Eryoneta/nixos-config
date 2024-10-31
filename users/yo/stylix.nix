{ config, pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # Stylix: Themes and colors manager
    stylix = {
      enable = true;
      autoEnable = true; # Automatically set for installed apps

      # Wallpaper
      image = ( # Wallpaper
        pkgs-bundle.nixos-artwork."wallpaper/nix-wallpaper-simple-blue.png"
      );
      imageScalingMode = "fill"; # Fill background

      # Cursor
      cursor = {
        #package = "";
        #name = "";
        # TODO: (Yo/Stylix) Set custom cursor
        size = 24;
      };

      # Fonts
      fonts = {
        sizes = { # Font sizes
          applications = 10; 
          terminal = 10;
        };
      };

      # Theme
      polarity = "dark"; # Theme
      # base16Scheme = with pkgs-bundle.stable; ( # Colors
      #   # Note: Between stable and unstable, some themes might not exist
      #   "${base16-schemes}/share/themes/oxocarbon-dark.yaml"
      # );
      base16Scheme = ( # Colors
        utils.toFile "yo-theme.yaml" ( # Custom colors
          utils.toYAML {
            "system" = "base16";
            "name" = "Yo Dark";
            "author" = "Yo";
            "variant" = "dark";
            "palette" = {
              "base00" = ( # Default Background
                "161616"
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
                "492387" # Strong Purple
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
