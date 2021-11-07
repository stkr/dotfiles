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


