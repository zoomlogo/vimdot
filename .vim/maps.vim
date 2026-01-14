nm <space> <nop>
let mapleader=" "
nm Q @q
nm <leader>w <cmd>up<cr>
nm <leader>h <cmd>vs<cr>
nm <leader>v <cmd>sp<cr>
nm <leader>t <cmd>tabnew<cr>
nm <leader>n <cmd>tabn<cr>
nm <leader>cd <cmd>cd %/..<cr>
nm <leader>cc <cmd>ChangeColor<cr>
nm D d$
nm Y y$
nm <m-w> viw
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
  " LspSwitchSourceHeader replaces this
  au bufnew,bufenter *.cpp nn <leader>p :e %<.hpp<cr>
  au bufnew,bufenter *.hpp nn <leader>p :e %<.cpp<cr>
  au bufnew,bufenter *.c nn <leader>p :e %<.h<cr>
  au bufnew,bufenter *.h nn <leader>p :e %<.c<cr>
endif
"fzf+rg
nm <leader>r <cmd>Rg<cr>
nm <c-f> <cmd>GFiles --cached --others --exclude-standard<cr>
nm <leader>f <cmd>Files<cr>
"snips
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"
"undotree
nm <leader>u <cmd>UndoTreeToggle<cr>
"lsp mappings
if exists('g:loaded_lsp')
  nm <leader>a <cmd>LspCodeAction<cr>
  nm <leader>d <cmd>LspDiag next<cr>
  nm <leader>D <cmd>LspDiag prev<cr>
  nm <leader>ss <cmd>LspDiagShow<cr>
  nm <leader>gd <cmd>LspGotoDeclaration<cr>
  nm <leader>gg <cmd>LspGotoDefinition<cr>
  nm <leader>gi <cmd>LspGotoImpl<cr>
  nm <leader>gt <cmd>LspGotoTypedef<cr>
  nm <leader>k <cmd>LspHover<cr>
  nm <leader>lr <cmd>LspRename<cr>
  nm <leader>p <cmd>LspSwitchSourceHeader<cr>
endif
