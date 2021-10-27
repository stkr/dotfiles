if status is-interactive
    # Commands to run in interactive sessions can go here
    alias dt='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

    # Directory shortcuts
    function sc -d "Shortcut for commonly used paths"
        if test (count $argv) -lt 1
            echo "Missing path argument."
            return
        end
        switch $argv[1]
            case 'ant'
                cd ~/data/src/rust/ant_simulation/
            case '*'
                echo "Unknown shortcut \"$argv[1]\"."
        end
    end

    # Use ctrl+l to complete one word of autosuggestion
    bind -M insert \cl 'forward-word'
end
