if status is-interactive
    # Commands to run in interactive sessions can go here
    alias np='nvim -S .session.vim'
    alias feh='feh --theme default'
    alias thumbs='feh --theme thumbnails'
    alias cm='chezmoi'

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
