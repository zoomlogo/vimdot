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
nn - <cmd>Vired<cr>
nn D d$
nn Y y$
nn <m-w> viw
":
cno <C-a> <Home>
cno <C-e> <End>
cno <C-p> <Up>
cno <C-n> <Down>
cno <C-b> <Left>
cno <C-f> <Right>
"swapline
nn <m-j> <cmd>m .+1<cr>==
nn <m-k> <cmd>m .-2<cr>==
ino <m-j> <Esc><cmd>m .+1<cr>==gi
ino <m-k> <Esc><cmd>m .-2<cr>==gi
vn <m-j> :m '>+1<cr>gv=gv
vn <m-k> :m '<-2<cr>gv=gv
"center screen
nn <C-u> <C-u>zz
nn <C-d> <C-d>zz
nn <C-f> <C-f>zz
nn <C-b> <C-b>zz
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
"file specific maps:
aug B
  au!
  au filetype python nn <buffer> <leader>b :up<cr>:!clear && python %<cr>
  au filetype k nn <buffer> <leader>b :up<cr>:!clear && ~/k/k %<cr>
  au filetype c nn <buffer> <leader>b :up<cr>:!clear && gcc % -Wall -Wextra -O2 -std=c23 && ./a.out<cr>
  au filetype cpp nn <buffer> <leader>b :up<cr>:!clear && g++ % -Wall -Wextra -O2 -std=c++23 && ./a.out<cr>
  au filetype tex nn <buffer> <leader>b :up<cr>:!clear && pdflatex % && pdfmv %:t:r.pdf<cr>
  au bufnew,bufnewfile,bufread *.flx nn <buffer> <leader>b :up<cr>:!flax f %<cr>
  au filetype make setl noet
  au filetype tex setl ts=2 sw=2 isk+=:
aug END
"c/c++ source/header swapping
if !exists('g:loaded_lsp')
  "LspSwitchSourceHeader replaces this
  au bufnew,bufenter *.cpp nn <m-p> :e %<.hpp<cr>
  au bufnew,bufenter *.hpp nn <m-p> :e %<.cpp<cr>
  au bufnew,bufenter *.c nn <m-p> :e %<.h<cr>
  au bufnew,bufenter *.h nn <m-p> :e %<.c<cr>
endif
"fzf+rg
nn <leader>r <cmd>Rg<cr>
nn <c-t> <cmd>GFiles --cached --others --exclude-standard<cr>
nn <leader>f <cmd>Files<cr>
"swap args
nn <m-h> <cmd>SidewaysLeft<cr>
nn <m-l> <cmd>SidewaysRight<cr>
"snips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
"undotree
nn <leader>u <cmd>UndotreeToggle<cr>
"lsp mappings
if exists('g:loaded_lsp')
  nn <m-a> <cmd>LspCodeAction<cr>
  nn <m-d> <cmd>LspDiag next<cr>
  nn <m-D> <cmd>LspDiag prev<cr>
  nn <m-s> <cmd>LspDiagShow<cr>
  nn <leader>gd <cmd>LspGotoDeclaration<cr>
  nn gd <cmd>LspGotoDefinition<cr>
  nn <leader>gi <cmd>LspGotoImpl<cr>
  nn gy <cmd>LspGotoTypedef<cr>
  nn K <cmd>LspHover<cr>
  nn gr <cmd>LspRename<cr>
  nn <m-p> <cmd>LspSwitchSourceHeader<cr>
endif
