{ ... }@args: with args.config-utils; {
  config = {

    # Firefox: Browser
    programs.firefox = {

      # Public profile
      profiles.default = {
        id = 0;
        isDefault = true;

        # Search engines
        search = {
          force = true;
          engines = {
            "Google" = {
              metaData.alias = "@g";
            };
          };
          default = "Google";
        };

        # Settings
        settings = {};

        # Extensions
        extensions = [];

      };

      # Policies
      policies = {};
      
    };

  };
}
