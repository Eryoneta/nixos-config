{ ... }@args: with args.config-utils; { # (Setup Module)

  # Baloo: File indexer
  config.modules."plasma-baloo" = {
    tags = config.modules."plasma".tags;
    setup = {
      home = { # (Home-Manager Module)

        # Dotfile
        config.programs.plasma.configFile."baloofilerc" = { # (plasma-manager option)
          "Basic Settings" = {
            "Indexing-Enabled" = false; # Disabled
            # Note: Indexing is good, but it ignores too many files. Manual search is absolute, albeith slow. But it works
          };
        };

      };
    };
  };

}
