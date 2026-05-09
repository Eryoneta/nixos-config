{ config, user, pkgs-bundle, ... }@args: with args.config-utils; { # (Setup-Manager Module)

  # RSnapshot: Backup manager
  config.modules."rsnapshot" = {
    tags = [ "personal-setup" ];
    attr.packageChannel = pkgs-bundle.stable;
    attr.mkRSnapshotConfig = (
      let
        pkgs = config.modules."rsnapshot".attr.packageChannel;
        mkRsnapshotConfigChunk = configChunk: (
          let

            # Command = Argument;
            # turns into
            # Command[TAB](Argument as string)
            mkSingleArg = command: argument: (utils.pipe argument [

              # Stringfy argument
              (x: builtins.toString x)

              # Join command and argument
              (x: "${command}\t${x}")

            ]);

            # Command = [ Argument1 Argument2 ];
            # turns into
            # Command[TAB](Argument1 as string)[TAB](Argument2 as string)...
            mkMultipleArgs = command: arguments: (utils.pipe arguments [

              # Stringfy all arguments
              (x: builtins.map (argument: (
                if (builtins.isList argument) then (
                  builtins.concatStringsSep "\t" argument
                ) else (
                  builtins.toString argument
                )
              )) x)

              # Merge all arguments separated by TAB
              (x: builtins.concatStringsSep "\t" x)

              # Join command and arguments
              (x: "${command}\t${x}")

            ]);

            # Command = [ [ Argument1 ] [ Argument2 ] ];
            # turns into
            # Command[TAB](Argument1 as string)[NEWLINE]Command[TAB](Argument2 as string)
            mkMultipleLinesArgs = command: arguments: (utils.pipe arguments [

              # Build all arguments
              (x: builtins.map (subArguments: (
                mkMultipleArgs command subArguments
              )) x)

              # Merge all arguments separated by NEWLINE
              (x: builtins.concatStringsSep "\n" x)

            ]);

          in (utils.pipe configChunk [

          # Transforms each value into a final, valid line
          (x: builtins.mapAttrs (command: argument: (
            if (builtins.isString argument) then (
              # Is a string = Command[TAB](Argument as string)
              mkSingleArg command argument
            ) else if (builtins.isList argument) then (
              if (builtins.all (subArg: builtins.isList subArg) argument) then (
                # Is a list of lists = Command[TAB](Argument1 as string)[NEWLINE]Command[TAB](Argument2 as string)
                mkMultipleLinesArgs command argument
              ) else (
                # Is a list of stuff = Command[TAB](Argument1 as string)[TAB](Argument2 as string)
                mkMultipleArgs command argument
              )
            ) else (
              # Is something else = Command[TAB](Argument as string)
              mkSingleArg command argument
            )
          )) x)

          # Transforms a set into a list
          (x: builtins.attrValues x)

          # Merges all items into a multiline text
          (x: builtins.concatStringsSep "\n" x)

          # Extra linebreak at the end so all chunks can be put together into a single text
          (x: x + "\n")

        ]));
        rsnapshotConfig = configName: {
          "config_version" = "1.2";
          "cmd_cp" = "${pkgs.coreutils}/bin/cp";
          "cmd_rm" = "${pkgs.coreutils}/bin/rm";
          "cmd_rsync" = "${pkgs.rsync}/bin/rsync";
          "cmd_ssh" = "${pkgs.openssh}/bin/ssh";
          "cmd_logger" = "${pkgs.inetutils}/bin/logger";
          "cmd_du" = "${pkgs.coreutils}/bin/du";
          "cmd_rsnapshot_diff" = "${pkgs.rsnapshot}/bin/rsnapshot-diff";
          "lockfile" = "/home/${user.username}/rsnapshot_${configName}.pid";
          "link_dest" = 1;
        };
        basicConfig = {
          "rsync_long_args" = (builtins.toString [
            "--delete" # Delete extra files
            "--numeric-ids" # Use ids rather than usernames to own files
            "--delete-excluded" # Be sure to delete files that are excluded
            "--no-relative" # Do not recreate absolute file paths
            "--verbose" # Show messages
          ]);
          "verbose" = 4; # Show all action messages
        };
      in ({ name, startBlock ? {}, middleBlock ? {}, endBlock ? {} }: (
        "# Auto-generated configuration file. Do not edit\n\n"
        + (mkRsnapshotConfigChunk ((rsnapshotConfig name) // basicConfig))
        + (mkRsnapshotConfigChunk startBlock)
        + (mkRsnapshotConfigChunk middleBlock)
        + (mkRsnapshotConfigChunk endBlock)
        # Note: Some options needs to be before others. These three chunks allow that
      ))
    );
    setup = { attr }: {
      home = { # (Home-Manager Module)

        # Install
        config.home.packages = with attr.packageChannel; [ rsnapshot ];

        # Example
        /*
          config.xdg.configFile."rsnapshot/my_backup.conf" = {
            text = (attr.mkRsnapshotConfig {
              name = "my_backup";
              startBlock = {
                "snapshot_root" = "/run/media/USERNAME/REMOVABLE_DEVICE_NAME/";
              };
              middleBlock = {
                "retain" = [
                  [ "snapshot" 20 ]
                ];
              };
              endBlock = {
                "backup" = [
                  [ "/home/USERNAME/DIR_TO_BACKUP1/" "DIR_TO_BACKUP1/" ]
                  [ "/home/USERNAME/DIR_TO_BACKUP2/" "DIR_TO_BACKUP2/" "+rsync_long_args=--max-size=400MiB" ]
                ];
              };
            });
          };
        */

      };
    };
  };

}
