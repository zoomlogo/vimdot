" language servers
call LspAddServer([#{
    \ name: 'clangd',
    \ filetype: ['c', 'cpp'],
    \ path: 'clangd',
    \ args: ['--background-index'],
    \ }])
call LspAddServer([#{name: 'pylsp',
    \ filetype: 'python',
    \ path: 'pylsp',
    \ args: []
    \ }])
"lsp mappings
nm <c-a> <cmd>LspCodeAction<cr>
nm <leader>d <cmd>LspDiag next<cr>
nm <leader>D <cmd>LspDiag prev<cr>
nm <leader>gd <cmd>LspGotoDeclaration<cr>
nm <leader>gg <cmd>LspGotoDefinition<cr>
nm <leader>gi <cmd>LspGotoImpl<cr>
nm <leader>gt <cmd>LspGotoTypedef<cr>
nm <leader>k <cmd>LspHover<cr>
nm <leader>lr <cmd>LspRename<cr>
nm <leader>p <cmd>LspSwitchSourceHeader<cr>
