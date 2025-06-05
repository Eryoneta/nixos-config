# Swapfile
/*
  - Configures a swap device
*/
{ config, lib, ... }:
  let
    cfg = config.swap;
  in {

    options = {
      swap = {

        enable = lib.mkEnableOption ''
          Enables the use of swap devices.
        '';

        devices = lib.mkOption {
          #type = (lib.types.attrsOf (lib.types.submodule options.swapDevices.type.getSubModules));
          # Note: Throws an error about "label"
          type = (lib.types.attrsOf (lib.types.attrs));
          # Note: Ideally, the set should have the same options of "config.swapDevices.*"
          #   But, extract the exact set is not possible???
          #   Well, non-existent options are complained by "config.swapDevices.*" anyways
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

        # Transforms the set into a list
        (x: builtins.attrValues x)

        # Removes all disabled devices
        (x: builtins.filter (swapDevice: (
          # "config.swap.devices.*.enable" might not be present. True by default
          if (builtins.hasAttr "enable" swapDevice) then (
            swapDevice.enable
          ) else true
        )) x)

        # Removes "enable" from all items
        (x: builtins.map (value: (
          # "config.swapDevices.*" does not contains "enable"!
          builtins.removeAttrs value [ "enable" ]
        )) x)

      ]);

    };
  }
