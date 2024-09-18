{ config-domain, host, ... }@args: with args.config-utils; {
  config = {

    # Firewall
    networking.firewall.enable = true;
    networking.firewall.allowPing = true;

    # Immutable Users (Once created, never change)
    users.mutableUsers = false;

    # Agenix
    age = with config-domain; (
      mkIf (mkFunc.pathExists private.secrets) (
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
