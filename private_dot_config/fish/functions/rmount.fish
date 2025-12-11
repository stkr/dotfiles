function rmount -d "SSH mount remote file system"
    # We tell argparse about -h/--help and others -these are short and long
    # forms of the same option. The "--" here is mandatory, it tells it from
    # where to read the arguments.
    argparse h/help -- $argv; or return

    # If -h or --help is given, we print a little help text and return
    if set -ql _flag_help || test (count $argv) -lt 1
        echo "Usage:"
        echo "    rmount mount_name"
        echo ""
        echo "For the given \$mount_name, the function looks for a file"
        echo "'~/remote/\$mount_name.ssh'. This file must contain the parameters"
        echo "which are forwarded to sshfs on the first line. This normally"
        echo "contains hostname and the remote directory to mount (see man for"
        echo "sshfs)."
        echo ""
        echo "A folder '~/remote/\$mount_name' will be created and the remote"
        echo "directory will be mounted to that folder."
        return 0
    end

    # The idea is to replicate what vifm does in order to reuse the same configuration files.
    # From vifm documentation:
    #
    # " :filetype extensions FUSE_MOUNT2|some_mount_command using %PARAM and %DESTINATION_DIR
    # variables
    # " %PARAM and %DESTINATION_DIR are filled in by vifm at runtime.
    # " A sample line might look like this:
    # " :filetype *.ssh FUSE_MOUNT2|sshfs %PARAM %DESTINATION_DIR
    # " %PARAM value is filled from the first line of file (whole line).
    # " Example first line for SshMount filetype: root@127.0.0.1:/
    #
    # As far as %DESTINATION_DIR% is concerned, for vifm this is a temporary directory, this needs
    # to be replaced by a static path. We chose the config filename without the .ssh extension in
    # the directory of the configuration.

    set rmount_base_path "$HOME/remote"
    if ! test -d "$rmount_base_path"
        echo "Base path [$rmount_base_path] is missing."
        return 1
    end

    set rmount_config_file_path "$rmount_base_path/$argv[1].ssh"
    if ! test -f "$rmount_config_file_path"
        echo "Config file [$rmount_config_file_path] is missing."
        return 1
    end

    set rmount_destination_path "$rmount_base_path/$argv[1]"
    if ! test -d "$rmount_destination_path"
        mkdir -p "$rmount_destination_path"
        if ! test -d "$rmount_destination_path"
            echo "Destination path [$rmount_destination_path] could not be created."
            return 1
        end
    end

    while read -la line
        sshfs $line "$rmount_destination_path"
        break
    end < "$rmount_config_file_path"

end

complete -c rmount -f -a "(ls -1 ~/remote/*.ssh 2>/dev/null | string replace -r '.*/' '' | string replace -r '.ssh\$' '')"
