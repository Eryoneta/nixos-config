{ config, lib, ... }: (
  let

    # Shortcuts
    cfg = config.file-manager;
    cfgLib = config.lib.file-manager;

    # 
    isDirectory = content: ((lib.isAttrs content) && !(isLink content));
    isLink = content: ((lib.isAttrs content) && (lib.hasAttr "_type" content) && (lib.hasAttr "_path" content));
    isSymlink = content: ((isLink content) && content._type == "symlink");
    isHardlink = content: ((isLink content) && content._type == "hardlink");
    isCopy = content: ((isLink content) && content._type == "copy");
    mkDirectoryScript = path: directoryConfig: ''
      # Create a directory. Do nothing if it already exists
      mkdir --parents "${path}";
      
      ${lib.pipe directoryConfig.content [

        # Gets the text of every child node
        (x: builtins.mapAttrs (nodeName: nodeConfig: (
          mkNodeScript "${path}/${nodeName}" nodeConfig
        )) x)

        # Transforms the set into a list of strings
        (x: builtins.attrValues x)

        # Merges all strings into a single one
        (x: builtins.concatStringsSep "\n" x)

      ]}
    '';
    mkFileScript = fullpath: fileConfig: (
      { # Switch case
        ${if (isSymlink fileConfig.content) then "true" else "non-symlink"} = ''
          # Create a symlink. Replace if it already exists
          ln --symbolic --force "${fileConfig.content._path}" "${fullpath}";
        '';
        ${if (isHardlink fileConfig.content) then "true" else "non-hardlink"} = ''
          # Create a hardlink. Replace if it already exists
          ln --force "${fileConfig.content._path}" "${fullpath}";
        '';
        ${if (isCopy fileConfig.content) then "true" else "non-copy"} = ''
          # Create a copy. Replace if it already exists
          cp "${fileConfig.content._path}" "${fullpath}";
        '';
      }.${"true"} or ''
        # Create a file
        echo "${fileConfig.content}" > "${fullpath}";
      ''
    );
    mkNodeScript = fullpath: nodeConfig: (
      if (isDirectory nodeConfig.content) then (
        (mkDirectoryScript fullpath nodeConfig)
      ) else (
        (mkFileScript fullpath nodeConfig)
      )
    );
    mkScript = (mkDirectoryScript cfg.baseDirectory cfg.fileSystem);

  in { # (NixOS/Home-Manager Module)
    config = {
      # Note: "config" cannot use "mkIf" as it sets "file-manager", which could set "enable" = Infinite recursion
      #   Each option here should use a individual "mkIf"

      assertions = (lib.mkIf (cfg.enable) [
        {
          assertion = !(cfg.baseDirectory == "");
          message = ''
            The option 'file-manager.baseDirectory' cannot be empty
          '';
        }
      ]);

      # Loads custom lib functions (See "./lib/default.nix")
      lib = (builtins.import ./lib lib);

      # Output
      # file-manager.output = mkScript;
      file-manager.output = (lib.mkIf (cfg.enable) mkScript);

      # Test
      file-manager = {
        enable = true;
        autoload = false;
        baseDirectory = "/home/yo/Downloads/Teste";
        fileSystem.content = {
          "Teste1".content = {
            "File1.txt".content = ''
              A1
              B1
              C1
            '';
            "File.symlink".content = (config.lib.file-manager.mkSymlink "/home/yo/Imagens");
            "File.hardlink".content = (config.lib.file-manager.mkHardlink "/home/yo/Imagens");
            "File.copy".content = (config.lib.file-manager.mkCopy "/home/yo/Imagens");
          };
          "Teste2".content = {
            "SubT1".content = {
              "File2.txt".content = ''
                A2
                B2
                C2
              '';
            };
          };
          "Teste2/SubT1/SubT2".content = {
            "File2.txt".content = ''
              A2
              B2
              C2
            '';
          };
          "Teste3/SubT/File3.txt".content = ''
            A3
            B3
            C3
          '';
        };
      };

    };
  }
)
