se nocp nohls nowrap et ts=4 sw=4 nobk ru is nu rnu ls=2 tgc noswf nowb so=1 title
se stal=2 list lcs=tab:→\ ,space:· bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8 scl=number
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
au filetype python nn <cr> :w<cr>:!clear && python %<cr>
au filetype k nn <cr> :w<cr>:!clear && ~/k/k %<cr>
au filetype c nn <cr> :w<cr>:!clear && gcc % -Wall -Wextra -O2 -std=c17 && ./a.out<cr>
au filetype cpp nn <cr> :w<cr>:!clear && g++ % -Wall -Wextra -O2 -std=c++20 && ./a.out<cr>
au filetype tex nn <cr> :w<cr>:!clear && pdflatex % && pdfmv %:t:r.pdf<cr>
au bufnew,bufnewfile,bufread *.flx nn <cr> :w<cr>:!flax f %<cr>
au filetype make se noet
au filetype tex se ts=2 sw=2 isk+=:
filet plugin indent on
sy enable
colo decino
let g:colorscheme_changer_colors=['decino','everforest','onedark','cemant','darcula']
nm <space> <nop>
let g:rainbow_active=1
let g:tex_flavor="latex"
let g:vimcomplete_tab_enable = 1
let mapleader=" "
nm Q @q
nm <leader>w <cmd>w<cr>
nm <leader>h <cmd>vsplit<cr>
nm <leader>v <cmd>split<cr>
nm <leader>t <cmd>tabnew<cr>
nm <leader>p <cmd>tabnext<cr>
nm <leader>cd <cmd>cd %/..<cr>
nm <leader>cc <cmd>ChangeColor<cr>
nm D d$
nm Y y$
nm <m-w> viw
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
