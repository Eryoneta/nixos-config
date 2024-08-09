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
      configFolder = default.host.configFolder;
      public = {
        dotfolder = "";
        resources = "";
        secrets = "";
      };
      private = {
        dotfolder = "";
        resources = "";
        secrets = "";
      };
    };

    # Default NixOS Config
    nixosConfig = {
      package = {};
      specialArgs.pgks-bundle = {};
      specialArgs.auto-upgrade = [];
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
  buildPkgsBundle = host: packages: (
    # MapAttrs: { pkgs = pkgs; } -> { pkgs = import pkgs { ... }; }
    builtins.mapAttrs (name: value: import value (pkgsConfig host)) packages
  );

  # AutoUpgradeList Builder
  buildAutoUpgradeList = autoUpgradePackages: (
    let
      # AttrNames: { pkgs = ...; } -> [ "pkgs" ]
      getAttrList = item: (builtins.attrNames item);
      # ElemAt: [ "pkgs" ] -> "pkgs"
      getPkgsName = item: (builtins.elemAt (getAttrList item) 0);
    in (
      # Map: [ { pkgs = ...; } ] -> [ "pkgs" ]
      builtins.map (pkgs: (getPkgsName pkgs)) autoUpgradePackages
    )
  );

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
    public = {
      dotfiles = "${user.configFolder}/public-config/dotfiles";
      resources = "${user.configFolder}/public-config/resources";
      secrets = "${user.configFolder}/public-config/secrets";
    };
    private = {
      dotfiles = "${user.configFolder}/private-config/dotfiles";
      resources = "${user.configFolder}/private-config/resources";
      secrets = "${user.configFolder}/private-config/secrets";
    };
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
        } // (nixosConfig.specialArgs // ({ # Any set inside "nixosConfig.specialArgs" is automatically included
          # But "nixosConfig.specialArgs.pkgs-bundle" needs to have all its packages imported to be used
          # And needs to override the original "nixosConfig.specialArgs.pkgs-bundle"
          pkgs-bundle = (buildPkgsBundle pair.host nixosConfig.specialArgs.pgks-bundle);
        } // {
          auto-upgrade-pkgs = (buildAutoUpgradeList nixosConfig.specialArgs.auto-upgrade-pkgs);
        }));
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