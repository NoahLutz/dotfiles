" Tab settings
set tabstop=3
set softtabstop=0
set shiftwidth=3
set expandtab
set smarttab

" Editor settings
set number
set splitright
set splitbelow
set nowrap
syntax on
filetype plugin indent on
set directory=$HOME/.vim/swapfiles//
set scrolloff=5
set tags=.tags
set colorcolumn=81
highlight ColorColumn ctermbg=0

" Statusline

"set statusline=%{ObsessionStatus()}
"set statusline+=%#PmenuSel#
"set statusline+=%#LineNr#
"set statusline+=\ %f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)

" Bindings
nnoremap <C-n> :NERDTreeFocus<CR>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-h> <C-w><C-h>
nnoremap <C-l> <C-w><C-l>

" Run pathogen
execute pathogen#infect()

" Autocommands 

augroup format_options
   autocmd BufNewFile,BufRead * setlocal formatoptions-=cro
augroup END

" Auto close vim if NERDTree is the last window
augroup NERDTree_close
   autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" Re-run ctags on *.c *.h file writes
"augroup ctags_refresh
"   autocmd BufWritePost *.c silent exec "!ctags -R ."
"   autocmd BufWritePost *.h silent exec "!ctags -R ."
"augroup END

" Macros
let @c = '0i//0j'
