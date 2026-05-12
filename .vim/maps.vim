"core
nn Y y$
nn <m-w> viw
nn <space> :
vn <space> :
nn : ,
vn : ,
nn K i<cr><esc>
nn Q @q
"leaders
let mapleader=","
nn <leader>w <cmd>up<cr>
nn <leader>h <cmd>vs<cr>
nn <leader>v <cmd>sp<cr>
nn <leader>t <cmd>tabnew<cr>
nn <leader>n <cmd>tabn<cr>
nn <leader>p <cmd>tabp<cr>
nn <leader>cd <cmd>cd %:h<cr>
nn <leader>K K
nn <leader>s <cmd>se bt=nofile<cr>
"duplicate
nn <leader>y myyyp`yj
"quicklist
nn ]q <cmd>cn<cr>zz
nn [q <cmd>cp<cr>zz
"locationlist
nn ]l <cmd>lne<cr>zz
nn [l <cmd>lp<cr>zz
":
cno <c-a> <Home>
cno <c-e> <End>
cno <c-h> <Left>
cno <c-j> <Down>
cno <c-k> <Up>
cno <c-l> <Right>
"bubble
nn <silent> <m-j> <cmd>sil! m .+1<cr>
nn <silent> <m-k> <cmd>sil! m .-2<cr>
vn <silent> <m-j> :m '>+1<cr>gv=gv
vn <silent> <m-k> :m '<-2<cr>gv=gv
"center screen
nn <c-u> <c-u>zz
nn <c-d> <c-d>zz
nn <c-f> <c-d><c-d>zz
nn <c-b> <c-u><c-u>zz
nn n nzz
nn N Nzz
"more window management (along with vim-terminal-help)
nn <m-U> <c-w>H
nn <m-I> <c-w>J
nn <m-O> <c-w>K
nn <m-P> <c-w>L
nn <m-N> <c-w>R
nn <m-M> <c-w>r
"tab for completion
ino <expr> <Tab> pumvisible() ? "\<C-n>" : "\t"
ino <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\t"
"quick-diff current state
fu! s:qdiff()
  vert sp | winc p
  ene | se bt=nofile | r # | norm! ggdd
  let &filetype = getbufvar('#', '&filetype')
  difft | winc p | difft
endfu
fu! s:qdiffi()
  diffo | winc p
  bw!
endfu
com! Diff call s:qdiff()
com! DiffI call s:qdiffi()
"bin
fu! s:xxd()
  let l:m=&mod
  if !exists('b:hex') || !b:hex
    let b:hex=1
    %!xxd
    setl ft=xxd
  el
    let b:hex=0
    %!xxd -r
    setl ft= | filet detect
  en
  if !l:m | setl nomod | en
endfu
com! Hex call s:xxd()
"file specific settings/autocmds
aug vimdot
  au!
  au filetype * setl fo-=o
  "
  au vimenter * ++once call s:viredstart()
  au filetype make setl noet ts=8 sw=8
  au filetype tex setl ts=2 sw=2 isk+=:
  au filetype c,cpp setl commentstring=//\ %s noet ts=8 sw=8
  au filetype markdown setl cole=2 cocu=nc et ts=4 sw=4 js cc=0 tw=78 fo=tcqn
  "man
  au filetype man setl cc=0 nonu nornu scl=no
aug END
"vired autostart (autocmd defined below)
nn - <cmd>Vired<cr>
fu! s:viredstart()
  if argc() == 1 && isdirectory(argv(0))
    let l:path = fnameescape(expand(argv(0)))
    bw!
    execute 'Vired ' . l:path
  endif
endfu
"buildme.vim
nn <leader>b <cmd>BuildMe<cr>
nn <leader>r <cmd>RunMe<cr>
"X11-only
if executable('xclip')
  vn <silent> <leader>y y<cmd>call system('xclip -selection clipboard', @")<cr>
endif
