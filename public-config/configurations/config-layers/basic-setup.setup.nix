{ ... }@args: with args.config-utils; { # (Setup Module)
  config.modules."basic-setup" = {

    # Configuration
    tags = [ "basic-setup" ];
    includeTags = [ "core-setup" ];

  };

}
