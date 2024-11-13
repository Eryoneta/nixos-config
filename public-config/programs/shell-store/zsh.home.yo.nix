{ config, ... }@args: with args.config-utils; {
  config = with config.profile.programs.zsh; {

    # ZSH: Shell
    programs.zsh = {

      # Aliases
      shellAliases = {
        "nixos-generations" = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      };
      
    };

  };
}
