{ config, lib, ... }: (
  let

    # Shortcuts
    cfg = config.file-manager;
    cfgLib = config.lib.file-manager;

    # 
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
      # Is a set is and a link = Link
      # Othewise = File
      if ((lib.isAttrs fileConfig.content) && (lib.hasAttr "_type" fileConfig.content)) then (
        if (fileConfig.content._type == "symlink") then ''
          # Create a symlink. Replace if it already exists
          ln --symbolic --force "${fileConfig.content._path}" "${fullpath}";
        '' else (
          if (fileConfig.content._type == "hardlink") then ''
          # Create a hardlink. Replace if it already exists
            ln --force "${fileConfig.content._path}" "${fullpath}";
          '' else ""
        )
      ) else ''
          # Create a file
          echo "${fileConfig.content}" > "${fullpath}";
      ''
    );
    mkNodeScript = fullpath: nodeConfig: (
      # Is a set and not a link = Directory
      # Othewise = File or link
      if ((lib.isAttrs nodeConfig.content) && !(lib.hasAttr "_type" nodeConfig.content)) then (
        (mkDirectoryScript fullpath nodeConfig)
      ) else (mkFileScript fullpath nodeConfig)
    );
    mkScript = (mkDirectoryScript cfg.baseDirectory cfg.fileSystem);

  in { # (NixOS/Home-Manager Module)

    config = {

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
      file-manager.output = lib.mkIf (cfg.enable) mkScript;

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
