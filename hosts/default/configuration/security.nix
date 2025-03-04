{ config-domain, host, ... }@args: with args.config-utils; {
  config = {

    # Firewall
    networking.firewall.enable = true;
    networking.firewall.allowPing = true; # Responds to echo requests

    # Immutable users (Once created, never change)
    users.mutableUsers = false;

    # Real-time scheduling can be used by normal users
    # Required for sound
    security.rtkit.enable = true;

    # Agenix
    age = with config-domain; ( # (Agenix option)
      # Check for "./private-config/secrets"
      utils.mkIf (utils.pathExists private.secrets) (
        let
          username = host.user.username;
        in {
          identityPaths = [ "/home/${host.userDev.username}/.ssh/id_ed25519_agenix" ];
          secrets = (utils.pipe (utils.attrsToList host.users) [
            # Removes users with files that don't exists
            (x: builtins.filter (user: (
              builtins.pathExists "${private.secrets}/${user.username}_user_password.age"
            )) x)

            # Set the value of each user to be a valid configuration
            (x: builtins.map (user: {
              name = "${user.username}-userPassword";
              value = {
                file = "${private.secrets}/${user.username}_user_password.age";
              };
            }) x)

            # Merge all items into a single set
            (x: builtins.listToAttrs x)

            # Add root user configuration
            (x: x // {
              "root-userPassword" = {
                file = "${private.secrets}/root_user_password.age";
              };
            })
          ]);
        }
      )
    );

    # AppArmor
    # security.apparmor = {
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
    # programs.firejail = {
    #   enable = true;
    #   wrappedBinaries = {
    #     "firefox" = {
    #       executable = (
    #         let
    #           firefox-pkgs = with config.home-manager.users.${host.user.username}; (
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
}
