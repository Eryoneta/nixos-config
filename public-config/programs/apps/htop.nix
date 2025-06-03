{ pkgs-bundle, ... }@args: with args.config-utils; { # (Setup Module)

  # HTop: Terminal based process viewer
  config.modules."htop" = {
    attr.packageChannel = pkgs-bundle.stable;
    tags = [ "default-setup" ];
    setup = { attr }: {
      home = { config, ... }: { # (Home-Manager Module)

        # Configuration
        config.programs.htop = {
          enable = true;
          package = (utils.mkDefault) (attr.packageChannel).htop;

          # Settings
          settings = {
            # Good reference: https://peteris.rocks/blog/htop/
            fields = with config.lib.htop.fields; [ # Main tab fields
              PID # PID: Process ID
              USER # USER: Process owner
              STATE # S: Process current state
              #   Note:
              #     R = Running
              #     S = Sleeping
              #     D = Sleeping, but ignores interruptions
              #     Z = Terminated, but not cleaned (Indicates a bug)
              #     T = Paused (Ctrl+Z)
              NICE # NI: Process priority (How "nice" it is to other processes)
              #   Note: Ranges from -20(Higher) to 20(Lower). The smaller, the more important it is
              PRIORITY # PRI: Process priority as defined by the Kernel
              #   Note: Ranges from 0 to 99("RealTime") and from 100 to 139(For users)
              PERCENT_CPU # CPU%: The % of CPU usage
              PERCENT_MEM # MEM%: The % of used memory. Basically RES/RAM
              M_SIZE # VIRT: Total memory usage as described by the process
              M_RESIDENT # RES: The actual memory used by the process
              M_SHARE # SHR: The memory space could be shared between processes
              TIME # TIME+: Process total running time
              COMM # Command: The command that spawned the process
            ];
            color_scheme = 0; # Default colors (Defined by the terminal)
            cpu_count_from_one = 1; # Start CPU index from 1
            delay = 15; # 1.5s between each updates
            highlight_base_name = 1; # Highlight process name (In Commmand)
            highlight_megabytes = 1; # Highlight high memory usage (In VIRT, RES, and SHR)
            highlight_threads = 1; # Display threads in a different color
            show_cpu_temperature = 1; # Show temperatures alongside each CPU meter
            enable_mouse = 1; # Allow for mouse click and scroll
          } // (with config.lib.htop; (
            (leftMeters [
              (bar "LeftCPUs2")
              (text "Tasks")
              (bar "Memory")
              (bar "Zram")
              (bar "Swap")
            ])
            //
            (rightMeters [
              (bar "RightCPUs2")
              (text "LoadAverage")
              (text "Uptime")
              (text "Systemd")
              (text "SystemdUser")
            ])
          ));

        };

      };
    };
  };

}
