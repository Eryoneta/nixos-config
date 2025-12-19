# Source: https://github.com/NixOS/nixpkgs/blob/bef98989a27429e1cb9e3d9c25701ba2da742af2/pkgs/os-specific/linux/nixos-rebuild/nixos-rebuild.sh#L659C1-L738C3
# Note: For some reason, "nixos-rebuild list-generations" with "--profile-name" does not work. It returns "[]"

    generation_from_dir() {
        generation_dir="$1"
        generation_base="$(basename "$generation_dir")" # Has the format "system-123-link" for generation 123
        no_link_gen="${generation_base%-link}"  # remove the "-link"
        echo "${no_link_gen##*-}" # remove everything before the last dash
    }
    describe_generation(){
        generation_dir="$1"
        generation_number="$(generation_from_dir "$generation_dir")"
        nixos_version="$(cat "$generation_dir/nixos-version" 2> /dev/null || echo "Unknown")"

        #kernel_dir="$(dirname "$(realpath "$generation_dir/kernel")")"
        # Note: kernel/ points to the nix/store/, where it not always contains lib/
        kernel_dir="$generation_dir/kernel-modules"
        kernel_version="$(ls "$kernel_dir/lib/modules" 2>/dev/null || echo "Unknown")"

        configurationRevision="$("$generation_dir/sw/bin/nixos-version" --configuration-revision 2> /dev/null || true)"

        # Old nixos-version output ignored unknown flags and just printed the version
        # therefore the following workaround is done not to show the default output
        nixos_version_default="$("$generation_dir/sw/bin/nixos-version")"
        if [ "$configurationRevision" == "$nixos_version_default" ]; then
             configurationRevision=""
        fi

        # jq automatically quotes the output => don't try to quote it in output!
        build_date="$(stat "$generation_dir" --format=%W | jq 'todate')"

        pushd "$generation_dir/specialisation/" > /dev/null || :
        specialisation_list=(*)
        popd > /dev/null || :

        specialisations="$(jq --compact-output --null-input '$ARGS.positional' --args -- "${specialisation_list[@]}")"

        if [ "$(basename "$generation_dir")" = "$(readlink "$profile")" ]; then
            current_generation_tag="true"
        else
            current_generation_tag="false"
        fi

        # Escape userdefined strings
        nixos_version="$(jq -aR <<< "$nixos_version")"
        kernel_version="$(jq -aR <<< "$kernel_version")"
        configurationRevision="$(jq -aR <<< "$configurationRevision")"
        cat << EOF
{
  "generation": $generation_number,
  "date": $build_date,
  "nixosVersion": $nixos_version,
  "kernelVersion": $kernel_version,
  "configurationRevision": $configurationRevision,
  "specialisations": $specialisations,
  "current": $current_generation_tag
}
EOF
    }

    find "$(dirname "$profile")" -regex "$profile-[0-9]+-link" |
        sort -Vr |
        while read -r generation_dir; do
            describe_generation "$generation_dir"
        done |
        if [ -z "$json" ]; then
            jq --slurp -r '.[] | [
                    ([.generation, (if .current == true then "current" else "" end)] | join(" ")),
                    (.date | fromdate | strflocaltime("%Y-%m-%d %H:%M:%S")),
                    .nixosVersion, .kernelVersion, .configurationRevision,
                    (.specialisations | join(" "))
                ] | @tsv' |
                column --separator $'\t' --table --table-columns "Generation,Build-date,NixOS version,Kernel,Configuration Revision,Specialisation"
        else
            jq --slurp .
        fi
    exit 0
