syntax on
colorscheme elflord

filetype on
filetype plugin on
filetype indent on

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set cindent

set pastetoggle=<F2>

execute pathogen#infect()

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_perl_checkers = ['perl']
let g:syntastic_php_checkers = ['php']
