vim9script
# add servers here:
var servers = [
    {name: 'clangd', cmd: 'clangd', ft: ['c', 'cpp'], args: ['--background-index', '--header-insertion=never']},
    {name: 'pylsp', cmd: 'pylsp', ft: 'python', args: []},
    {name: 'rustanalyzer', cmd: 'rust-analyzer', ft: 'rust', args: [], syncInit: true},
    {name: 'svls', cmd: 'svls', ft: 'systemverilog', args: []},
]

for server in servers
    if executable(server.cmd)
        call LspAddServer([{
            name: server.name,
            filetype: server.ft,
            path: server.cmd,
            args: server.args,
            syncInit: get(server, 'syncInit', false)
        }])
    endif
endfor
