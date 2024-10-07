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
    config-utils = (import ./modules/flake-module-config-utils.nix flakePath);

  in (
    user: host: (
      let

        # Common Modifiers
        commonModifiers = [
          # Configuration-Utilities
          (config-utils.build {
            nixpkgs-lib = inputs.nixpkgs.lib;
            home-manager-pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
            home-manager-lib = inputs.home-manager.lib;
          })
          # User-Host-Scheme
          (flake-modules."user-host-scheme.nix".build {
            inherit user;
            inherit host;
          })
          # Pkgs-Bundle
          (flake-modules."package-bundle.nix".build {
            architecture = host.system.architecture;
            autoImportPackages = (with inputs; {
              stable = nixpkgs-stable;
              unstable = nixpkgs-unstable;
              unstable-fixed = nixpkgs-unstable-fixed;
            });
            packages = (with inputs; {
              firefox-addons = nurpkgs-firefox-addons.packages.${host.system.architecture};
              fx-autoconfig = fx-autoconfig;
            });
          })
          # Public-Private-Domains
          (flake-modules."public-private-domains.nix".build {
            # Allows development in 'develop' branch while "AutoUpgrade" updates 'main' branch
            # But dotfiles changes (caused by installed programs) should always happen in 'develop' (It's convenient!)
            # Important: Only absolute paths notices the dev folder
            configPath = if (user.username == "yo") then user.configDevFolder else user.configFolder;
            # configPath = user.configFolder;
            directories = {
              dotfiles = "/dotfiles";
              programs = "/programs";
              resources = "/resources";
              secrets = "/secrets";
            };
          })
          # Map-Modules-Dir
          (flake-modules."map-modules-directory.nix".build {
            directory = ./modules;
          })
          # Agenix
          (flake-modules."agenix.nix".build {
            architecture = host.system.architecture;
            package = inputs.agenix;
          })
          # Inputs-As-Args
          (flake-modules."inputs-as-args.nix".build {
            inputs = inputs;
          })
        ];

      in {

        # NixOS Configuration
        nixosSystemConfig = (
          # NixOS-System
          flake-modules."nixos-system.nix".build {
            architecture = host.system.architecture;
            package = inputs.nixpkgs;
            modifiers = commonModifiers ++ [
              # Home-Manager-Module
              (flake-modules."home-manager-module.nix".build {
                username = user.username;
                package = inputs.home-manager;
                modifiers = commonModifiers;
              })
              # Auto-Upgrade-List
              (flake-modules."auto-upgrade-list.nix".build {
                packages = (with inputs; {
                  inherit nixpkgs;
                  inherit home-manager;
                  inherit agenix;
                  inherit nixpkgs-stable;
                  inherit nixpkgs-unstable;
                  #inherit nixpkgs-unstable-fixed;
                  inherit nurpkgs-firefox-addons;
                  #inherit fx-autoconfig;
                });
              })
            ];
          }
        );

        # Home-Manager-Standalone Configuration
        homeManagerConfig = (
          # Home-Manager-Standalone
          flake-modules."home-manager-standalone.nix".build {
            package = inputs.home-manager;
            systemPackage = inputs.nixpkgs;
            username = user.username;
            modifiers = commonModifiers;
          }
        );

      }
    )
  )
)
