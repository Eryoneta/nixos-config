{ config, pkgs-bundle, config-domain, ... }@args: with args.config-utils; {
  config = with config.profile.programs.vscodium; {

    # VSCodium: (Medium) Code editor
    programs.vscode = {

      # Settings
      userSettings = with config-domain; (
        # Check for "./private-config/dotfiles"
        mkIf (mkFunc.pathExists private.dotfiles) (
          mkFunc.readJSONFile "${private.dotfiles}/vscodium/.config/VSCodium/User/settings.json"
        )
      );

      # Shortcuts
      keybindings = with config-domain; (
        # Check for "./private-config/dotfiles"
        mkIf (mkFunc.pathExists private.dotfiles) (
          mkFunc.readJSONFile "${private.dotfiles}/vscodium/.config/VSCodium/User/keybindings.json"
        )
      );

      # Extensions
      extensions = (
        let
          vscode-marketplace-pkgs = options.packageChannel.vscode-utils.extensionFromVscodeMarketplace;
          vscode-marketplace-extensions = {
            jrebocho.vscode-random = vscode-marketplace-pkgs {
              publisher = "jrebocho";
              name = "vscode-random";
              version = "1.12.0";
              sha256 = "sha256-J5m607m+HnMDApOphO8rOe8HhhU57afIx324o7puKkc=";
            };
          };
        in with options.packageChannel; (
          (with vscode-extensions; [
            jnoortheen.nix-ide # Nix IDE: Nix sintax support
            mhutchie.git-graph # Git Graph: Shows a nice, interactive git log
          ])
          ++
          (with vscode-marketplace-extensions; [
            jrebocho.vscode-random # VSCode-Random: Includes many random generators
          ])
        )
      );

    };

  };
}
