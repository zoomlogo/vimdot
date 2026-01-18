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
au filetype python nn <leader>b :up<cr>:!clear && python %<cr>
au filetype k nn <leader>b :up<cr>:!clear && ~/k/k %<cr>
au filetype c nn <leader>b :up<cr>:!clear && gcc % -Wall -Wextra -O2 -std=c23 && ./a.out<cr>
au filetype cpp nn <leader>b :up<cr>:!clear && g++ % -Wall -Wextra -O2 -std=c++23 && ./a.out<cr>
au filetype tex nn <leader>b :up<cr>:!clear && pdflatex % && pdfmv %:t:r.pdf<cr>
au bufnew,bufnewfile,bufread *.flx nn <leader>b :up<cr>:!flax f %<cr>
au filetype make se noet
au filetype tex se ts=2 sw=2 isk+=:
"c/c++ source/header swapping
if !exists('g:loaded_lsp')
  "LspSwitchSourceHeader replaces this
  au bufnew,bufenter *.cpp nn <leader>p :e %<.hpp<cr>
  au bufnew,bufenter *.hpp nn <leader>p :e %<.cpp<cr>
  au bufnew,bufenter *.c nn <leader>p :e %<.h<cr>
  au bufnew,bufenter *.h nn <leader>p :e %<.c<cr>
endif
"fzf+rg
nn <leader>r <cmd>Rg<cr>
nn <c-f> <cmd>GFiles --cached --others --exclude-standard<cr>
nn <leader>f <cmd>Files<cr>
"swap args
nn <m-h> <cmd>SidewaysLeft<cr>
nn <m-l> <cmd>SidewaysRight<cr>
"snips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
"undotree
nn <leader>u <cmd>UndotreeToggle<cr>
"lsp mappings
if exists('g:loaded_lsp')
  nn <leader>a <cmd>LspCodeAction<cr>
  nn <leader>d <cmd>LspDiag next<cr>
  nn <leader>D <cmd>LspDiag prev<cr>
  nn <leader>ss <cmd>LspDiagShow<cr>
  nn <leader>gd <cmd>LspGotoDeclaration<cr>
  nn <leader>gg <cmd>LspGotoDefinition<cr>
  nn <leader>gi <cmd>LspGotoImpl<cr>
  nn <leader>gt <cmd>LspGotoTypedef<cr>
  nn <leader>k <cmd>LspHover<cr>
  nn <leader>lr <cmd>LspRename<cr>
  nn <leader>p <cmd>LspSwitchSourceHeader<cr>
endif
