set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath

source ~/.vim/vimrc

" Language server protocol {{{
"
"
" Enable clangd with completion-nvim
lua require'lspconfig'.clangd.setup{on_attach=require'completion'.on_attach}
" }}}
"

