{ ... }@args: with args.config-utils; { # (Setup Module)

  # Security
  config.modules."security" = {
    tags = [ "default-setup" ];
    setup = {
      nixos = { host, config-domain, ... }: { # (NixOS Module)

        # Firewall
        config.networking.firewall.enable = true;
        config.networking.firewall.allowPing = true; # Responds to echo requests

        # Immutable users (Once created, never change)
        config.users.mutableUsers = false;

        # Real-time scheduling can be used by normal users
        # Required for sound
        config.security.rtkit.enable = true;

        # User passwords
        config.age = with config-domain; ( # (agenix option)
          # Check for "./private-config/secrets"
          utils.mkIf ((utils.pathExists private.secrets) && !host.system.virtualDrive) {
            identityPaths = [ "/home/${host.userDev.username}/.ssh/id_ed25519_agenix" ];
            secrets = (utils.pipe host.users [

              # Transforms the set into a list
              (x: builtins.attrValues x)

              # Removes users with files that don't exists
              (x: builtins.filter (user: (
                builtins.pathExists "${private.secrets}/${user.username}_user_password.age"
              )) x)

              # Prepare each item to be transformed into a set
              (x: builtins.map (user: {
                name = "${user.username}-userPassword";
                value = {
                  file = "${private.secrets}/${user.username}_user_password.age";
                };
              }) x)

              # Transforms the list into a set
              (x: builtins.listToAttrs x)

              # Add root user configuration
              (x: x // {
                "root-userPassword" = {
                  file = "${private.secrets}/root_user_password.age";
                };
              })

            ]);
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
