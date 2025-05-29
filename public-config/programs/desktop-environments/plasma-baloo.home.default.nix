{ config, lib, ... }@args: with args.config-utils; {
  config = with config.profile.programs.plasma; (lib.mkIf (options.enabled) {

    # Baloo: File indexer
    programs.plasma.configFile."baloofilerc" = { # (plasma-manager option)
      "Basic Settings" = {
        "Indexing-Enabled" = false; # Disabled
        # Note: Indexing is good, but it ignores too many files. Manual search is absolute, slow, but it works
      };
    };

  });
}
