{ config, ... }@args: with args.config-utils; { # (Setup Module)

  # Security
  config.modules."security" = {
    tags = [ "default-setup" ];
    attr.isAgenixSecretsAllowed = config.modules."configuration".attr.isAgenixSecretsAllowed;
    attr.mkUserSecrets = users: (utils.pipe users [

      # Transforms the set into a list
      (x: builtins.attrValues x)

      # Add root user into the list
      (x: x ++ [
        { # Root user
          username = "root";
        }
      ])

      # Prepare each item to be transformed into a set
      (x: builtins.map (user: {
        name = "${user.username}-userPassword";
        value = {
          file = (config.modules."configuration".attr.mkFilePath {
            private-secret = "${user.username}_user_password.age";
          });
        };
      }) x)

      # Transforms the list into a set
      (x: builtins.listToAttrs x)

    ]);
    setup = { attr }: {
      nixos = { host, ... }: { # (NixOS Module)

        # Firewall
        config.networking.firewall.enable = true;
        config.networking.firewall.allowPing = true; # Responds to echo requests

        # Immutable users (Once created, never change)
        config.users.mutableUsers = false;

        # Real-time scheduling can be used by normal users
        # Required for sound
        config.security.rtkit.enable = true;

        # User passwords
        config.age = ( # (agenix option)
          utils.mkIf (attr.isAgenixSecretsAllowed "private") {
            identityPaths = [ "/home/${host.userDev.username}/.ssh/id_ed25519_agenix" ];
            secrets = (attr.mkUserSecrets host.users);
          }
        );

        # AppArmor
        # config.security.apparmor = {
        #   enable = true;
        #   policies = {
        #     # "firefox" = {
        #     #   enable = true;
        #     #   enforce = false;
        #     #   profile = ''
        #     #   '';
        #     # };
        #   };
        # };
        # environment.systemPackages = with pkgs-bundle.stable; [
        #   # apparmor-utils
        #   apparmor-profiles
        # ];
        # TODO: (Security) AppArmor

        # Firejail
        # config.programs.firejail = {
        #   enable = true;
        #   wrappedBinaries = {
        #     "firefox" = {
        #       executable = (
        #         let
        #           firefox-pkgs = with config.home-manager.users.${args.hostArgs.user.username}; (
        #             profile.programs.firefox.options.packageChannel
        #           ).firefox;
        #         in "${lib.getBin firefox-pkgs}/bin/firefox"
        #       );
        #       profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        #     };
        #   };
        # };
        # TODO: (Security) Firejail

      };
    };
  };

}
