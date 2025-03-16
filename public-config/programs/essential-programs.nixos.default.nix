{ pkgs-bundle, pkgs, ... }@args: with args.config-utils; {
  config = {

    # System programs
    environment.systemPackages = with pkgs-bundle; (
      (with unstable; [

      ])
      ++
      (with stable; [
        home-manager # Home-Manager: Manages home configuration
        fastfetch # FastFetch: Shows general system information
        gparted # GParted: Manages partitions
        git # Git: Versioning
        kdePackages.filelight # Filelight: Disk usage visualizer
        pavucontrol # PulseAudio Volume Control: Tool for system audio

        nix-output-monitor # nix-output-monitor: Prettify nix output
        # Note: Best usage is "sudo ls /dev/null > /dev/null 2>&1 && sudo nixos-rebuild switch --flake <PATH>#<HOSTNAME> --use-remote-sudo --show-trace --print-build-logs --verbose |& nom"
        #   "sudo ls /dev/null > /dev/null 2>&1" requires sudo password, and passes that to "nixos-rebuild"
        #     Otherwise, the password prompt is invisible
        #   "--use-remote-sudo" means only use sudo at the end
        #   "--show-trace" is for full error messages
        #   "--print-build-logs --verbose" is for very detailed output
        #   "|& nom" passes the output to nix-output-monitor to prettify
        
      ])
    );

    # Do NOT include
    environment.plasma6.excludePackages = with pkgs; [
      kdePackages.elisa # Elisa: Music player (Not used)
    ];

  };
}
