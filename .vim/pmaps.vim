"plugin maps
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
