{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-keyboard-layout" = {

    # Configuration
    tags = [ "basic-setup" ];

    setup = {
      nixos = { # (NixOS Module)
        config = {

          # Keyboard layout
          services.xserver.xkb = {
            layout = "br";
            variant = ""; # All available at: "man xkeyboard-config"
          };
          console.keyMap = "br-abnt2";

        };
      };
    };
  };
}
