{ ... }@args: with args.config-utils; { # (Setup Module)

  # Core setup
  config.modules."core-setup" = {
    tags = [ "core-setup" ];
    # Does not include anything else
  };

  # Basic setup
  config.modules."basic-setup" = {
    tags = [ "basic-setup" ];
    includeTags = [ "core-setup" ];
  };

  # Default setup
  config.modules."default-setup" = {
    tags = [ "default-setup" ];
    includeTags = [ "basic-setup" ];
  };

  # Personal setup
  config.modules."personal-setup" = {
    tags = [ "personal-setup" ];
    includeTags = [ "default-setup" ];
  };

  # Developer setup
  config.modules."developer-setup" = {
    tags = [ "developer-setup" ];
    includeTags = [ "default-setup" ];
  };

  # SysDev setup
  config.modules."sysdev-setup" = {
    tags = [ "sysdev-setup" ];
    includeTags = [ "default-setup" ];
  };

  # Work setup
  config.modules."work-setup" = {
    tags = [ "work-setup" ];
    includeTags = [ "default-setup" ];
  };

}
