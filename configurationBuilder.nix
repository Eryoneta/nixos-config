inputs: flakePath: (
  let

    # Imports
    mapDir = (import ./modules/nix-modules/mapDir.nix).mapDir;
    flake-modules = (
      # MapAttrs: { "feat.nix" = ./.../feat.nix; } -> { "feat.nix" = (import ./.../feat.nix flakePath); }
      builtins.mapAttrs (
        name: value: (import value flakePath)
      ) (mapDir ./modules/flake-modules)
    );
    config-utils-lib = (import ./modules/flake-module-config-utils.nix flakePath);

  in (
    usersOrUser: host: (
      let

        users = if(builtins.isList usersOrUser) then usersOrUser else [ usersOrUser ]; # Makes sure it's a list
        userDev = (builtins.head users);

        # Modifiers
        modifiers = {

          # Configuration-Utilities
          config-utils = (config-utils-lib.build {
            nixpkgs-lib = inputs.nixpkgs.lib;
            home-manager-pkgs = inputs.nixpkgs.legacyPackages."${host.system.architecture}";
            home-manager-lib = inputs.home-manager.lib;
          });

          # Inputs-as-Arguments
          inputs-as-args = (flake-modules."inputs-as-args.nix".build {
            inherit inputs;
          });

          # Pkgs-Bundle
          package-bundle = (flake-modules."package-bundle.nix".build (
            let
              architecture = host.system.architecture;
            in {
              inherit architecture;
              autoImportPackages = (with inputs; {
                stable = nixpkgs-stable;
                unstable = nixpkgs-unstable;
              });
              packages = (with inputs; {
                firefox-addons = {
                  pkgs = nurpkgs-firefox-addons.packages.${architecture};
                  buildFirefoxXpiAddon = nurpkgs-firefox-addons.lib.${architecture}.buildFirefoxXpiAddon;
                };
                fx-autoconfig = fx-autoconfig;
                nixos-artwork = {
                  "wallpaper/nix-wallpaper-simple-blue.png" = nixos-artwork;
                };
                tiledmenu = tiledmenu;
                papirus-colors-icons = {
                  "Papirus-Colors-Dark" = "${papirus-colors-icons}/Papirus-Colors-Dark";
                };
                mpv-input-event = mpv-input-event;
                primslauncherCRK = primslauncherCRK;
                powershell-prompt = powershell-prompt;
                git-tools = git-tools;
                firefox-scripts = firefox-scripts;
              });
            }
          ));

          # Auto-Upgrade-List
          auto-upgrade-list = (flake-modules."auto-upgrade-list.nix".build {
            packages = (with inputs; {
              inherit nixpkgs;
              inherit home-manager;
              inherit plasma-manager;
              inherit agenix;
              inherit stylix;
              inherit nixpkgs-stable;
              inherit nixpkgs-unstable;
              inherit nixpkgs-unfree-unstable;
              inherit nurpkgs-firefox-addons;
            });
          });

          # Public-Private-Domains
          public-private-domains = (flake-modules."public-private-domains.nix".build {
            configPath = if (userDev.configDevFolder != "") then userDev.configDevFolder else userDev.configFolder;
            # Note: Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
            #   But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
            #   Important: Only absolute paths notices the dev folder
            directories = {
              dotfiles = "/dotfiles";
              programs = "/programs";
              resources = "/resources";
              secrets = "/secrets";
            };
          });

          # User-Host-Scheme
          user-host-scheme = (flake-modules."user-host-scheme.nix".build {
            inherit users;
            inherit host;
          });

          # Map-Modules-Dir
          map-modules-directory = (flake-modules."map-modules-directory.nix".build {
            directory = ./modules;
          });

          # Modular Configuration
          modular-config = (flake-modules."modular-config.nix".build {
            nixpkgs-lib = inputs.nixpkgs.lib;
            packages = inputs.nixpkgs.legacyPackages."${host.system.architecture}";
          });

          # Agenix
          agenix = (flake-modules."agenix.nix".build {
            architecture = host.system.architecture;
            package = inputs.agenix;
          });

          # Plasma-Manager
          plasma-manager = (flake-modules."plasma-manager.nix".build {
            package = inputs.plasma-manager;
          });

          # Stylix
          stylix = (flake-modules."stylix.nix".build {
            package = inputs.stylix;
          });

          # Home-Manager-Module
          home-manager-module = (flake-modules."home-manager-module.nix".build {
            usernames = (builtins.map (user: user.username) users);
            package = inputs.home-manager;
            modifiers = commonModifiers ++ (with modifiers; [
              plasma-manager
              stylix
            ]);
            architecture = host.system.architecture;
            systemPackage = inputs.nixpkgs-stable;
          });

        };

        # Common Modifiers
        commonModifiers = with modifiers; [
          config-utils
          inputs-as-args
          auto-upgrade-list
          package-bundle
          user-host-scheme
          public-private-domains
          map-modules-directory
          modular-config
          agenix
        ];

      in {

        # NixOS Configuration
        nixosSystemConfig = (
          # NixOS-System
          flake-modules."nixos-system.nix".build {
            architecture = host.system.architecture;
            package = inputs.nixpkgs;
            modifiers = commonModifiers ++ (with modifiers; [
              home-manager-module
            ]);
          }
        );

        # Home-Manager-Standalone Configuration
        homeManagerConfig = (
          builtins.listToAttrs (builtins.map (
            user: {
              name = "${user.name}";
              value = (
                # Home-Manager-Standalone
                flake-modules."home-manager-standalone.nix".build {
                  username = user.username;
                  package = inputs.home-manager;
                  #systemPackage = inputs.nixpkgs;

                  systemPackage = inputs.nixpkgs-stable;
                  # TODO: (Flake) Kernel 6.6.89 and later are weirdly slow. Change when a good one appears

                  modifiers = commonModifiers ++ (with modifiers; [
                    plasma-manager
                    stylix
                  ]);
                }
              );
            }
          ) users)
        );

      }
    )
  )
)
