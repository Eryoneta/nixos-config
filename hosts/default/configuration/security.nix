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
    age = with config-domain; (
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
    
  };
}
