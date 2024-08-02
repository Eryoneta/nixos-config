{
  # Description
  description = "Yo Flake";

  # Inputs
  inputs = {

    # NixOS (AutoUpgrade)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home-Manager (AutoUpgrade)
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Unstable Packages (Manual Upgrade)
    nixpkgs-unstable-fixed.url = "github:NixOS/nixpkgs/nixos-unstable";

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Packages
      nixpkgs = extraArgs.nixpkgs;
      home-manager = extraArgs.home-manager;
      pgks-bundle = {
        stable = extraArgs.nixpkgs-stable;
        unstable = extraArgs.nixpkgs-unstable;
        unstable-fixed = extraArgs.nixpkgs-unstable-fixed;
      };

      # Flake Helper
      helper = import ./flake-helper.nix;

      # Hosts
      LiCo = helper.buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = "AutoUpgrade_Git_Fix"; #[a-zA-Z0-9:_.-]*
      };
      NeLiCo = helper.buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = ""; #[a-zA-Z0-9:_.-]*
      };

      # Users
      Yo = (helper.buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
      }) // (
        # Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
        # But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
        # So, all changes happens in 'develop', and 'main' only gets occasional upgrades
        # ...If the folder "nixos-config-dev" is present, that is
        if (builtins.pathExists /home/yo/Utilities/SystemConfig/nixos-config-dev) then (
          let
            configDevFolder = "/home/yo/Utilities/SystemConfig/nixos-config-dev";
          in {
            private.dotfiles = "${configDevFolder}/private-config/dotfiles";
            private.resources = "${configDevFolder}/private-config/resources";
            private.secrets = "${configDevFolder}/private-config/secrets";
          } 
        ) else {}
      );
      Eryoneta = helper.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
        configFolder = "/home/eryoneta/.nixos-config";
      };
      
      # Common Config
      commonSystemConfig = user: host: {
        inherit user;
        inherit host;
        nixosConfig = {
          package = nixpkgs;
          homeManagerConfig = {
            enable = true;
            package = home-manager;
            extraSpecialArgs.pgks-bundle = pgks-bundle;
          };
          specialArgs.pgks-bundle = pgks-bundle;
        };
      };
      commonHMConfig = user: host: {
        inherit user;
        inherit host;
        homeManagerConfig = {
          package = home-manager;
          systemPackage = nixpkgs;
          extraSpecialArgs.pgks-bundle = pgks-bundle;
        };
      };

    in {

      # NixOS + Home Manager
      nixosConfigurations = {
        "Yo@LiCo" = helper.buildSystem (commonSystemConfig Yo LiCo);
        #"Yo@NeLiCo" = helper.buildSystem (commonSystemConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = helper.buildSystem (commonSystemConfig Eryoneta NeLiCo);
      };
      
      # Home Manager
      homeConfigurations = {
        "Yo@LiCo" = helper.buildHomeManager (commonHMConfig Yo LiCo);
        #"Yo@NeLiCo" = helper.buildHomeManager (commonHMConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = helper.buildHomeManager (commonHMConfig Eryoneta NeLiCo);
      };

    }
  );
}
