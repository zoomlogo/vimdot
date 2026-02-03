vim9script

var fname_regex = '^\%(\s*\S\+\s\+\)\{5}\zs.*'

# track
sign define ViredTracker

# setup
export def OpenVired(path: string = '')
    var target = path == '' ? getcwd() : path
    target = fnamemodify(target, ':p')
    if target[-1] == '/' | target = target[0 : -2] | endif
    setlocal nomodified
    enew
    b:cwd = target
    Render()
enddef

# colour
def SetupViredColours()
    syn match ViredPerms "^[drwxlst-][rwx-]*" contains=ViredType,ViredRead,ViredWrite,ViredExec,ViredDash nextgroup=ViredSize skipwhite
    syn match ViredType  "d" contained nextgroup=ViredRead
    syn match ViredType  "l" contained nextgroup=ViredRead
    syn match ViredRead  "r" contained nextgroup=ViredWrite
    syn match ViredWrite "w" contained nextgroup=ViredExec
    syn match ViredExec  "x" contained nextgroup=ViredRead
    syn match ViredDash  "-" contained

    syn match ViredSize  "\s*\d\+\%(\.\d\+\)\?[kMGTPEZY]\?" contained nextgroup=ViredDate skipwhite
    syn match ViredDate  "\s*\S\+\s\+\d\+\s\+\%(\d\+:\d\+\|\d\{4\}\)" contained

    syn match ViredNameDir  "\s\zs[^/]\+/$"
    syn match ViredNameExec "\s\zs[^*]\+\*$"
    syn match ViredNameLink "\s\zs[^@]\+@\ze"
    syn match ViredLinkTarget "->.*$"

    hi def link ViredType Structure
    hi def link ViredRead String
    hi def link ViredWrite WarningMsg
    hi def link ViredExec Statement
    hi def link ViredDash Comment

    hi def link ViredSize Number
    hi def link ViredDate Directory

    hi def link ViredNameDir Directory
    hi def link ViredNameExec String
    hi def link ViredNameLink Constant
    hi def link ViredLinkTarget Comment
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

def FormatLine(dir: string, name: string): string
    var fp = dir .. '/' .. name
    var suffix = ''
    var fptype = '-'

    if isdirectory(fp)
        fptype = 'd'
        suffix = '/'
    elseif getftype(fp) == 'link'
        fptype = 'l'
        var target = fnamemodify(resolve(fp), ":~")
        if target =~ '^//' | target = target[1 : -1] | endif
        suffix = '@ -> ' .. target
    elseif executable(fp)
        suffix = '*'
    endif

    var perm = fptype .. getfperm(fp)
    var sz = fptype == 'd' ? '-' : FormatSize(getfsize(fp))
    var date = strftime("%b %d %H:%M", getftime(fp))

    return printf("%s %6s %s %s%s", perm, sz, date, name, suffix)
enddef

def GetFileList(dir: string): list<string>
    var entries = readdir(dir)
    if empty(entries) | return ["(empty)"] | endif

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

    for dname in dirs | add(ls, FormatLine(dir, dname)) | endfor
    for fname in files | add(ls, FormatLine(dir, fname)) | endfor

    return ls
enddef

# helpers
def GetFileName(line: string): string
    if line == '' || line == '(empty)' | return '' | endif

    var raw = matchstr(line, fname_regex)
    var name = substitute(raw, ' -> .*$', '', '')

    if name[-1 : -1] =~ '[/*@=|]'
        name = name[0 : -2]
    endif

    return name
enddef

def LockCursor()
    var line = getline('.')
    var col = match(getline('.'), fname_regex)
    if col == -1 | return | endif

    if col('.') < col + 1
        cursor(line('.'), col + 1)
    endif
enddef

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
    var id = 1
    var lines = getline(1, '$')

    for i in range(len(lines))
        var name = GetFileName(lines[i])
        if name == '' | continue | endif

        sign_place(id, 'ViredGroup', 'ViredTracker', bufnr(), {lnum: i + 1})
        b:fmap[id] = name
        id += 1
    endfor
enddef

# render
def Render()
    setlocal modifiable
    silent! :%delete _

    var files = GetFileList(b:cwd)

    if len(files) == 0
        files = ["(empty)"]
    endif
    setline(1, files)

    var bufname = 'vired://' .. b:cwd
    silent! execute 'file ' .. fnameescape(bufname)

    setlocal nomodified buftype=acwrite bufhidden=wipe
    setlocal noswapfile nonumber filetype=vired nowrap
    &l:statusline = b:cwd
    SetupViredColours()

    augroup ViredEvents
        autocmd! * <buffer>
        autocmd BufWriteCmd <buffer> Sync()
        autocmd CursorMoved,CursorMovedI <buffer> LockCursor()
        autocmd QuitPre <buffer> setlocal nomodified
    augroup END

    nnoremap <buffer><nowait> <CR> <ScriptCmd>Enter()<CR>
    nnoremap <buffer><nowait> U <ScriptCmd>GoUp()<CR>
    nnoremap <buffer><nowait> ! <ScriptCmd>ShellCommand()<CR>
    nnoremap <buffer><nowait> . <ScriptCmd>Render()<CR>
    nnoremap <buffer><nowait> yy <ScriptCmd>Copy()<CR>

    LockCursor()
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
        var nname = GetFileName(lines[i])

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
    var name = GetFileName(getline('.'))
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

    var name = GetFileName(getline('.'))
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
    var name = GetFileName(getline('.'))
    if name == '.' || name == '..' || name == '' | echo "select valid file..." | return | endif

    var fp = fnameescape(b:cwd .. '/' .. name)
    var cmd = input('! ', '', 'shellcmd')
    redraw
    if cmd == '' | return | endif

    var rcmd = (stridx(cmd, '{}') != -1) ? substitute(cmd, '{}', fp, 'g') : cmd .. ' ' .. fp
    execute 'botright terminal ' .. rcmd
enddef

command! -nargs=? -complete=dir Vired OpenVired(<f-args>)
