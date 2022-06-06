if status is-interactive
    # Commands to run in interactive sessions can go here
    alias dt='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias np='nvim -S .project.vim'
    alias thumbs='feh --thumbnails --thumb-width=200 --thumb-height=200 --limit-width=1900'

    # Use ctrl+l to complete one word of autosuggestion
    bind -M insert \cl 'forward-word'
end
