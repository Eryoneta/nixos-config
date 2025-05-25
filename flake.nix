{
  # Description
  description = "Yo Flake";

  # Inputs
  inputs = {

    # System Inputs
    # NixOS (AutoUpgrade)
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    nixpkgs.url = "github:NixOS/nixpkgs/3e362ce63e16b9572d8c2297c04f7c19ab6725a5";
    # TODO: (Flake) Kernel 6.6.89 and later are weirdly slow. Change when a good one appears

    # Home-Manager (AutoUpgrade)
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    # TODO: (Flake) Kernel 6.6.89 and later are slow. Undo when a good one appears

    # Plasma-Manager (AutoUpgrade)
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    # Agenix (AutoUpgrade)
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";
    # Stylix (AutoUpgrade)
    stylix.url = "github:danth/stylix/release-24.11";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.home-manager.follows = "home-manager";

    # Package Inputs
    # Stable Packages (AutoUpgrade)
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    # Unstable Packages (AutoUpgrade)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Extra Inputs
    # Unstable Unfree Packages (AutoUpgrade)
    nixpkgs-unfree-unstable.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    nixpkgs-unfree-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Firefox Addons (AutoUpgrade)
    nurpkgs-firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    nurpkgs-firefox-addons.inputs.nixpkgs.follows = "nixpkgs-unfree-unstable"; # Some extensions are unfree
    # Firefox: FX-AutoConfig (Manual Fetch)
    fx-autoconfig.url = "github:MrOtherGuy/fx-autoconfig/fe783f2c72388f64fd7ea0ee67617c6fd32f2261";
    fx-autoconfig.flake = false;
    # NixOS Artwork (Manual Fetch)
    nixos-artwork.url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-simple-blue.png";
    nixos-artwork.flake = false;
    # Plasma/Plasmoid: TiledMenu (Manual Fetch)
    tiledmenu.url = "github:Zren/plasma-applet-tiledmenu/73e03bd9ff523b01abb31a7c72901ba25918f9d8";
    tiledmenu.flake = false;
    # Plasma/Icons: Papirus Colors (Manual Fetch)
    papirus-colors-icons.url = "github:varlesh/papirus-colors/ae694e120110ab30ead27c66abc68e74dfd4e4f5";
    papirus-colors-icons.flake = false;
    # MPV Scripts: InputEvent (Manual Fetch)
    mpv-input-event.url = "github:natural-harmonia-gropius/input-event/refs/tags/v1.3";
    mpv-input-event.flake = false;
    # Prism Launcher (Cracked) (Manual Fetch)
    primslauncherCRK.url = "github:Diegiwg/PrismLauncher-Cracked/062a55639b4b18e8123a1306e658834ba0ffc137"; # TODO: (Flake) Remove once I afford the original
    primslauncherCRK.inputs.nixpkgs.follows = "nixpkgs";

    # My Utilities
    # PowerShell Prompt (Manual Fetch)
    powershell-prompt.url = "github:Eryoneta/powershell-prompt";
    powershell-prompt.flake = false;
    # Git Tools (Manual Fetch)
    git-tools.url = "github:Eryoneta/git-tools";
    git-tools.flake = false;
    # Firefox Scripts (Manual Fetch)
    firefox-scripts.url = "github:Eryoneta/Firefox-Scripts";
    firefox-scripts.flake = false;

  };

  # Outputs
  outputs = { self, ... }@extraArgs: (
    let

      # Imports
      user-host-scheme = (import ./modules/flake-modules/user-host-scheme.nix self.outPath);
      buildConfiguration = (import ./configurationBuilder.nix extraArgs self.outPath);

      # System_Label ([a-zA-Z0-9:_.-]*)
      # I change it at every rebuild. Very convenient for naming generations!
      systemLabel = (builtins.readFile ./NIXOS_LABEL.txt);

      # Hosts
      LiCo = user-host-scheme.buildHost {
        hostname = "lico";
        name = "LiCo";
        system.label = systemLabel; 
      };
      NeLiCo = user-host-scheme.buildHost {
        hostname = "nelico";
        name = "NeLiCo";
        system.label = systemLabel;
      };
      HyperV_VM = user-host-scheme.buildHost {
        hostname = "hyper-v_vm";
        name = "HyperV_VM";
        system.label = systemLabel;
      };

      # Users
      Yo = user-host-scheme.buildUser {
        username = "yo";
        name = "Yo";
        configFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config";
        configDevFolder = "/home/yo/Personal/System_Utilities/system-configuration/nixos-config-dev"; # Dev folder
      };
      Eryoneta = user-host-scheme.buildUser {
        username = "eryoneta";
        name = "Eryoneta";
      };
      
    in {

      # NixOS + Home-Manager(+ Plasma-Manager + Agenix) + Agenix
      nixosConfigurations = {
        "Yo@HyperV_VM" = (buildConfiguration [ Yo ] HyperV_VM).nixosSystemConfig;
        "Yo@LiCo" = (buildConfiguration [ Yo ] LiCo).nixosSystemConfig;
        "Yo@NeLiCo" = (buildConfiguration [ Yo Eryoneta ] NeLiCo).nixosSystemConfig;
      };
      
      # Home-Manager + Plasma-Manager + Agenix
      homeConfigurations = {
        "Yo@HyperV_VM" = (buildConfiguration Yo HyperV_VM).homeManagerConfig.Yo;
        "Yo@LiCo" = (buildConfiguration Yo LiCo).homeManagerConfig.Yo;
        "Yo@NeLiCo" = (buildConfiguration Yo NeLiCo).homeManagerConfig.Yo;
      };

    }
  );
}
