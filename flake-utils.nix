flakePath: (
  let

    # Imports
    user-host-scheme = ((builtins.import ./config-utils/user-host-scheme.nix) flakePath);
    config-domain = ((builtins.import ./config-utils/public-private-domains.nix) flakePath);
    config-utils = (builtins.import ./config-utils/config-utils.nix);
    mapDir = (builtins.import ./config-utils/nix-utils/mapDir.nix).mapDir;

  in {
    buildHost = user-host-scheme.buildHost;
    buildUser = user-host-scheme.buildUser;
    buildConfiguration = { inputs, user, users ? null, host, auto-upgrade-pkgs, packages }: (
      let
        allUsers = (if (users == null) then [ user ] else users);
        userDev = (builtins.head allUsers);
        userHostArgs = (user-host-scheme.buildSpecialArgs {
          inherit allUsers host;
        });
        configDomainArgs = (config-domain.buildSpecialArgs { # Config Domain
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
        pkgs-bundle = (packages host.system.architecture); # Packages (Requires architecture)
        modules = (mapDir ./modules); # Modules Directory
        configUtilsArgs = (config-utils.build {
          nixpkgs-lib = inputs.nixpkgs.lib;
          home-manager-pkgs = inputs.nixpkgs.legacyPackages."${host.system.architecture}";
          home-manager-lib = inputs.home-manager.lib;
        });
      in {

        # NixOS Configuration
        nixosSystemConfig = (inputs.nixpkgs.lib.nixosSystem {
          system = host.system.architecture;
          modules = [

            { # (NixOS-Module)
              config = {
                nixpkgs.config.allowUnfree = true; # Allows unfree packages
              };
            }

            "./hosts/${host.hostname}/configuration.nix"  # Loads host configuration

            # Home-Manager-Module Configuration
            inputs.home-manager.nixosModules.home-manager # Loads Home-Manager options
            { # (NixOS-Module)
              config = {
                home-manager = {
                  useGlobalPkgs = false; # Ignore system nixpkgs configuration. Every one is configured separately
                  useUserPackages = true; # Save user packages in "/etc/profiles/per-user/$USERNAME" if it's already present in the system ("/etc/profiles/")
                  users = (inputs.nixpkgs.lib.pipe allUsers [ # Loads all users configurations

                    # Prepare list to be converted to set
                    (x: builtins.map (user: {
                      name = user.username;
                      value = (builtins.import "./users/${user.username}/home.nix");
                    }) x)

                    # Convert list of users to attrs of users
                    (x: builtins.listToAttrs x)

                  ]);
                  sharedModules = [
                    inputs.plasma-manager.homeManagerModules.plasma-manager # Loads Plasma-Manager options
                    inputs.stylix.homeManagerModules.stylix # Loads Stylix options
                    inputs.agenix.homeManagerModules.default # Loads Agenix options
                  ];
                  extraSpecialArgs = {
                    inherit pkgs-bundle; # Packages
                    inherit (userHostArgs) userDevArgs; # User-Host-Scheme
                    inherit (configDomainArgs) config-domain; # Config-Domain
                    inherit modules; # Modules Directory
                    inherit (configUtilsArgs) config-utils; # Config-Utils
                  };
                };
              };
            }
            { # (NixOS-Module)
              config = {
                home-manager.extraSpecialArgs = {
                  pkgs = pkgs-bundle.stable; # Replace "pkgs" with a custom one
                  # Note: This allows all home-manager modules to use a different package from the system
                  #   Kernel and KDE Plasma are defined by NixOS. Nearly all apps are defined by Home-Manager
                };
              };
            }
            { # (NixOS-Module)
              config = {
                environment.systemPackages = [
                  pkgs-bundle.stable.home-manager # Home-Manager: Manages standalone home configurations
                ];
              };
            }

            inputs.stylix.nixosModules.stylix # Loads Stylix options

            # Agenix Configuration
            inputs.agenix.nixosModules.default # Loads Agenix options
            { # (NixOS-Module)
              config = {
                environment.systemPackages = [
                  inputs.agenix.packages.${host.system.architecture}.default # Agenix CLI
                ];
              };
            }

          ];
          specialArgs = {
            inherit auto-upgrade-pkgs; # Auto-Upgrade
            inherit pkgs-bundle; # Packages
            inherit (userHostArgs) userDevArgs hostArgs; # User-Host-Scheme
            inherit (configDomainArgs) config-domain; # Config-Domain
            inherit modules; # Modules Directory
            inherit (configUtilsArgs) config-utils; # Config-Utils
          };
        });

        # Home-Manager-Standalone Configuration
        homeManagerConfig = (inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs-stable.legacyPackages.${host.system.architecture};
          modules = [

            "./users/${userDev.username}/home.nix" # Loads user configuration

            inputs.plasma-manager.homeManagerModules.plasma-manager # Loads Plasma-Manager options
            inputs.stylix.homeManagerModules.stylix # Loads Stylix options
            inputs.agenix.homeManagerModules.default # Loads Agenix options

          ];
          extraSpecialArgs = {
            inherit pkgs-bundle; # Packages
            inherit (userHostArgs) userDevArgs; # User-Host-Scheme
            inherit (configDomainArgs) config-domain; # Config-DomainS
            inherit modules; # Modules Directory
            inherit (configUtilsArgs) config-utils; # Config-Utils
          };
        });

      }
    );
  }
)