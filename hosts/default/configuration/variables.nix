{ config, host, lib, ... }:
  let
    mkDefault = value: lib.mkDefault value;
  in {
    config = {

      # Default Text Editor
      environment.variables.EDITOR = "kwrite";

    };
  }
