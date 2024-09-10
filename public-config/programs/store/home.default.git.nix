{ pkgs-bundle, user, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Git: File versioning
      programs.git = {
        enable = mkDefault true;
        package = mkDefault pkgs-bundle.stable.git;
      };

    };
  }
