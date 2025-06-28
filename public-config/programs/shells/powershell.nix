{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # PowerShell: Shell
  config.modules."powershell" = {
    tags = [ "personal-setup" "developer-setup" "work-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ powershell ];

        # Dotfile: My PowerShell-Prompt
        config.xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1" = {
          source = "${pkgs-bundle.powershell-prompt}/Microsoft.PowerShell_profile.ps1";
        };

      };
    };
  };

}
