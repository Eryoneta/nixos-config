# Public/Private Domains
/*
  - Defines paths for directories
  - The configuration is defined by two "domains": Public and Private
    - That requires two directories at the "flake.nix" level: "./private-config" and "./public-config"
    - The content can be defined by the argument "directories". Each atribute gets turned into a path for a directory
      - Absolute paths can be read from the "outOfStore" set inside it
*/
flakePath: (
  let

    # Path Builder
    buildPath = basePath: parentDirectory: directories: (
      # Sets a complete path for each directory
      builtins.mapAttrs (filename: filepath: (
        basePath + parentDirectory + filepath
      )) directories
    );

  in {

    # Args Builder
    buildSpecialArgs = { configPath, directories }: {
      config-domain = {
        publicPath = (flakePath + "/public-config");
        privatePath = (flakePath + "/private-config");
        public = (buildPath flakePath "/public-config" directories);
        private = (buildPath flakePath "/private-config" directories);
        outOfStore = {
          publicPath = (configPath + "/public-config");
          privatePath = (configPath + "/private-config");
          public = (buildPath configPath "/public-config" directories);
          private = (buildPath configPath "/private-config" directories);
        };
      };
    };

  }
)