{
  # Description
  description = "Yo Flake";

  # Inputs
  inputs = {

    # System Inputs
    # NixOS (Auto upgrade)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home-Manager (Auto upgrade)
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Plasma-Manager (Auto upgrade)
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    # Agenix (Auto upgrade)
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    # Stylix (Auto upgrade)
    stylix.url = "github:danth/stylix/release-25.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";

    # Package Inputs
    # Stable Packages (Auto upgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Unstable Packages (Auto upgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Extra Inputs
    # Unstable Unfree Packages (Auto upgrade)
    nixpkgs-unfree-unstable.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    nixpkgs-unfree-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Firefox Addons (Auto upgrade)
    nurpkgs-firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    nurpkgs-firefox-addons.inputs.nixpkgs.follows = "nixpkgs-unfree-unstable"; # Some extensions are unfree
    # Firefox: FX-AutoConfig (Fixed)
    fx-autoconfig.url = "github:MrOtherGuy/fx-autoconfig/f1f61958491c18e690bed8e04e89dd3a8e4a6c4d";
    fx-autoconfig.flake = false;
    # NixOS Artwork (Fixed)
    nixos-artwork.url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-simple-blue.png";
    nixos-artwork.flake = false;
    # Plasma/Icons: Papirus Colors (Fixed)
    papirus-colors-icons.url = "github:varlesh/papirus-colors/ae694e120110ab30ead27c66abc68e74dfd4e4f5";
    papirus-colors-icons.flake = false;
    # Plasma/Plasmoid: TiledMenu (Fixed)
    tiledmenu.url = "github:Zren/plasma-applet-tiledmenu/73e03bd9ff523b01abb31a7c72901ba25918f9d8";
    tiledmenu.flake = false;
    # Plasma/Plasmoid: Window-Title (Fixed)
    windowtitle.url = "github:dhruv8sh/plasma6-window-title-applet/a6eaf5086a473919ed2fffc5d3b8d98237c2dd41";
    windowtitle.flake = false;
    # Plasma/Plasmoid: Configurable-Button (Fixed)
    configurablebutton.url = "github:doncsugar/plasmoid-button/a03f0fe832ff6d3dd528ef263b7e1d4cec0b4440";
    configurablebutton.flake = false;
    # MPV Scripts: InputEvent (Fixed)
    mpv-input-event.url = "github:natural-harmonia-gropius/input-event/refs/tags/v1.3";
    mpv-input-event.flake = false;
    # Prism Launcher (Cracked) (Fixed)
    prismlauncherCRK.url = "github:Diegiwg/PrismLauncher-Cracked/062a55639b4b18e8123a1306e658834ba0ffc137";
    prismlauncherCRK.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: (Flake/Prism-Launcher) Remove once I can afford the original

    # My Utilities
    # PowerShell Prompt (Manual upgrade)
    powershell-prompt.url = "github:Eryoneta/powershell-prompt";
    powershell-prompt.flake = false;
    # Git Tools (Manual upgrade)
    git-tools.url = "github:Eryoneta/git-tools";
    git-tools.flake = false;
    # Firefox Scripts (Manual upgrade)
    firefox-scripts.url = "github:Eryoneta/Firefox-Scripts";
    firefox-scripts.flake = false;

  };

  # Outputs
  outputs = { self, ... }@args: (
    let

      # Utilities
      flake-utils = ((builtins.import ./flake-utils.nix) self.outPath);

      # Auto-Upgrade list
      auto-upgrade-pkgs = (builtins.attrNames (with args; {
        inherit nixpkgs;
        inherit home-manager;
        inherit plasma-manager;
        inherit agenix;
        inherit stylix;
        inherit nixpkgs-stable;
        inherit nixpkgs-unstable;
        inherit nixpkgs-unfree-unstable;
        inherit nurpkgs-firefox-addons;
      }));

      # Package Bundle
      package-bundle = architecture: (
        let
          nixpkgsConfig = {
            system = architecture;
            config.allowUnfree = true;
          };
        in (with args; {
          system = ((builtins.import nixpkgs) nixpkgsConfig);
          stable = ((builtins.import nixpkgs-stable) nixpkgsConfig);
          unstable = ((builtins.import nixpkgs-unstable) nixpkgsConfig);
          firefox-addons = {
            pkgs = nurpkgs-firefox-addons.packages.${architecture};
            buildFirefoxXpiAddon = nurpkgs-firefox-addons.lib.${architecture}.buildFirefoxXpiAddon;
          };
          inherit fx-autoconfig;
          nixos-artwork = {
            "wallpaper/nix-wallpaper-simple-blue.png" = nixos-artwork;
          };
          papirus-colors-icons = {
            "Papirus-Colors-Dark" = "${papirus-colors-icons}/Papirus-Colors-Dark";
          };
          inherit tiledmenu;
          inherit windowtitle;
          inherit configurablebutton;
          inherit mpv-input-event;
          inherit prismlauncherCRK;
          inherit powershell-prompt;
          inherit git-tools;
          inherit firefox-scripts;
        })
      );

      # System-Label ([a-zA-Z0-9:_.-]*)
      # I change it at every rebuild. Very convenient for naming generations!
      systemLabel = (builtins.readFile ./NIXOS_LABEL.txt);

      # Hosts
      hyper-v_vm = flake-utils.buildHost {
        hostname = "hyper-v_vm";
        name = "HyperV_VM";
        system.label = systemLabel;
        system.stateVersion = "24.05";
      };
      lico = flake-utils.buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = systemLabel;
        system.stateVersion = "24.05";
      };
      nelico = flake-utils.buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = systemLabel;
        system.stateVersion = "24.05";
      };

      # Users
      yo = flake-utils.buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config";
        configDevFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config-dev"; # Dev folder
      };
      eryoneta = flake-utils.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
      };

      # Config Builder
      configBuilder = (flake-utils.mkConfigBuilder {
        inputs = args;
        inherit auto-upgrade-pkgs;
        inherit package-bundle;
      });

    in {

      # NixOS + Home-Manager(+ Plasma-Manager + Stylix + Agenix) + Agenix
      nixosConfigurations = (configBuilder.buildSystemConfigurations {
        "HyperV_VM" = {
          users = [ yo ];
          host = hyper-v_vm;
        };
        "LiCo" = {
          users = [ yo ];
          host = lico;
        };
        "NeLiCo" = {
          users = [ yo eryoneta ];
          host = nelico;
        };
        # Note: Each host is duplicated as a VM, for "nixos-rebuild build-vm"
        #   It is necessary, as a VM does not have access to secrets or symlinks out of store
        #   Example: "NeLiCo@VM"
      });

      # Home-Manager + Plasma-Manager + Stylix + Agenix
      homeConfigurations = (configBuilder.buildHomeConfigurations {
        "Yo@HyperV_VM" = {
          user = yo;
          host = hyper-v_vm;
        };
        "Yo@LiCo" = {
          user = yo;
          host = lico;
        };
        "Yo@NeLiCo" = {
          user = yo;
          host = nelico;
        };
      });

    }
  );
}
