vim9script

# add rules (top gets priority)
# project build rules (file, cmd if file exists)
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
if !exists('g:bm_project_run_cmd')
    # this is local to project, do not set in ~/.vimrc
    # set it in <project>/.vimrc (`set secure exrc`)
    g:bm_project_run_cmd = ''
endif

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

var run_job_ref: job = null_job
var run_output_buf: string = 'RunMe'
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
    if cmd == '' | cmd = g:bm_project_run_cmd | endif
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
    var winid = bufwinid(run_output_buf)
    if winid == -1
        if bufnr(run_output_buf) != -1 | execute 'bwipeout! ' .. bufnr(run_output_buf) | endif

        botright new
        try | execute 'file ' .. run_output_buf | catch | endtry

        setlocal buftype=nofile bufhidden=wipe noswapfile nonumber norelativenumber signcolumn=no
        wincmd p
    else
        deletebufline(run_output_buf, 1, '$')
    endif

    if job_status(run_job_ref) == 'run'
        job_stop(run_job_ref)
    endif

    redraw
    var scmd = [&shell, &shellcmdflag, cmd]

    echo '[BuildMe] Running...'
    run_job_ref = job_start(scmd, {
        out_cb: OnOutputRun,
        err_cb: OnOutputRun,
        exit_cb: OnExitRun,
        out_mode: 'nl'
    })
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
def LogRunBuffer(msg: string)
    var bufnum = bufnr(run_output_buf)
    if bufnum != -1
        if line('$', bufwinid(bufnum)) == 1 && getbufline(bufnum, 1)[0] == ''
            setbufline(bufnum, 1, msg)
        else
            appendbufline(bufnum, '$', msg)
        endif
        var winid = bufwinid(bufnum)
        if winid != -1 | win_execute(winid, 'normal! G') | endif
    endif
enddef

def OnOutputRun(ch: channel, msg: string)
    LogRunBuffer(msg)
enddef

def OnExitRun(j: job, status: number)
    var msg = (status == 0) ? 'Finished' : 'Failed with exit code ' .. status
    LogRunBuffer('----- [' .. msg .. '] -----')

    redraw
    echo '[BuildMe] Run: ' .. msg
enddef

def GetRunCommand(): string
    running_script = false

    if g:bm_project_run_cmd != '' | return g:bm_project_run_cmd | endif

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
