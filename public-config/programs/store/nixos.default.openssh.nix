{ lib, ... }: 
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # OpenSSH: Remote connection
      services.openssh = {
        enable = mkDefault false; # Disabled by default!
        ports = [ 22 ];
        openFirewall = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

    };
  }
