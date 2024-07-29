{ config, user, ... }: {
    
  imports = [
    ../default/home.nix # Default
    ./programs.nix # Programas
  ];

  # Yo
  config = {
    
    home = {

    };
    
  };

}
