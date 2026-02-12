vim9script
# Vired: Vim Directory Editor.
# Inspired by Emacs' dired.
#
# Provides a single command:
# :Vired <opt:dir> -> Opens directory (or current directory) as a file
#   listing, emulating ls -l --color output.
#
# Vired allows for common file management operations such as renaming,
# moving, copying, deletion and creation of files and directories using
# standard Vim commands. Edit the buffer to perform these operations
# and write the buffer to sync changes with the disk. These operations
# are irreversible, so be careful before saving.
#
# Buffer specific mappings:
# U -> Go up to the parent directory.
# . -> Reload Vired.
# ! -> Run a shell command on the current file.
# yy -> Copy the current file.
# <CR> -> Go inside a directory or open a file (current under cursor).

# track
sign define ViredTracker

if empty(prop_type_get('vired_perm_type'))
    var hlmap = {
        vired_perm_type: 'Structure',
        vired_perm_read: 'String',
        vired_perm_write: 'WarningMsg',
        vired_perm_exec: 'Statement',
        vired_perm_dash: 'Comment',
        vired_sz: 'Number',
        vired_date: 'Directory',
        vired_suffix_dir: 'Directory',
        vired_suffix_exec: 'String',
        vired_suffix_link: 'Constant',
        vired_suffix_link_target: 'Comment',
    }
    for [name, hl] in items(hlmap)
        prop_type_add(name, {highlight: hl, override: true})
    endfor
endif

# setup
export def OpenVired(path: string = '')
    var target = simplify(path == '' ? getcwd() : path)
    setlocal nomodified
    if expand('%') != '' | enew | endif
    b:cwd = target
    Render()
enddef

# emulate ls -la in vim9script
def FormatSize(bytes: number): string
    if bytes < 1024 | return string(bytes) | endif
    var suffix = ['k', 'M', 'G', 'T', 'P']
    var size = bytes * 1.0
    for s in suffix
        size = size / 1024.0
        if size < 1024 | return printf("%.1f%s", size, s) | endif
    endfor
    return printf("%.1fE", size)
enddef

def GetFileList(dir: string): list<string>
    var entries = readdir(dir)
    if empty(entries) | return [] | endif

    var dirs = []
    var files = []
    var ls = []

    for name in entries
        if isdirectory(dir .. '/' .. name)
            add(dirs, name)
        else
            add(files, name)
        endif
    endfor

    sort(dirs, 'i')
    sort(files, 'i')

    for dname in dirs | add(ls, dname) | endfor
    for fname in files | add(ls, fname) | endfor

    return ls
enddef

def LongList(files: list<string>, dir: string)
    for i in range(len(files))
        var line = i + 1
        var len = len(files[i])
        var file = dir .. '/' .. files[i]

        # get file data
        var fptype = '-'
        var suffix = ''
        var target = ''

        if isdirectory(file)
            fptype = 'd'
            suffix = '/'
        elseif getftype(file) == 'link'
            fptype = 'l'
            target = fnamemodify(resolve(file), ":~")
            if target =~ '^//'
                target = target[1 : -1]
            endif
            suffix = '@'
        elseif executable(file)
            suffix = '*'
        endif

        # parse perm
        prop_add(line, 1, {type: fptype == '-' ? 'vired_perm_dash' : 'vired_perm_type', text: fptype})

        var perms = getfperm(file)
        for j in range(3)
            prop_add(line, 1, {type: perms[3 * j] == '-' ? 'vired_perm_dash' : 'vired_perm_read', text: perms[3 * j]})
            prop_add(line, 1, {type: perms[3 * j + 1] == '-' ? 'vired_perm_dash' : 'vired_perm_write', text: perms[3 * j + 1]})
            prop_add(line, 1, {type: perms[3 * j + 2] == '-' ? 'vired_perm_dash' : 'vired_perm_exec', text: perms[3 * j + 2]})
        endfor

        # parse sz
        var sz = fptype == 'd' ? '-' : FormatSize(getfsize(file))
        prop_add(line, 1, {type: 'vired_sz', text: printf("%6s ", sz)})

        # parse date
        var date = strftime("%b %d %H:%M", getftime(file))
        prop_add(line, 1, {type: 'vired_date', text: date .. ' '})

        # parse suffix
        if suffix == '/'      # dir
            prop_add(line, 0, {type: 'vired_suffix_dir', text: suffix})
            prop_add(line, 1, {type: 'vired_suffix_dir', end_col: len + 1})
        elseif suffix == '*'  # exec
            prop_add(line, 0, {type: 'vired_suffix_exec', text: suffix})
            prop_add(line, 1, {type: 'vired_suffix_exec', end_col: len + 1})
        elseif suffix == '@'  # link
            prop_add(line, 0, {type: 'vired_suffix_link', text: suffix})
            prop_add(line, 0, {type: 'vired_suffix_link_target', text: ' -> ' .. target})
            prop_add(line, 1, {type: 'vired_suffix_link', end_col: len + 1})
        endif
    endfor
enddef

# helpers
def NewFileOrDir(line: string)
    var name = trim(line)
    if name == '' | return | endif

    var fp = b:cwd .. '/' .. name

    if !empty(glob(fp)) | return | endif

    var parent = fnamemodify(fp, ':h')
    if !isdirectory(parent)
        mkdir(parent, 'p')
    endif

    if name =~ '/$'
        if !isdirectory(fp)
            mkdir(fp, 'p')
        endif
    else
        if !filereadable(fp)
            writefile([], fp)
        endif
    endif
enddef

def TrackFiles()
    sign_unplace('ViredGroup', {'buffer': bufnr()})
    b:fmap = {}

    var lines = getline(1, '$')
    var batch = []

    for i in range(len(lines))
        var name = lines[i]
        if name == '' | continue | endif

        var line = i + 1

        b:fmap[line] = name
        add(batch, {
            buffer: bufnr(),
            id: line,
            group: 'ViredGroup',
            name: 'ViredTracker',
            lnum: line,
        })
    endfor

    if !empty(batch)
        sign_placelist(batch)
    endif
enddef

# render
def Render()
    setlocal modifiable
    silent! :%delete _

    var files = GetFileList(b:cwd)

    if len(files) != 0
        setline(1, files)
        LongList(files, b:cwd)
    else
        prop_clear(1, line('$'))
    endif

    var bufname = 'vired://' .. b:cwd
    silent! execute 'file ' .. fnameescape(bufname)

    setlocal nomodified buftype=acwrite bufhidden=wipe
    setlocal noswapfile nonumber filetype=vired nowrap
    setlocal colorcolumn=0 textwidth=0
    &l:statusline = b:cwd

    augroup ViredEvents
        autocmd! * <buffer>
        autocmd BufWriteCmd <buffer> Sync()
        autocmd QuitPre <buffer> setlocal nomodified
    augroup END

    nnoremap <buffer><nowait> <CR> <ScriptCmd>Enter()<CR>
    nnoremap <buffer><nowait> U <ScriptCmd>GoUp()<CR>
    nnoremap <buffer><nowait> ! <ScriptCmd>ShellCommand()<CR>
    nnoremap <buffer><nowait> . <ScriptCmd>Render()<CR>
    nnoremap <buffer><nowait> yy <ScriptCmd>Copy()<CR>

    TrackFiles()
enddef

# sync on write
def Sync()
    var signs = sign_getplaced(bufnr(), {group: 'ViredGroup'})[0].signs
    var map = {}
    var seen = {}
    for s in signs | map[s.lnum] = s.id | endfor

    var lines = getline(1, '$')
    for i in range(len(lines))
        var lnum = i + 1
        if !has_key(map, lnum)
            NewFileOrDir(lines[i])
            continue
        endif

        var id = map[lnum]
        var name = b:fmap[id]
        var nname = lines[i]

        seen[id] = true
        if nname == ''
            var fp = b:cwd .. '/' .. name
            if delete(fp, 'rf') == 0
                echo "deleted " .. name
            else
                echoerr "failed to delete " .. name
            endif
            continue
        endif

        if nname != name
            var src = b:cwd .. '/' .. name
            var dst = b:cwd .. '/' .. nname
            if !empty(glob(dst))
                echoerr "failed to rename " .. name
                continue
            endif

            var dparent = fnamemodify(dst, ':h')
            if !isdirectory(dparent)
                mkdir(dparent, 'p')
            endif

            if rename(src, dst) == 0
                echo name .. " -> " .. nname
            else
                echoerr "failed to rename " .. name
            endif
        endif
    endfor

    for idt in keys(b:fmap)
        var id = str2nr(idt)
        if !has_key(seen, id)
            var name = b:fmap[idt]
            var fp = b:cwd .. '/' .. name
            if delete(fp, 'rf') == 0
                echo "deleted " .. name
            else
                echoerr "failed to delete " .. name
            endif
        endif
    endfor

    Render()
enddef

# movement
def Enter()
    var name = getline('.')
    setlocal nomodified

    if name == '.'
        return
    elseif name == '..'
        GoUp()
        return
    endif

    var fp = b:cwd .. '/' .. name
    if isdirectory(fp)
        b:cwd = fp
        Render()
    else
        execute 'edit ' .. fnameescape(fp)
    endif
enddef

def Copy()
    if &modified | echoerr 'save first' | return | endif

    var name = getline('.')
    if name == '' || name == '.' || name == '..' | return | endif

    var src = b:cwd .. '/' .. name
    var target = input('copy to: ', name, 'file') | redraw
    if target == '' || target == name | return | endif

    var dst = (target =~ '^/') ? target : b:cwd .. '/' .. target
    var cmd = 'cp -r ' .. shellescape(src) .. ' ' .. shellescape(dst)
    system(cmd)

    if v:shell_error
        echoerr 'copy failed'
    else
        echo 'copied: ' .. name .. ' -> ' .. target
        Render()
    endif
enddef

def GoUp()
    b:cwd = fnamemodify(b:cwd, ':h')
    Render()
enddef

def ShellCommand()
    var name = getline('.')
    if name == '.' || name == '..' || name == '' | echo "select valid file..." | return | endif

    var fp = fnameescape(b:cwd .. '/' .. name)
    var cmd = input('! ', '', 'shellcmd')
    redraw
    if cmd == '' | return | endif

    var rcmd = (stridx(cmd, '{}') != -1) ? substitute(cmd, '{}', fp, 'g') : cmd .. ' ' .. fp
    execute 'botright terminal ' .. rcmd
enddef

command! -nargs=? -complete=dir Vired OpenVired(<f-args>)
