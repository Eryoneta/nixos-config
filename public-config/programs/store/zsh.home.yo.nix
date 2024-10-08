{ ... }@args: with args.config-utils; {
  config = {

    # ZSH: Shell
    programs.zsh = {

      # Aliases
      shellAliases = {
        nixos-generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      };
      
    };

  };
}
