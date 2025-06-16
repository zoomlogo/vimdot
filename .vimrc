"basic config
se nocp nohls nowrap et ts=4 sw=4 nobk ru is nu rnu ls=2 tgc noswf nowb so=1 t_Co=256 ai
se stal=2 list lcs=tab:→\ ,space:· bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim fdls=99
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8 scl=number ut=100 nohid
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
filet plugin indent on
sy enable
colo decino
let g:colorscheme_changer_colors=['decino','everforest','onedark','gruvbox','cemant']
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:vimcomplete_tab_enable=1
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
"other
so ~/.vim/maps.vim
so ~/.vim/lspconf.vim
