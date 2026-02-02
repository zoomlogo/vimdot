"basic config
se nocp nohls nowrap et ts=4 sw=4 nobk ru is nu rnu ls=2 tgc noswf nowb so=6 t_Co=256 culopt=number
se stal=2 list bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim fdls=99 ai hid cpt+=o cul ic scs
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8 scl=yes ut=100
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
filet plugin indent on
sy enable
colo habamax
let &listchars="tab:\xbb "
let g:colorscheme_changer_colors=['decino','everforest','onedark','gruvbox','cemant']
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:gitgutter_sign_priority=0
let g:loaded_netrw=1
let g:loaded_netrwPlugin=1
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
aug ll
  au!
  au vimenter * ++once pa lsp | so ~/.vim/lspconf.vim
aug END
"other
so ~/.vim/maps.vim "mappings
so ~/.vim/syn.vim  "syntax highlighting
