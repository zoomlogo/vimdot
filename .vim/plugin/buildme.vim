vim9script

# add rules (top gets priority)
var project_rules = [
    ['build.sh', './build.sh'],
    ['Makefile', 'make -j8'],
    ['makefile', 'make -j8'],
    ['build.ninja', 'ninja'],
    ['Cargo.toml', 'cargo build'],
]

# script rules, (filetype, command)
var script_rules = [
    ['python', 'python {}'],
    ['k', '~/k/k {}'],
    ['c', 'gcc {} -Wall -Wextra -O3 -lm -std=gnu23 && ./a.out'],
    ['cpp', 'g++ {} -Wall -Wextra -O3 -lm -std=gnu++23 && ./a.out'],
]

var job_ref: job
var job_output: list<string> = []
var running_script: bool = false

export def BuildMe()
    var cmd = GetCommand()
    if cmd == '' | return | endif
    if running_script
        var fp = expand('%:p')
        cmd = substitute(cmd, '{}', fp, 'g')
    endif

    if job_status(job_ref) == 'run'
        job_stop(job_ref)
    endif

    job_output = []
    redraw

    var scmd = [&shell, &shellcmdflag, cmd]

    echo '[BuildMe] Building...'
    job_ref = job_start(scmd, {
        out_cb: OnOutput,
        err_cb: OnOutput,
        exit_cb: OnExit,
        out_mode: 'nl'
    })
enddef

def OnOutput(ch: channel, msg: string)
    add(job_output, msg)
enddef

def GetCommand(): string
    if filereadable('CMakeLists.txt')
        if isdirectory('build') | return 'cmake --build build'
        else
            return 'cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug && cmake --build build'
        endif
    endif

    for rule in project_rules
        if filereadable(rule[0]) | return rule[1] | endif
    endfor

    for rule in script_rules
        if &filetype == rule[0]
            running_script = true
            return rule[1]
        endif
    endfor

    return ''
enddef

def OnExit(j: job, status: number)
    setqflist([], 'r', {title: ' Build Output ', lines: job_output})
    redraw

    if status == 0 | echo '[BuildMe] Successfully built project.'
    else
        echohl ErrorMsg | echo '[BuildMe:' .. status .. '] Failed!' | echohl None
        botright copen 10 | wincmd p
    endif
enddef

command! BuildMe call BuildMe()
