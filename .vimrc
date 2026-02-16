"basic config
se nocp nohls nowrap et ts=4 sw=4 nobk ru is nu rnu ls=2 tgc noswf nowb so=6
se stal=2 list bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim fdls=99 ai hid
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8 scl=yes
se ut=100 bg=dark cpt+=o cul ic scs cc=80 tw=100 t_Co=256 culopt=number nofen
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
filet plugin indent on | sy enable
colo habamax
let &listchars="tab:\xbb "
let g:colorscheme_changer_colors=['wildcharm','habamax','onedark','gruvbox',
            \'cemant','unokai','quiet','sorbet','slate','lunaperche']
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:gitgutter_sign_priority=0
let g:loaded_netrw=1
let g:loaded_netrwPlugin=1
let g:markdown_folding=1
let g:markdown_fenced_languages=['c','cpp','k','python','rust','vim','bash=sh']
let $MANWIDTH=78
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
"other
ru ftplugin/man.vim | se keywordprg=:Man
pa! cfilter | pa! matchit | pa! termdebug
pa lsp | so ~/.vim/lspconf.vim
so ~/.vim/maps.vim "mappings
so ~/.vim/syn.vim  "syntax highlighting
