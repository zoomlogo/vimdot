nn <space> <nop>
let mapleader=" "
nn Q @q
nn <leader>w <cmd>up<cr>
nn <leader>h <cmd>vs<cr>
nn <leader>v <cmd>sp<cr>
nn <leader>t <cmd>tabnew<cr>
nn <leader>n <cmd>tabn<cr>
nn <leader>cd <cmd>cd %:h<cr>
nn <leader>cc <cmd>ChangeColor<cr>
nn <leader>cr <cmd>RandomColor<cr>
nn D d$
nn Y y$
nn <m-w> viw
"quicklist
nn ]q <cmd>cn<cr>
nn [q <cmd>cp<cr>
nn [] <cmd>copen<cr>
nn ][ <cmd>cgetbuffer<cr>
"vired autostart (autocmd defined below)
nn - <cmd>Vired<cr>
fu! s:viredstart()
  if argc() == 1 && isdirectory(argv(0))
    let l:path = fnameescape(expand(argv(0)))
    bw!
    execute 'Vired ' . l:path
  endif
endfu
":
cno <c-a> <Home>
cno <c-e> <End>
cno <c-p> <Up>
cno <c-n> <Down>
cno <c-b> <Left>
cno <c-f> <Right>
"bubble
nn <silent> <m-j> <cmd>sil! m .+1<cr>
nn <silent> <m-k> <cmd>sil! m .-2<cr>
ino <silent> <m-j> <Esc><cmd>sil! m .+1<cr>gi
ino <silent> <m-k> <Esc><cmd>sil! m .-2<cr>gi
vn <silent> <m-j> :m '>+1<cr>gv=gv
vn <silent> <m-k> :m '<-2<cr>gv=gv
"center screen
nn <c-u> <c-u>zz
nn <c-d> <c-d>zz
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
  au vimenter * ++once call s:viredstart()
  au filetype make setl noet
  au filetype tex setl ts=2 sw=2 isk+=:
  au filetype c,cpp setl commentstring=//\ %s
aug END
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
"fzf+rg
nn <c-g> <cmd>Rg<cr>
nn <c-f> <cmd>GFiles --cached --others --exclude-standard<cr>
nn <c-t> <cmd>Files<cr>
nn <c-b> <cmd>Buffers<cr>
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
"snips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
"undotree
nn <leader>u <cmd>UndotreeToggle<cr>
"lsp mappings
nn <m-a> <cmd>LspCodeAction<cr>
nn <leader>d <cmd>LspDiag next<cr>
nn <leader>D <cmd>LspDiag prev<cr>
nn <m-s> <cmd>LspDiagShow<cr>
nn <leader>gd <cmd>LspGotoDeclaration<cr>
nn gd <cmd>LspGotoDefinition<cr>
nn <leader>gi <cmd>LspGotoImpl<cr>
nn gy <cmd>LspGotoTypedef<cr>
nn K <cmd>LspHover<cr>
nn gr <cmd>LspRename<cr>
nn <m-p> <cmd>LspSwitchSourceHeader<cr>
"wsl-only
if executable('clip.exe')
  vn <silent> <leader>y y<cmd>call system('clip.exe', @")<cr>
endif
