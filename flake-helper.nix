let

  # Defaults
  default = {

    # Default Host
    host = {
      hostname = "nixos";
      name = "nixos";
      user = default.user;
      system = {
        architecture = "x86_64-linux";
        label = "";
      };
      configFolder = "/etc/nixos";
    };

    # Default User
    user = {
      username = "nixos";
      name = "nixos";
      host = default.host;
      dotfolder-public = "";
      dotfolder-private = "";
      configFolder = default.host.configFolder;
    };

    # Default NixOS Config
    nixosConfig = {
      package = {};
      specialArgs.pgks-bundle = {};
      homeManagerConfig = default.homeManagerConfig // {
        enable = false;
      };
    };

    # Default Home-Manager Config
    homeManagerConfig = {
      package = {};
      systemPackage = {};
      extraSpecialArgs.pgks-bundle = {};
    };

  };

  # Host-User-Pair Builder
  buildPair = user: host: {
    user = user // {
      host = host // {
        user = user; # User -> Host -> User -> void
        configFolder = user.configFolder;
      };
    };
    host = host // {
      user = user // {
        host = host; # Host -> User -> Host -> void
      };
      configFolder = user.configFolder;
    };
  };

  # Packages Builder
  pkgsConfig = host: {
    system = host.system.architecture;
    config.allowUnfree = true;
  };
  # MapAttrs: { pkgs = pkgs; } -> { pkgs = import pkgs { ... }; }
  buildPkgsBundle = host: packages:
    builtins.mapAttrs (name: value: import value (pkgsConfig host)) packages;

in {

  # Host Builder
  buildHost = host: default.host // {
    hostname = host.hostname;
    name = host.name;
    system = default.host.system // {
      label = host.system.label;
    };
  };

  # User Builder
  buildUser = user: default.user // {
    username = user.username;
    name = user.name;
    configFolder = user.configFolder;
    dotfolder-public = "${user.configFolder}/public-config/dotfiles";
    dotfolder-private = "${user.configFolder}/private-config/dotfiles";
  };

  # System Builder
  buildSystem = { user, host, nixosConfig ? default.nixosConfig }:
    let
      pair = (buildPair user host);
      homeManagerConfig = nixosConfig.homeManagerConfig;
    in
      nixosConfig.package.lib.nixosSystem {
        system = pair.host.system.architecture;
        modules = [
          (./. + "/hosts/${pair.host.hostname}/configuration.nix")
        ]
        ++ (if homeManagerConfig.enable then [
          homeManagerConfig.package.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${pair.user.username} = import (./. + "/users/${pair.user.username}/home.nix");
              extraSpecialArgs = {
                user = pair.user;
                pkgs-bundle = (buildPkgsBundle pair.host homeManagerConfig.extraSpecialArgs.pgks-bundle);
              };
            };
          }
        ] else []);
        specialArgs = {
          host = pair.host;
          pkgs-bundle = (buildPkgsBundle pair.host nixosConfig.specialArgs.pgks-bundle);
        };
      };

  # Home-Manager Builder
  buildHomeManager = { user, host, homeManagerConfig ? default.homeManagerConfig }:
    let
      pair = (buildPair user host);
      systemPackage = homeManagerConfig.systemPackage;
    in 
      homeManagerConfig.package.lib.homeManagerConfiguration {
        pkgs = systemPackage.legacyPackages.${pair.host.system.architecture};
        modules = [
          (./. + "/users/${pair.user.username}/home.nix")
        ];
        extraSpecialArgs = {
          user = pair.user;
          pkgs-bundle = (buildPkgsBundle pair.host homeManagerConfig.extraSpecialArgs.pgks-bundle);
        };
      };

}