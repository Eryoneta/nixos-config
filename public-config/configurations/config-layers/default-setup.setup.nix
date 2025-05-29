{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."default-setup" = {

    # Configuration
    tags = [ "default-setup" ];
    includeTags = [
      "core-setup" "basic-setup"
      "system-tool"
      "tool-office"
    ];

  };

}
