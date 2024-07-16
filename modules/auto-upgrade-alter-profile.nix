{ config, pkgs, lib, ... }:
  let
    # Depende de "nixpkgs/nixos/modules/tasks/auto-upgrade.nix"
    cfg = config.system.autoUpgrade;
    cfg_ap = config.system.autoUpgrade.alterProfile;
  in {

    options = {
      system.autoUpgrade.alterProfile = {

        enable = lib.mkEnableOption ''
          Enables a secondary profile menu entry inside the bootloader to separate system-updates generatons from others.
        '';

        name = lib.mkOption {
          type = lib.types.strMatching "[a-zA-Z0-9:_.-]*";
          description = ''
            The name of the profile.

            It can only contain letters, numbers, and the following symbols: `:`, `_`, `.`, and `-`.
          '';
          default = "System_Updates";
        };

        configurationLimit = lib.mkOption {
          type = lib.types.int;
          description = "Maximum number of latest generations in the profile menu.";
          default = 100;
        };

      };
    };

    config = lib.mkIf (cfg.enable && cfg_ap.enable) {

      assertions = [{
        assertion = !(cfg_ap.configurationLimit < 2 || cfg_ap.configurationLimit > 9999);
        message = ''
          The option 'system.autoUpgrade.alterProfile.configurationLimit' cannot be less than 2 or more than 9999.
        '';
      }];

      # Flag para executar 'nixos-rebuild' com '--profile-name'
      system.autoUpgrade.flags = [ "--profile-name ${cfg_ap.name}" ];
      systemd.services."nixos-upgrade" = {
        serviceConfig.User = "root";
        path = [ pkgs.nix ];
        # O serviço 'nixos-upgrade' deve executar apenas após este! Isso evita deadSymlink no submenu
        preStart = ''
          nix-env --delete-generations +${toString (cfg_ap.configurationLimit - 1)} --profile /nix/var/nix/profiles/system-profiles/${cfg_ap.name}
        '';
      };

    };
  }
