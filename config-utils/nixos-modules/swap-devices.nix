# Swapfile
/*
  - Creates a swapfile
*/
{ config, options, lib, ... }:
  let
    cfg = config.swap;
  in {

    options = {
      swap = {

        enable = lib.mkEnableOption ''
          Enables the use of swap devices.
        '';

        devices = lib.mkOption {
          type = (lib.types.attrsOf (lib.types.attrs));
          # Note: Ideally, the set should have the same options of "config.swapDevices.*"
          #   But, extract the exact set is not possible???
          #   Well, non-existent options are complained by "config.swapDevices.*" anyways
          #type = (lib.types.attrsOf (lib.types.submodule options.swapDevices.type.getSubModules));
          # Note: Throws an error about "label"
          default = {};
          description = ''
            Swap devices as defined by {option}`swapDevices`.

            This option is a set rather than a list.

            The set name does not matter, but it's convenient for recalling the config.
          '';
        };

      };
    };

    config = lib.mkIf (cfg.enable) {

      # Swap devices
      swapDevices = (lib.pipe cfg.devices [
        # AttrNames: { attr1 = "value1"; } -> [ "attr1" ]
        (x: builtins.attrNames x)

        # Map: [ "attr1" ] -> [ "value1" ]
        (x: builtins.map (
          value: cfg.devices.${value}
        ) x)

        # Filter: [ { enable = true; } { enable = false; } ] => [ { enable = true; } ]
        (x: builtins.filter (
          # "swap.devices.*.enable" might not be present. True by default
          value: if (builtins.hasAttr "enable" value) then (
            value.enable
          ) else true
        ) x)

        # Map: [ { enable = true; } ] -> [ { } ]
        (x: builtins.map (
          value: builtins.removeAttrs value [ "enable" ]
        ) x)
      ]);

    };
  }
