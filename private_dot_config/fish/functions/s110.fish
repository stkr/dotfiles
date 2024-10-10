function _s110_init
    set -g -x JIRA_PROJECT "ESE"
    set -g -x BASE_PATH "/home/$USER/projects/s110"
    set -g -x LLVM_BIN_PATH $BASE_PATH/src/riscv32-nxp-elf_0.7.2_cssi/bin

    source "$BASE_PATH/.venv/bin/activate.fish"
end

function _s110_cd
    if test -z "$JIRA_PROJECT"
        _s110_init
    end

    cd "$BASE_PATH/src/s400"
end

function _s110_edit
    _s110_cd
    nvim -S .session.vim
end

function _s110_branch -a nr -a text
    if test -z "$JIRA_PROJECT"
        _s110_init
    end

    if test (count $argv) -lt 2
        echo "Not enough arguments. Usage: branch NR TEXT."
        return 1
    end

    set -l owner "sk"
    set -l branch "$owner/$JIRA_PROJECT-$nr-$text"
    
    git checkout -b "$branch"; or return
    git push --set-upstream origin "$branch"; or return
end

function _s110_bininfo -a objectfile
    if test -z "$JIRA_PROJECT"
        _s110_init
    end

    if test (count $argv) -lt 1
        echo "Not enough arguments. Usage: bininfo FILE."
        return 1
    end

    set -l objdump "$LLVM_BIN_PATH/llvm-objdump"
    if ! test -e "$objdump"
        echo "Objdump $objdump does not exist"
        return 1
    end

    $objdump --disassemble $argv[1] > "$argv[1].dis"; or return
    echo "disassembly written to [$argv[1].dis]"
    $objdump --syms "$argv[1]" | sort > "$argv[1].sym"; or return
    echo "symbol table written to [$argv[1].sym]"
end

function s110 -d "Functions specific to s110 project"
    # We tell argparse about -h/--help and others -these are short and long
    # forms of the same option. The "--" here is mandatory, it tells it from
    # where to read the arguments.
    argparse h/help -- $argv; or return

    # If -h or --help is given, we print a little help text and return
    if set -ql _flag_help || test (count $argv) -lt 1
        echo "Usage:                                                     "
        echo "    s110 command                                           "
        echo "                                                           "
        echo "Valid commands:                                            "
        echo "    * init: Initialize the environment (incl. python venv)."
        echo "    * cd: Iniialize the environment and change to the      "
        echo "      source directory.                                    "
        echo "    * edit: Initialize the environment and launch nvim in  "
        echo "      the source directory.                                "
        echo "    * branch: Create a branch from the currently checked   "
        echo "      out commit. Takes an artifact number and a short     "
        echo "      description as arguments.                            "
        echo "    * bininfo: Extract disassembly and symbol file from    "
        echo "      binary.                                              "
        return 0
    end

    switch $argv[1]
        case init
            _s110_init
        case cd
            _s110_cd
        case edit
            _s110_edit
        case branch
            _s110_branch $argv[2..-1]
        case bininfo
            _s110_bininfo $argv[2..-1]
        case '*'
            echo Unsupported command \"$argv[1]\"
            return 1
    end
end

set -l s110_commands init cd edit branch bininfo
complete -c s110 -f -s h -l help
complete -c s110 -f -n "not __fish_seen_subcommand_from $s110_commands" -a "init" -d "Initialize the environment (incl. python venv)."
complete -c s110 -f -n "not __fish_seen_subcommand_from $s110_commands" -a "cd" -d "Iniialize the environment and change to the source directory."
complete -c s110 -f -n "not __fish_seen_subcommand_from $s110_commands" -a "edit" -d "Initialize the environment and launch nvim in the source directory."
complete -c s110 -f -n "not __fish_seen_subcommand_from $s110_commands" -a "branch" -d "Create a branch from the currently checked out commit."
complete -c s110 -n "not __fish_seen_subcommand_from $s110_commands" -a "bininfo" --force-files -d "Extract disassembly and symbol file from binary."
