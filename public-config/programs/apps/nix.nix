{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # Nix: Package manager
  config.modules."nix" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.system; # (Also included with NixOS)
    setup = { attr }: {
      nixos = { pkgs, inputs, host, nixos-modules, ... }: { # (NixOS Module)

        # Imports
        imports = [
          nixos-modules."garbage-collector-notifier.nix"
        ];

        # Configuration
        config.nix = {
          package = (utils.mkDefault) (attr.packageChannel).nix;

          # Garbage Collector
          gc = {
            automatic = (utils.mkDefault) true;
            dates = (utils.mkDefault) "*-*-* 18:00:00"; # Every day, 18h00

            # Notifier ("garbage-collector-notifier.nix")
            notifier = {
              enable = (utils.mkDefault) true;
              systemUser = host.userDev.username;
              informStart = {
                show = (utils.mkDefault) true;
                time = (utils.mkDefault) 15;
              };
              informConclusion = {
                show = (utils.mkDefault) true;
                time = (utils.mkDefault) 30;
              };
            };

          };

          # Nix Store
          settings.auto-optimise-store = (utils.mkDefault) true; # Remove duplicates and creates hardlinks

          # Sync NIX_PATH with "inputs.nixpkgs.pkgs"
          # This means "nix-shell" uses "nixpkgs" from this flake and NOT "<nixpkgs>" from "nix-channel" (Obsolete!)
          #nixPath = [ "nixpkgs=${pkgs.path}" ];
          # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

          # Sync Flake Registry with "inputs.nixpkgs"
          # This means "nix shell" uses "nixpkgs" from this flake and not necessarily "github:NixOS/nixpkgs/nixpkgs-unstable"
          #registry.nixpkgs.flake = inputs.nixpkgs;
          # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

        };

      };
      home = { # (Home-Manager Module)

        # Garbage Collector
        config.nix.gc = {
          automatic = (utils.mkDefault) true;
          frequency = (utils.mkDefault) "*-*-* 19:00:00"; # Every day, 19h00
        };
        # Note: This one collects user specific ones

      };
    };
  };

}
