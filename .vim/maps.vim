"core
nn Y y$
nn <m-w> viw
nn <space> :
nn : ,
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
"file specific settings/autocmds
aug vimdot
  au!
  au filetype * setl fo-=o
  "
  au vimenter * ++once call s:viredstart()
  au filetype make setl noet ts=8 sw=8
  au filetype tex setl ts=2 sw=2 isk+=:
  au filetype c,cpp setl commentstring=//\ %s
  "bin help
  au bufreadpre *.bin let &bin=1
  au bufreadpost *.bin if &bin | %!xxd
  au bufreadpost *.bin se ft=xxd | endif
  au bufwritepre *.bin if &bin | %!xxd -r
  au bufwritepre *.bin endif
  au bufwritepost *.bin if &bin | %!xxd
  au bufwritepost *.bin se nomod | endif
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
"c/c++ source/header swapping
if !exists('g:loaded_lsp')
  "LspSwitchSourceHeader replaces this
  au bufnew,bufenter *.cpp nn <m-p> :e %<.hpp<cr>
  au bufnew,bufenter *.hpp nn <m-p> :e %<.cpp<cr>
  au bufnew,bufenter *.c nn <m-p> :e %<.h<cr>
  au bufnew,bufenter *.h nn <m-p> :e %<.c<cr>
endif
"fuzzbox
nn <leader>g <cmd>FuzzyGrep<cr>
nn <leader>f <cmd>FuzzyFiles<cr>
nn <leader>d <cmd>FuzzyBuffers<cr>
nn <leader>c <cmd>FuzzyColors<cr>
"swap args
nn <m-h> <cmd>SidewaysLeft<cr>
nn <m-l> <cmd>SidewaysRight<cr>
"easy align
nn ga <Plug>(EasyAlign)
vn ga <Plug>(EasyAlign)
"vismulti
let g:VM_maps = {}
let g:VM_show_warnings = 0
let g:VM_silent_exit = 1
let g:VM_maps['Visual Cursors'] = 'gl'
let g:VM_maps['Add Cursor Down'] = '<C-j>'
let g:VM_maps['Add Cursor Up'] = '<C-k>'
"vim-latex
imap <C-J> <Plug>IMAP_JumpForward
"snips
imap <C-j> <Plug>snip9nextOrTrigger
smap <C-j> <Plug>snip9nextOrTrigger
xmap <C-j> <Plug>snip9visual
imap <C-k> <Plug>snip9back
smap <C-k> <Plug>snip9back
"undotree
nn <leader>u <cmd>UndotreeToggle<cr>
"lsp mappings
nn <m-a> <cmd>LspCodeAction<cr>
nn ]e <cmd>LspDiag next<cr>
nn [e <cmd>LspDiag prev<cr>
nn <m-s> <cmd>LspDiagShow<cr>
nn <leader>gd <cmd>LspGotoDeclaration<cr>zz
nn gd <cmd>LspGotoDefinition<cr>zz
nn <leader>gi <cmd>LspGotoImpl<cr>zz
nn gy <cmd>LspGotoTypedef<cr>zz
nn <leader>k <cmd>LspHover<cr>
nn gr <cmd>LspRename<cr>
nn <m-r> <cmd>LspShowReferences<cr>
nn <m-p> <cmd>LspSwitchSourceHeader<cr>
"X11-only
if executable('xclip')
  vn <silent> <leader>y y<cmd>call system('xclip -selection clipboard', @")<cr>
endif
"quick-diff current (use :Gdiffsplit for git files)
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
