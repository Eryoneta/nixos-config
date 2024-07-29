{ ... }: {
  config = {

    # OpenSSH: Server SSH para conexão remota
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

  };
}
