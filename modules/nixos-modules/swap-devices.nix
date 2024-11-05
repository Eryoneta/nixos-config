# Swapfile
/*
  - Creates a swapfile
*/
{ config, options, lib, pkgs, utils, ... }:
  let
    cfg = config.swap;
  in {

    options = {
      swap = (
        let
          # swapDeviceOpts = (
          #   builtins.head ((builtins.head options.swapDevices.type.getSubModules).imports) {
          #     inherit config;
          #     inherit options;
          #   }
          # );
          # swapDeviceOptsList = options.swapDevices.type.getSubModules;
          # extraOpt = { ... }: {
          #   options = {
          #     enable = lib.mkOption {
          #       type = lib.types.bool;
          #       default = true;
          #       description = "Enables the swap device.";
          #     };
          #   };
          # };
          # UGLY HACK
          # swapDeviceOptsListFIXED = (
          #   swapDeviceOptsList // (
          #     let
          #       options = swapDeviceOptsList.options;
          #       config = swapDeviceOptsList.config;
          #     in {
          #       config.device = (
          #         let
          #           isLabelDefined = (
          #             if (builtins.hasAttr "isDefined" options.label) then (
          #               options.label.isDefined
          #             ) else false
          #           );
          #         in if (isLabelDefined) then (
          #           lib.mkIf (true) "/dev/disk/by-label/${config.label}"
          #         ) else (
          #           lib.mkIf (false) ""
          #         )
          #       );
          #     }
          #   )
          # );
          # End of UGLY HACK
          # allOpts = swapDeviceOptsListFIXED ++ [ extraOpt ];
          #
          # Note: I REALLY tried, but it DOES NOT work!
        in {

          enable = lib.mkEnableOption ''
            Enables the use of swap devices.
          '';

          devices = lib.mkOption {
            #type = (lib.types.attrsOf (lib.types.submodule allOpts));
            # Note: "submodule" does not work with "swapDevices". Using "attrs" instead...
            # TODO: (NixOS-Modules/SwapDevices): Make it work with options set by "swapDevices" instead of a free set
            type = (lib.types.attrsOf (lib.types.attrs));
            default = {};
            description = ''
              Swap devices as defined by {option}`swapDevices`.

              This option is a set rather than a list.

              The set name does not matter, but it's convenient for recalling the config.
            '';
          };

        }
      );
    };

    config = lib.mkIf (cfg.enable) {

      # Swap devices
      swapDevices = (
        # Map: [ { enable = true; } ] -> [ { } ]
        builtins.map (
          value: builtins.removeAttrs value [ "enable" ]
        ) (
          # Filter: [ { enable = true; } { enable = false; } ] => [ { enable = true; } ]
          builtins.filter (
            # "swap.devices.*.enable" might not be present. True by default
            value: if (builtins.hasAttr "enable" value) then (
              value.enable
            ) else true
          ) (
            # Map: [ "attr1" ] -> [ "value1" ]
            builtins.map (
              value: cfg.devices.${value}
            ) (
              # AttrNames: { attr1 = "value1"; } -> [ "attr1" ]
              builtins.attrNames cfg.devices
            )
          )
        )
      );

    };
  }
