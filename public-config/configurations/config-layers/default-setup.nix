{ ... }@args: with args.config-utils; { # (Setup Module)

  # Default setup
  config.modules."default-setup" = {
    tags = [ "default-setup" ];
    includeTags = [
      "core-setup" "basic-setup"
      "system-tool"
      "tool-office"
    ];
  };

}
