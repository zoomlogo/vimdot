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
