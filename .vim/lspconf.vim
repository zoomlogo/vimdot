pa lsp
call LspAddServer([#{
    \ name: 'clangd',
    \ filetype: ['c', 'cpp'],
    \ path: 'clangd',
    \ args: ['--background-index'],
    \ }])
