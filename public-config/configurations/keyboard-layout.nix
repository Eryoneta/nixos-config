{ ... }@args: with args.config-utils; { # (Setup Module)

  # Keyboard layout
  config.modules."keyboard-layout" = {
    tags = [ "basic-setup" ];
    setup = {
      nixos = { # (NixOS Module)

        # Keyboard layout
        config.services.xserver.xkb = {
          layout = "br";
          variant = ""; # All available at: "man xkeyboard-config"
        };
        config.console.keyMap = "br-abnt2";

      };
    };
  };

}
