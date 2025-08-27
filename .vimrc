" ============================================================================
"                       Vim Config Multi-linguagem
" ============================================================================
" - Transparente para Alacritty
" - Auto-completion (), {}, []
" - NERDTree com ícones
" - Barra de status com vim-airline
" - Fuzzy finder FZF
" - Autocomplete Coc.nvim com fundo preto e letras vermelhas
" - Linha atual sem cor de fundo
" - Atalhos com <leader> (barra de espaço)
" ============================================================================

" -----------------------------
" === Leader key ===
" -----------------------------
let mapleader = " "  " barra de espaço como leader

" -----------------------------
" === Interface / Aparência ===
" -----------------------------
set number
set relativenumber
set cursorline
set showcmd
set wildmenu
syntax on
filetype plugin indent on

if has("termguicolors")
  set termguicolors
endif

" Fundo transparente
hi Normal ctermbg=NONE guibg=NONE
hi NonText ctermbg=NONE guibg=NONE
hi LineNr ctermbg=NONE guibg=NONE
hi SignColumn ctermbg=NONE guibg=NONE

hi CursorLine ctermbg=NONE guibg=NONE

" -----------------------------
" === Cores do autocomplete ===
" -----------------------------
hi Pmenu guibg=black guifg=red
hi PmenuSel guibg=darkred guifg=white
hi PmenuSbar guibg=black
hi PmenuThumb guibg=red

" -----------------------------
" === Tabs & Indentação ===
" -----------------------------
set expandtab
set shiftwidth=4
set tabstop=4
set smartindent

" -----------------------------
" === Busca ===
" -----------------------------
set ignorecase
set smartcase
set hlsearch
set incsearch

" -----------------------------
" === Backup & Undo ===
" -----------------------------
set nobackup
set nowritebackup
set undofile

" -----------------------------
" === Atalhos principais ===
" -----------------------------
inoremap jk <ESC>

" -----------------------------
" === Atalhos <leader> (barra de espaço) ===
" -----------------------------
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>s :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>z :wq<CR>

nnoremap <leader>x ggVG
if has('clipboard')
    nnoremap <leader>c :%y+<CR>
else
    nnoremap <leader>c :%y*<CR>
endif
nnoremap <leader>d :%d<CR>

" Atalho para rodar C++ usando vim-dispatch
nnoremap <leader>p :w<CR>:Dispatch g++ % -o %:r && ./%:r<CR>

" Atalho para rodar Python
nnoremap <leader>o :w<CR>:!python3 %<CR>

" Atalho para rodar Ruby
nnoremap <leader>i :w<CR>:!ruby %<CR>

" -----------------------------
" === Plugins (vim-plug) ===
" -----------------------------
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Plugin para compilar/rodar C++
Plug 'tpope/vim-dispatch'

call plug#end()

" -----------------------------
" === Configuração CoC (Autocompletion) ===
" -----------------------------
inoremap <silent><expr> <TAB>      pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB>    pumvisible() ? "\<C-p>" : "\<S-TAB>"
inoremap <silent><expr> <CR>       pumvisible() ? coc#_select_confirm() : "\<CR>"

" -----------------------------
" === Configuração Vim-Airline ===
" -----------------------------
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" -----------------------------
" === Configuração NERDTree com ícones ===
" -----------------------------
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:WebDevIconsUnicodeDecorateFileNodes = 1
autocmd VimEnter * if argc() == 0 | NERDTree | endif
