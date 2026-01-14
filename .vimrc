"basic config
se nocp nohls nowrap et ts=4 sw=4 nobk ru is nonu nornu ls=2 tgc noswf nowb so=4 t_Co=256
se stal=2 list bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim fdls=99 ai hid cpt+=o
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8 scl=yes ut=100
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
filet plugin indent on
sy enable
colo onedark
let &listchars="tab:\xbb "
let g:colorscheme_changer_colors=['decino','everforest','onedark','gruvbox','cemant']
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:vimcomplete_tab_enable=1
let g:gitgutter_sign_priority=0
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
"lsp (to disable it, comment the next line)
pa lsp
if exists('g:loaded_lsp')
    so ~/.vim/lspconf.vim
endif
"other
so ~/.vim/maps.vim "mappings
so ~/.vim/syn.vim  "syntax highlighting
