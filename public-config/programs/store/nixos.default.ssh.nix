{ pkgs-bundle, ... }@args: with args.config-utils; {
  config = {

    # SSH: Secure connection
    programs.ssh = { # Its always enabled
      package = mkDefault pkgs-bundle.stable.openssh;
      startAgent = mkDefault true; # SSH Agent
    };

  };
}
