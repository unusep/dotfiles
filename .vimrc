set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround' 

Plugin 'wincent/command-t'
" Webdev stuff
Plugin 'skammer/vim-css-color'      
Plugin 'hail2u/vim-css3-syntax'  
" Ruby/Rails
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-rails'
" Javascript/Node
Plugin 'pangloss/vim-javascript'
Plugin 'moll/vim-node'
" Haskell
Plugin 'itchyny/vim-haskell-indent'
" Jekyll
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" " plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" " Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" " git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" " The sparkup vim script is in a subdirectory of this repo called vim.
" " Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" " Install L9 and avoid a Naming conflict if you've already installed a
" " different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
" """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

"Always show current position
set ruler
syntax on

" Line ends at 80 char
set textwidth=80

" Colour
let g:solarized_termcolors=256 " color depth
let g:solarized_termtrans=0 " 1|0 background transparent
let g:solarized_bold=1 " 1|0 show bold fonts
let g:solarized_italic=1 " 1|0 show italic fonts
let g:solarized_underline=1 " 1|0 show underlines
let g:solarized_contrast="normal" " normal|high|low contrast
let g:solarized_visibility="low" " normal|high|low effect on whitespace characters
set background=dark
colorscheme solarized

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Set line numbers
set nu
set cursorline

" Copy to system clipboard
set clipboard=unnamed

" Set mouse mode to enable scrolling, highlighting etc
set mouse=a
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Fold method
" set foldmethod=syntax

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2


""""""""""""""""""""""""""""""
" => NerdTree
""""""""""""""""""""""""""""""
" Toggle nerdtree shortcut
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1

""""""""""""""""""""""""""""
" => Window manipulation
""""""""""""""""""""""""""""
nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-j> <C-w>j

""""""""""""""""""""""""""""
" => File specific setting
""""""""""""""""""""""""""""
autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2
autocmd Filetype markdown setlocal ts=2 sts=2 sw=2
autocmd Filetype md setlocal ts=2 sts=2 sw=2
autocmd Filetype css setlocal ts=2 sts=2 sw=2
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2

""""""""""""""""""""""""""""
" => YAML front matter
""""""""""""""""""""""""""""
