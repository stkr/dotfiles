set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

source ~/.vim/vimrc

" Language server protocol {{{
"
if (has('nvim'))
    " Enable clangd
    lua << EOF
require'lspconfig'.clangd.setup{}
EOF
endif
" }}}
"

