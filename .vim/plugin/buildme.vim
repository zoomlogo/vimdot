vim9script
# BuildMe: Easily build and run projects/files.
# The two commands it offers read the execution command from either 3 things
# (in order):
# - user defined command (g:bm_..._cmd)
# - project command (using files as markers)
# - filetype command (for scripts)
#
# Provides two commands:
# :BuildMe <opt:cmd> -> Builds the project and if the build errors, it pipes
#   the output into vim's quickfix list.
# :RunMe <opt:cmd> -> Runs the command in a terminal window.


# add rules (top gets priority)
# project build rules (file, cmd if file exists)
g:bm_build_cmd = get(g:, 'bm_build_cmd', '')

const project_build_rules = [
    ['build.sh', './build.sh'],
    ['Makefile', 'make -j8'],
    ['makefile', 'make -j8'],
    ['build.ninja', 'ninja'],
    ['Cargo.toml', 'cargo build'],
    # cmake handled in GetBuildCommand
]

# single file build rules
# script rules (filetype, command)
const script_build_rules = [
    ['c', 'gcc {} -Wall -Wextra -O3 -lm -std=gnu23 -march=native'],
    ['cpp', 'g++ {} -Wall -Wextra -O3 -lm -std=gnu++23 -march=native'],
]

# project run rules
g:bm_run_cmd = get(g:, 'bm_run_cmd', '')

const project_run_rules = [
    ['a.out', './a.out'],
    ['main.py', 'python -u main.py'],
]

const script_run_rules = [
    ['python', 'python -u {}'],
    ['k', '~/k/k {}'],
]

# internal state
var build_job_ref: job = null_job
var build_job_output: list<string> = []
var building_script: bool = false

var run_termid: number = -1
var running_script: bool = false

# exports
export def BuildMe(incmd: string = '')
    var cmd = incmd
    if cmd == '' | cmd = GetBuildCommand() | endif

    if cmd == ''
        echo '[BuildMe] Nothing to build.'
        return
    endif

    if building_script
        var fp = expand('%:p')
        cmd = substitute(cmd, '{}', shellescape(fp), 'g')
    endif

    if job_status(build_job_ref) == 'run'
        job_stop(build_job_ref)
    endif

    build_job_output = []
    redraw

    var scmd = [&shell, &shellcmdflag, cmd]

    echo '[BuildMe] Building...'
    build_job_ref = job_start(scmd, {
        out_cb: OnOutputBuild,
        err_cb: OnOutputBuild,
        exit_cb: OnExitBuild,
        out_mode: 'nl'
    })
enddef

export def RunMe(incmd: string = '')
    var cmd = incmd
    if cmd == '' | cmd = GetRunCommand() | endif

    if cmd == ''
        echo '[BuildMe] Nothing to run.'
        return
    endif

    if running_script
        var fp = expand('%:p')
        cmd = substitute(cmd, '{}', shellescape(fp), 'g')
    endif

    # make buffer
    if bufexists(run_termid)
        var job = term_getjob(run_termid)
        if job_status(job) == 'run'
            job_stop(job)
        endif
        
        execute 'bwipeout! ' .. run_termid
    endif

    var options = {
        curwin: 1,
        term_name: 'RunMe',
        exit_cb: OnExitRun,
        term_finish: 'open',
        term_kill: 'kill',
    }
    botright new

    redraw
    var scmd = [&shell, &shellcmdflag, cmd]
    echo '[BuildMe] Running...'
    run_termid = term_start(scmd, options)
    wincmd p
enddef

# build me internals
def OnOutputBuild(ch: channel, msg: string)
    add(build_job_output, msg)
enddef

def OnExitBuild(j: job, status: number)
    setqflist([], 'r', {title: ' Build Output ', lines: build_job_output})
    redraw

    if status == 0 | echo '[BuildMe] Successful.'
    else
        echohl ErrorMsg | echo '[BuildMe:' .. status .. '] Failed!' | echohl None
        botright copen 10 | wincmd p
    endif
enddef

def GetBuildCommand(): string
    building_script = false

    if g:bm_build_cmd != '' | return g:bm_build_cmd | endif

    if filereadable('CMakeLists.txt')
        if isdirectory('build') | return 'cmake --build build'
        else
            return 'cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug && cmake --build build'
        endif
    endif

    for rule in project_build_rules
        if filereadable(rule[0]) | return rule[1] | endif
    endfor

    for rule in script_build_rules
        if &filetype == rule[0]
            building_script = true
            return rule[1]
        endif
    endfor

    return ''
enddef

# runme internals
def OnExitRunPost(msg: string)
    setbufvar(run_termid, '&modifiable', 1)
    if bufexists(run_termid)
        appendbufline(run_termid, '$', msg)
        var winid = bufwinid(run_termid)
        if winid != -1
            win_execute(winid, 'normal! G')
        endif
    endif
    setbufvar(run_termid, '&buftype', 'nofile')
    setbufvar(run_termid, '&bufhidden', 'wipe')
    setbufvar(run_termid, '&swapfile', 0)
    setbufvar(run_termid, '&modified', 0)
enddef

def OnExitRun(j: job, status: number)
    var msg = (status == 0) ? 'Finished' : 'Failed with exit code ' .. status
    timer_start(10, (timer) => OnExitRunPost('----- [' .. msg .. '] -----'))

    redraw
    echo '[BuildMe] Run: ' .. msg
enddef

def GetRunCommand(): string
    running_script = false

    if g:bm_run_cmd != '' | return g:bm_run_cmd | endif

    for rule in project_run_rules
        if filereadable(rule[0]) | return rule[1] | endif
    endfor

    for rule in script_run_rules
        if &filetype == rule[0]
            running_script = true
            return rule[1]
        endif
    endfor

    return ''
enddef

command! -nargs=? -complete=shellcmdline BuildMe BuildMe(<f-args>)
command! -nargs=? -complete=shellcmdline RunMe RunMe(<f-args>)
