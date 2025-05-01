{ lib, config, modules, host, pkgs, ... }@args: with args.config-utils; {

  imports = with modules; [
    nixos-modules."garbage-collector-notifier.nix"
  ];

  options = {
    profile.programs.nix = {
      options.enabled = (utils.mkBoolOption true); # Always true
      options.packageChannel = (utils.mkPackageOption pkgs);
    };
  };

  config = with config.profile.programs.nix; (lib.mkIf (options.enabled) {

    # Nix: System package manager
    nix = {
      package = (utils.mkDefault) (options.packageChannel).nix; # Same package as the system

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
      settings = {
        auto-optimise-store = (utils.mkDefault) true; # Remove duplicates and creates hardlinks
        # TODO: (Nix) Remove once flakes are sorted out (Might take a while!)
        experimental-features = [ "nix-command" "flakes" ]; # Experimental features
      };

      # Sync NIX_PATH with "inputs.nixpkgs.pkgs"
      # This means "nix-shell" uses "nixpkgs" from this flake and NOT "<nixpkgs>" from "nix-channel" (Obsolete!)
      #nixPath = [ "nixpkgs=${pkgs.path}" ];
      # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

      # Sync Flake Registry with "inputs.nixpkgs"
      # This means "nix shell" uses "nixpkgs" from this flake and not necessarily "github:NixOS/nixpkgs/nixpkgs-unstable"
      #registry.nixpkgs.flake = inputs.nixpkgs;
      # Apparently, NixOS already does that: https://github.com/NixOS/nixpkgs/blob/release-24.05/nixos/modules/misc/nixpkgs-flake.nix

    };

  });
  
}
