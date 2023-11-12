if status is-interactive
    # Commands to run in interactive sessions can go here
    alias dt='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias np='nvim -S .session.vim'
    alias thumbs='feh --thumbnails --thumb-width=200 --thumb-height=200 --limit-width=1900'

    # Load the fzf keybindings. Note, this relies on key-bindings.fish being
    # installed in ~/.config/fish/functions!
    if test -f ~/.config/fish/functions/key-bindings.fish
        fzf_key_bindings
    end

    # Load the fzf keybindings. Note, this relies on git_fzf.fish being
    # installed in ~/.config/fish/functions!
    if test -f ~/.config/fish/functions/git_fzf.fish
        source ~/.config/fish/functions/git_fzf.fish
        git_fzf_key_bindings
    end

    # Use ctrl+l to complete one word of autosuggestion
    bind -M insert \cl 'forward-word'
end
