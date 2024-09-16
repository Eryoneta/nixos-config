{ tools, pkgs-bundle, ... }: with tools; {
  config = {

    # SSH: Secure connection
    programs.ssh = { # Its always enabled
      package = mkDefault pkgs-bundle.stable.openssh;
      startAgent = mkDefault true; # SSH Agent
    };

  };
}
