if status is-interactive
    # Commands to run in interactive sessions can go here
    alias dt='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias np='nvim -S .project.vim'

    # Use ctrl+l to complete one word of autosuggestion
    bind -M insert \cl 'forward-word'
end
