colorscheme monokai
nnoremap <esc> :noh<return><esc>
nnoremap <M-d> <Nop>
nnoremap <M-y> :w! \| !~/.scripts/compile <c-r>%<CR>

set autoread
set backspace=indent,eol,start
set clipboard=unnamedplus
set encoding=utf-8
set expandtab
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set magic
set mouse=a
set nocompatible
set number
set scrolloff=5
set shiftwidth=2
set showmatch
set smartcase
set smartindent
set smarttab
set softtabstop=2
set tabstop=2
set ttyfast
set undolevels=100
syntax on

set statusline=\ %F
set statusline+=\ %h
set statusline+=%m
set statusline+=%r
set statusline+=%=
set statusline+=line\ %l\ of\ %L
set statusline+=\ ≈\ %P
