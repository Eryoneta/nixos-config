{ ... }@args: with args.config-utils; {
  config = {

    # Variables
    home.sessionVariables = {
      EDITOR = mkDefault "kwrite"; # Default Text Editor
    };

  };
}
