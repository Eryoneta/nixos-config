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

    # Config with submodules included
    # Very ugly! I hope its temporary!
    # Calling this whole flake with "?submodules=1" is too limited! It doesn't support "git worktree"!
    # Flakes should be able to find submodules by default!
    complete-config-dev = {
      url = "git+file:///home/yo/Utilities/SystemConfig/nixos-config-dev?submodules=1";
      flake = false;
    };

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Imports
      nix-utils = (import ./modules/nix-modules/mapDir.nix);
      flake-modules = (
        # MapAttrs: { "feat.nix" = ./.../feat.nix; } -> { "feat.nix" = (import ./.../feat.nix self.outPath); }
        builtins.mapAttrs (
          name: value: (import value self.outPath)
        ) (nix-utils.mapDir ./modules/flake-modules)
      );

      # Hosts
      LiCo = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = "Flake:_Modules"; #[a-zA-Z0-9:_.-]*
      };
      NeLiCo = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = ""; #[a-zA-Z0-9:_.-]*
      };
      HyperV_VM = flake-modules."user-host-scheme.nix".buildHost {
        hostname = "hyper-v_vm";
        name = "HyperV_VM";
        system.label = ""; #[a-zA-Z0-9:_.-]*
      };

      # Users
      Yo = flake-modules."user-host-scheme.nix".buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Utilities/SystemConfig/nixos-config";
        configDevFolder = "/home/yo/Utilities/SystemConfig/nixos-config-dev";
      };
      Eryoneta = flake-modules."user-host-scheme.nix".buildUser {
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
        privateDirPath = (extraArgs.complete-config-dev + "/private-config");
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
      mapModulesDirConfig = {
        directory = ./modules;
      };

      # Common NixOS Configuration
      buildCommonConfig = user: host: (
        # NixOS-System
        flake-modules."nixos-system.nix".build {
          architecture = host.system.architecture;
          package = extraArgs.nixpkgs;
          modifiers = [
            # User-Host-Scheme
            (flake-modules."user-host-scheme.nix".buildFor.nixosSystem (userHostSchemeConfig user host))
            # Home-Manager-Module
            (flake-modules."home-manager-module.nix".build {
              username = user.username;
              package = extraArgs.home-manager;
              modifiers = [
                # User-Host-Scheme
                (flake-modules."user-host-scheme.nix".buildFor.homeManagerModule (userHostSchemeConfig user host))
                # Pkgs-Bundle
                (flake-modules."package-bundle.nix".buildFor.homeManagerModule (packageBundleConfig host))
                # Public-Private-Zones
                (flake-modules."public-private-domains.nix".buildFor.homeManagerModule (pubPrivDomainsConfig user))
                # Map-Modules-Dir
                (flake-modules."map-modules-directory.nix".buildFor.homeManagerModule (mapModulesDirConfig))
              ];
            })
            # Pkgs-Bundle
            (flake-modules."package-bundle.nix".buildFor.nixosSystem (packageBundleConfig host))
            # Public-Private-Zones
            (flake-modules."public-private-domains.nix".buildFor.nixosSystem (pubPrivDomainsConfig user))
            # Auto-Upgrade-List
            (flake-modules."auto-upgrade-list.nix".buildFor.nixosSystem (autoUpgradeListConfig))
            # Map-Modules-Dir
            (flake-modules."map-modules-directory.nix".buildFor.nixosSystem (mapModulesDirConfig))
          ];
        }
      );

      # Common Home-Manager Configuration
      buildCommonHMConfig = user: host: (
        # Home-Manager-Standalone
        flake-modules."home-manager-standalone.nix".build {
          package = extraArgs.home-manager;
          systemPackage = extraArgs.nixpkgs;
          username = user.username;
          modifiers = [
            # User-Host-Scheme
            (flake-modules."user-host-scheme.nix".buildFor.homeManagerStandalone (userHostSchemeConfig user host))
            # Pkgs-Bundle
            (flake-modules."package-bundle.nix".buildFor.homeManagerStandalone (packageBundleConfig host))
            # Public-Private-Zones
            (flake-modules."public-private-domains.nix".buildFor.homeManagerStandalone (pubPrivDomainsConfig user))
            # Map-Modules-Dir
            (flake-modules."map-modules-directory.nix".buildFor.homeManagerStandalone (mapModulesDirConfig))
          ];
        }
      );
      
    in {

      # NixOS + Home Manager
      nixosConfigurations = {
        "Yo@LiCo" = (buildCommonConfig Yo LiCo);
        "Yo@HyperV_VM" = (buildCommonConfig Yo HyperV_VM);
        #"Yo@NeLiCo" = (buildCommonConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = (buildCommonConfig Eryoneta NeLiCo);
      };
      
      # Home Manager
      homeConfigurations = {
        "Yo@LiCo" = (buildCommonHMConfig Yo LiCo);
        "Yo@HyperV_VM" = (buildCommonHMConfig Yo HyperV_VM);
        #"Yo@NeLiCo" = (buildCommonHMConfig Yo NeLiCo);
        #"Eryoneta@NeLiCo" = (buildCommonHMConfig Eryoneta NeLiCo);
      };

    }
  );
}
