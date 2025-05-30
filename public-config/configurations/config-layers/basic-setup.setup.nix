{ ... }@args: with args.config-utils; { # (Setup Module)

  # Basic setup
  config.modules."basic-setup" = {
    tags = [ "basic-setup" ];
    includeTags = [
      "core-setup"
      "essential-tool"
    ];
  };

}
