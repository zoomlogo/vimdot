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
call LspAddServer([#{name: 'rustanalyzer',
    \ filetype: ['rust'],
    \ path: 'rust-analyzer',
    \ args: [],
    \ syncInit: v:true
    \ }])
