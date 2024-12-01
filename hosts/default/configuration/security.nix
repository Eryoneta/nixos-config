{ config, config-domain, host, pkgs-bundle, lib, pkgs, ... }@args: with args.config-utils; {
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
          identityPaths = [ "/home/${username}/.ssh/id_ed25519_agenix" ];
          secrets = {
            "root-userPassword".file = "${private.secrets}/root_user_password.age";
            "${username}-userPassword".file = "${private.secrets}/${username}_user_password.age";
          };
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
