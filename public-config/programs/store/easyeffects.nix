{ config, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # EasyEffects: Tool for audio effects
  config.modules."easyeffects" = {
    tags = [ "default-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.mkSymlink = config.modules."configuration".attr.mkSymlink;
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ easyeffects ];

        # Autostart
        config.xdg.configFile."autostart/easyeffects-service.desktop" = {
          text = utils.toINI {
            "Desktop Entry" = {
              "Name" = "Easy Effects";
              "Icon" = "com.github.wwmm.easyeffects";
              "Comment" = "Easy Effects Service";
              "Exec" = "easyeffects --gapplication-service";
              "StartupNotify" = false;
              "Terminal" = false;
              "Type" = "Application";
            };
          };
        };

        # Dotfiles
        config.xdg.configFile."easyeffects/output/LoudnessEqualizer.json" = (attr.mkSymlink {
          public-dotfile = "easyeffects/.config/easyeffects/output/LoudnessEqualizer.json";
        });
        config.xdg.configFile."easyeffects/autoload/output/alsa_output.pci-0000_08_00.6.analog-stereo:analog-output-lineout.json" = (attr.mkSymlink {
          public-dotfile = "easyeffects/.config/easyeffects/autoload/output/alsa_output.pci-0000_08_00.6.analog-stereo:analog-output-lineout.json";
        });

      };
    };
  };

}
