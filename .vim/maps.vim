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
im <c-h> <left>
im <c-j> <down>
im <c-k> <up>
im <c-l> <right>
"file specific maps:
au filetype python nn <cr> :up<cr>:!clear && python %<cr>
au filetype k nn <cr> :up<cr>:!clear && ~/k/k %<cr>
au filetype c nn <cr> :up<cr>:!clear && gcc % -Wall -Wextra -O2 -std=c17 && ./a.out<cr>
au filetype cpp nn <cr> :up<cr>:!clear && g++ % -Wall -Wextra -O2 -std=c++20 && ./a.out<cr>
au filetype tex nn <cr> :up<cr>:!clear && pdflatex % && pdfmv %:t:r.pdf<cr>
au bufnew,bufnewfile,bufread *.flx nn <cr> :up<cr>:!flax f %<cr>
au filetype make se noet
au filetype tex se ts=2 sw=2 isk+=:
"c/c++ source/header swapping
if !get(g:, 'loaded_lsp', false)
    " LspSwitchSourceHeader replaces this
    au bufnew,bufenter *.cpp nn <leader>p :e %<.hpp<cr>
    au bufnew,bufenter *.hpp nn <leader>p :e %<.cpp<cr>
    au bufnew,bufenter *.c nn <leader>p :e %<.h<cr>
    au bufnew,bufenter *.h nn <leader>p :e %<.c<cr>
endif
"fzf+rg
nm <leader>r <cmd>Rg<cr>
nm <c-f> <cmd>Files<cr>
