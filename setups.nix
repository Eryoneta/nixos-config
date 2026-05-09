{ ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # Core setup: The bare minimum to have a working system
  config.modules."core-setup" = {
    tags = [ "core-setup" ];
    # Does not include anything else
  };

  # Basic setup: The necessary to have a acceptable system
  config.modules."basic-setup" = {
    tags = [ "basic-setup" ];
    includeTags = [ "core-setup" ];
  };

  # Default setup: The basic for a daily use
  config.modules."default-setup" = {
    tags = [ "default-setup" ];
    includeTags = [ "basic-setup" ];
  };

  # Personal setup: For personal use only
  config.modules."personal-setup" = {
    tags = [ "personal-setup" ];
    includeTags = [ "default-setup" ];
  };

  # Developer setup: For software development
  config.modules."developer-setup" = {
    tags = [ "developer-setup" ];
    includeTags = [ "default-setup" ];
  };

  # SysDev setup: For system maintenance
  config.modules."sysdev-setup" = {
    tags = [ "sysdev-setup" ];
    includeTags = [ "default-setup" ];
  };

  # Work setup: For a job
  config.modules."work-setup" = {
    tags = [ "work-setup" ];
    includeTags = [ "default-setup" ];
  };

  # Note: Any other module shall include these ones, according with the feature it includes

}
