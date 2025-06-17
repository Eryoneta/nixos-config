{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # FastFetch: Shows general system information
  config.modules."fastfetch" = {
    tags = [ "basic-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.infoGrid = rec {
      # Constants
      firstElemIcon = "┌ ";
      middleElemIcon = "├ ";
      lastElemIcon = "└ ";
      # Functions
      mkItem = id: name: {
        _type = "basic";
        inherit id name;
      };
      mkCustomItem = setting: {
        _type = "custom";
        inherit setting;
      };
      mkBlock = title: list: (
        width: (
          let
            isEven = number: (((number / 2) * 2) == number); # Check if a number is even
            # Note: There is no "%" here, in Nix land
            #   Here, the solution is to divide the number, then multiply it. An even number is unchanged by the end of it
            gridWidth = ( # Width should be even
              if (isEven width) then width else (width + 1)
            );
            mkLine = size: ( # Returns "─" multiplied by "size", so a line
              builtins.concatStringsSep "" (
                builtins.genList (x: "─") size
              )
            );
            mkHeader = title: ( # Creates a valid header module
              let
                titleIsOdd = !(isEven (builtins.stringLength title));
                blockTitle = ( # Title length should be even
                  if (titleIsOdd) then (title + "─") else title
                );
                titleLength = ((builtins.stringLength title) + (if (titleIsOdd) then 1 else 0));
                # Note: Very important. "builtins.stringLength" returns the total of bytes, not total of characters!
                lineWidth = ((gridWidth - 2) - titleLength) / 2;
              in {
                "type" = "custom";
                  "format" = "{#keys}{#1}┌${mkLine lineWidth}${blockTitle}${mkLine lineWidth}┐{#}";
              }
            );
            mkElem = pretext: item: (
              if (builtins.isAttrs item) then (
                if (builtins.hasAttr "_type" item) then (
                  { # Switch case
                    "basic" = { # Creates a valid, basic module
                      "type" = item.id;
                      "key" = (pretext + item.name);
                    };
                    "custom" = item.setting; # Here, "settings" should be a valid module
                  }.${item._type}
                ) else (builtins.throw "Invalid info grid configuration") # An unknown set
              ) else item # Should be a string
            );
            mkFirstElem = item: (mkElem firstElemIcon item);
            mkMiddleElem = item: (mkElem middleElemIcon item);
            mkLastElem = item: (mkElem lastElemIcon item);
            mkFooter = { # Creates a valid footer module
              "type" = "custom";
              "format" = "{#keys}{#1}└${mkLine (gridWidth - 2)}┘{#}";
            };
            # Items
            firstItem = (builtins.head list);
            lastItem = (builtins.elemAt list ((builtins.length list) - 1));
            middleItems = (builtins.filter (item: (
              (item != firstItem && item != lastItem) # Middle items should not be the first nor the last items
            )) list);
          in (builtins.concatLists [ # Merge all lists into a single list
            [ (mkHeader title) ] # Header
            [ (mkFirstElem firstItem) ] # First item
            (builtins.map (item: (mkMiddleElem item)) middleItems) # Middle items
            [ (mkLastElem lastItem) ] # Last item
            [ mkFooter ] # Footer
          ])
        )
      );
      mkGrid = width: items: (
        builtins.concatLists ( # Merge all lists into a single list
          builtins.map (item: (
            if(builtins.isFunction item) then (
              item width # It's a function = It's a Block, and it requires "width"
            ) else (
              if (!(builtins.isList item)) then (
                [ item ] # All items should be lists
              ) else item
            )
          )) items
        )
      );
    };
    setup = { attr }: {
      home = { # (Home-Manager Module)
        config.programs.fastfetch = {
          enable = true;
          package = (attr.packageChannel).fastfetch;
          # Doc: https://github.com/fastfetch-cli/fastfetch/wiki/Configuration
          settings = {
            "logo" = {
              "type" = "builtin";
              "padding" = {
                "top" = 6;
                "left" = 2;
              };
            };
            "modules" = with attr.infoGrid; (mkGrid 72 [
              "break" # Blank space
              (mkBlock "Software" [ # Software
                (mkItem "os" "OS") # OS version + Architecture
                (mkItem "os" "OS" ) # OS version + Architecture
                (mkItem "kernel" "Kernel" ) # Linux kernel version
                (mkItem "packages" "Packages" ) # Total number of packages, including from Flatpak
                (mkItem "terminal" "Terminal" ) # Terminal name and version
                (mkItem "shell" "Shell" ) # Shell name and version
                (mkItem "lm" "LM" ) # Login manager name
                (mkItem "de" "DE" ) # Desktop environment name
                (mkItem "wm" "WM" ) # Window manager name
                (mkItem "opengl" "OpenGL" ) # OpenGL version
                (mkItem "vulkan" "Vulkan" ) # Vulkan version
              ])
              "break" # Blank space
              (mkBlock "Theme" [ # Theme
                (mkItem "theme" "Theme") # Installed theme names
                (mkItem "icons" "Icons") # Icon theme name
              ])
              "break" # Blank space
              (mkBlock "Hardware" [ # Hardware
                (mkItem "board" "Board") # Motherboard model
                (mkCustomItem { # BIOS type and version
                  "type" = "bios";
                  "key" = "${middleElemIcon}BIOS ({type})";
                  "format" = "{version} {release}";
                })
                (mkItem "cpu" "CPU") # CPU model
                (mkItem "gpu" "GPU") # GPU model
                (mkCustomItem {
                  "type" = "physicaldisk";
                  "key" = "${middleElemIcon}Disk Device ({name})";
                  "format" = "{size} [{physical-type}, {removable-type}]";
                })
                (mkCustomItem { # Monitor model, resolution, refresh-rate, and size
                  "type" = "display";
                  "key" = "${lastElemIcon}Display ({name})";
                  "format" = "{width}x{height} @ {refresh-rate}Hz in {inch}\" ({type})";
                })
              ])
              "break" # Blank space
              "title" # User@Host
            ]);

          };
        };
      };
    };
  };

}
