{ tools, config-domain, host, ... }: with tools; {
  config = {

    # Firewall
    networking.firewall.enable = true;
    networking.firewall.allowPing = true;

    # Immutable Users (Once created, never change)
    users.mutableUsers = false;

    # Agenix
    age = (
      let
        username = host.user.username;
      in {
        identityPaths = [ "/home/${username}/.ssh/id_ed25519_agenix" ];
        secrets = with config-domain.private; {
          "root-userPassword".file = "${secrets}/root_user_password.age";
          "${username}-userPassword".file = "${secrets}/${username}_user_password.age";
        };
      }
    );
    
  };
}
