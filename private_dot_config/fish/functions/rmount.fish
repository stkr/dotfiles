set -g rmount_unit_prefix "rmount-"
set -g rmount_base_path "$HOME/remote"

function __rmount_units
    systemctl --user list-unit-files --no-legend "$rmount_unit_prefix*.service" 2>/dev/null \
        | awk '{print $1}' \
        | string replace -r "^$rmount_unit_prefix" "" \
        | string replace -r "\.service\$" ""
end

function rmount -d "Mount/unmount a remote file system via a systemd user service"
    argparse h/help u/unmount s/status -- $argv; or return

    if set -ql _flag_help || test (count $argv) -lt 1
        echo "Usage:"
        echo "    rmount [-u|--unmount] [-s|--status] mount_name"
        echo ""
        echo "Options:"
        echo "    -u, --unmount   Stop the service (unmount)."
        echo "    -s, --status    Print the status of an rclone mount (via rclone rc)."
        echo ""
        echo "The --status option only works for rclone mounts that have the rc"
        echo "socket enabled, as shown in the example unit below."
        echo ""
        echo "For the given mount_name, the function looks for a systemd user unit"
        echo "named "$rmount_unit_prefix\$mount_name".service' (via"
        echo "'systemctl --user list-unit-files'). It starts that service to mount,"
        echo "and stops it to unmount."
        echo ""
        echo "The unit should mount to '$rmount_base_path/\$mount_name'."
        echo ""
        echo "Example unit (~/.config/systemd/user/"$rmount_unit_prefix"graz-pi5.service):"
        echo "    [Service]"
        echo "    Type=notify"
        echo "    RuntimeDirectory=rclone-graz-pi5"
        echo "    RuntimeDirectoryMode=0700"
        echo "    ExecStart=rclone mount graz-pi5:/srv %h/remote/graz-pi5 \\"
        echo "      --vfs-cache-mode writes \\"
        echo "      --vfs-cache-max-size 10G \\"
        echo "      --rc \\"
        echo "      --rc-addr unix://%t/rclone-graz-pi5/rc.sock"
        echo "    ExecStop=fusermount3 -u -z %h/remote/graz-pi5"
        echo ""
        echo "    [Unit]"
        echo "    Description=rclone mount for graz-pi5"
        echo ""
        echo ""
        echo "Example sshfs unit (~/.config/systemd/user/"$rmount_unit_prefix"graz-pi5.service):"
        echo "    [Unit]"
        echo "    Description=sshfs mount for graz-pi5"
        echo "    After=network-online.target"
        echo ""
        echo "    [Service]"
        echo "    Type=simple"
        echo "    ExecStart=/usr/bin/sshfs graz-pi5:/ %h/remote/graz-pi5 -o idmap=user,transform_symlinks,follow_symlinks,dir_cache=yes"
        echo "    ExecStop=/bin/fusermount -u %h/remote/graz-pi5"
        echo "    Restart=on-failure"
        echo ""
        echo "    [Install]"
        echo "    WantedBy=default.target"
        echo ""
        echo "A folder '$rmount_base_path/\$mount_name' will be created and used as"
        echo "the mount point."
        return 0
    end

    set mount_name $argv[1]
    set service_name "$rmount_unit_prefix$mount_name.service"
    set rmount_destination_path "$rmount_base_path/$mount_name"

    if not systemctl --user list-unit-files --no-legend "$service_name" 2>/dev/null | string match -q "*"
        echo "No systemd user service found for '$service_name'."
        return 1
    end

    if ! test -d "$rmount_base_path"
        echo "Base path [$rmount_base_path] is missing."
        return 1
    end

    if set -ql _flag_status
        set -l runtime_dir "$XDG_RUNTIME_DIR"
        if test -z "$runtime_dir"
            set runtime_dir "/run/user/"(id -u)
        end
        set -l socket_path "$runtime_dir/rclone-$mount_name/rc.sock"
        if not test -S "$socket_path"
            echo "No rclone socket found at $socket_path. Is the mount running and is it an rclone mount?"
            return 1
        end
        rclone rc --unix-socket "$socket_path" core/stats
        return $status
    end

    if set -ql _flag_unmount
        systemctl --user stop "$service_name"
        return $status
    end

    if ! test -d "$rmount_destination_path"
        mkdir -p "$rmount_destination_path"
        if ! test -d "$rmount_destination_path"
            echo "Destination path [$rmount_destination_path] could not be created."
            return 1
        end
    end

    systemctl --user start "$service_name"
    and pushd "$rmount_destination_path"
end

complete -c rmount -f -a "(__rmount_units)"
