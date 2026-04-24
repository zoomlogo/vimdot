"basic config
se nocp nohls nowrap et ts=4 sw=4 is nu rnu ls=2 tgc noswf nowb so=6 nosmd ic ai
se stal=2 list bg=dark cole=1 pp+=~/.vim fdls=99 hid cul scs nofen cc=80 top sc
se bs=2 wmnu shm=asWIcq ttimeout ttm=50 tm=600 rtp+=~/k/vim-k scl=yes bg=dark
se ut=100 cpt+=o tw=100 t_Co=256 culopt=number enc=utf-8 gp=rg\ --vimgrep\ -P
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
filet plugin indent on | sy enable
colo catppuccin
let &listchars="tab:\xbb "
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:gitgutter_sign_priority=0
let g:loaded_netrw=1 | let g:loaded_netrwPlugin=1
let g:markdown_folding=1
let g:markdown_fenced_languages=['c','cpp','k','python','rust','vim','bash=sh','pikchr']
let g:fuzzbox_mappings=0
let g:snips_author='zoomlogo'
let $MANWIDTH=78
"other
ru ftplugin/man.vim | se keywordprg=:Man
pa! cfilter | pa! matchit | pa! termdebug
pa lsp | so ~/.vim/lspconf.vim
so ~/.vim/maps.vim | so ~/.vim/pmaps.vim | so ~/.vim/syn.vim
