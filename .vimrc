" Enable Pathogen
execute pathogen#infect()

" Enable Omni completion
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Enable neocomplete
"let g:neocomplete#enable_at_startup = 1

" Enable syntax highlighting
syntax enable

" Enable indentation definition on a file type basis
filetype plugin indent on

" Set indentation to use use (4) spaces
set expandtab
set shiftwidth=4
set softtabstop=4

" Show line numbers
set number

" Shoe command in bottom bar
set showcmd
set wildmenu
set lazyredraw
set showmatch
set incsearch
set hlsearch


" Highlight current line
set cursorline

" Set theme and enable powerline
set background=dark
colorscheme gruvbox
let g:airline_powerline_fonts=1

" Disable folding
set nofoldenable

" Jump to last time position
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

