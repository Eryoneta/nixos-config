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

      # Imports
      nixosSystem = (import ./flake-modules/nixos-system.nix self.outPath);
      homeManagerModule = (import ./flake-modules/home-manager-module.nix self.outPath);
      homeManagerStandalone = (import ./flake-modules/home-manager-standalone.nix self.outPath);
      userHostScheme = (import ./flake-modules/user-host-scheme.nix self.outPath);
      packageBundle = (import ./flake-modules/package-bundle.nix self.outPath);
      pubPrivDomains = (import ./flake-modules/public-private-domains.nix self.outPath);
      autoUpgradeList = (import ./flake-modules/auto-upgrade-list.nix self.outPath);

      # Hosts
      LiCo = userHostScheme.buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = "Flake:_Nix-Modules"; #[a-zA-Z0-9:_.-]*
      };
      NeLiCo = userHostScheme.buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = ""; #[a-zA-Z0-9:_.-]*
      };

      # Users
      Yo = userHostScheme.buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
        configDevFolder = "/home/yo/Utilities/SystemConfig/nixos-config-dev";
      };
      Eryoneta = userHostScheme.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
        configFolder = "/home/eryoneta/.nixos-config";
      };

      # Common Configurations
      userHostSchemeConfig = user: host: {
        inherit user;
        inherit host;
      };
      packageBundleConfig = host: {
        architecture = host.system.architecture;
        packages = (with extraArgs; {
          stable = nixpkgs-stable;
          unstable = nixpkgs-unstable;
          unstable-fixed = nixpkgs-unstable-fixed;
        });
      };
      pubPrivDomainsConfig = user: {
        # Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
        # But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
        # So, all changes happens in 'develop', and 'main' only gets occasional system upgrades
        configPath = if (user.username == "yo") then user.configDevFolder else user.configFolder;
        # configPath = user.configFolder;
        folders = {
          dotfiles = "/dotfiles";
          programs = "/programs";
          resources = "/resources";
          secrets = "/secrets";
        };
        absolutePaths.dotfiles = true;
      };
      autoUpgradeListConfig = {
        packages = (with extraArgs; {
          inherit nixpkgs;
          inherit home-manager;
          inherit nixpkgs-stable;
          inherit nixpkgs-unstable;
          # inherit nixpkgs-unstable-fixed;
        });
      };

      # Common NixOS Configuration
      buildCommonConfig = user: host: (
        # NixOS-System
        nixosSystem.build {
          architecture = host.system.architecture;
          package = extraArgs.nixpkgs;
          modifiers = [
            # User-Host-Scheme
            (userHostScheme.buildFor.nixosSystem (userHostSchemeConfig user host))
            # Home-Manager-Module
            (homeManagerModule.build {
              username = user.username;
              package = extraArgs.home-manager;
              modifiers = [
                # User-Host-Scheme
                (userHostScheme.buildFor.homeManagerModule (userHostSchemeConfig user host))
                # Pkgs-Bundle
                (packageBundle.buildFor.homeManagerModule (packageBundleConfig host))
                # Public-Private-Zones
                (pubPrivDomains.buildFor.homeManagerModule (pubPrivDomainsConfig user))
              ];
            })
            # Pkgs-Bundle
            (packageBundle.buildFor.nixosSystem (packageBundleConfig host))
            # Public-Private-Zones
            (pubPrivDomains.buildFor.nixosSystem (pubPrivDomainsConfig user))
            # Auto-Upgrade-List
            (autoUpgradeList.buildFor.nixosSystem (autoUpgradeListConfig))
          ];
        }
      );

      # Common Home-Manager Configuration
      buildCommonHMConfig = user: host: (
        # Home-Manager-Standalone
        homeManagerStandalone.build {
          package = extraArgs.home-manager;
          systemPackage = extraArgs.nixpkgs;
          username = user.username;
          modifiers = [
            # User-Host-Scheme
            (userHostScheme.buildFor.homeManagerStandalone (userHostSchemeConfig user host))
            # Pkgs-Bundle
            (packageBundle.buildFor.homeManagerStandalone (packageBundleConfig host))
            # Public-Private-Zones
            (pubPrivDomains.buildFor.homeManagerStandalone (pubPrivDomainsConfig user))
          ];
        }
      );
      
    in {

      # NixOS + Home Manager
      nixosConfigurations = {
        "Yo@LiCo" = (buildCommonConfig Yo LiCo);
        #"Yo@NeLiCo" = (buildCommonConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = (buildCommonConfig Eryoneta NeLiCo);
      };
      
      # Home Manager
      homeConfigurations = {
        "Yo@LiCo" = (buildCommonHMConfig Yo LiCo);
        #"Yo@NeLiCo" = (buildCommonHMConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = (buildCommonHMConfig Eryoneta NeLiCo);
      };

    }
  );
}
