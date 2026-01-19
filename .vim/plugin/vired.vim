vim9script

import './vimage.vim'

var ls_cmd = 'ls -laF --group-directories-first --color=never'
var fname_regex = '^\%(\s*\S\+\s\+\)\{8}\zs.*'

# track
sign define ViredTracker

# setup
export def OpenVired()
    setlocal nomodified
    enew
    b:cwd = getcwd()
    Render()
enddef

# colour
def SetupViredColours()
    syn match ViredPerms "^[drwxlst-][rwx-]*" contains=ViredType,ViredRead,ViredWrite,ViredExec,ViredDash nextgroup=ViredLinks skipwhite

    syn match ViredType  "d" contained nextgroup=ViredRead
    syn match ViredType  "l" contained nextgroup=ViredRead
    syn match ViredRead  "r" contained nextgroup=ViredWrite
    syn match ViredWrite "w" contained nextgroup=ViredExec
    syn match ViredExec  "x" contained nextgroup=ViredRead
    syn match ViredDash  "-" contained

    syn match ViredLinks "\s*\d\+" contained nextgroup=ViredUser skipwhite

    syn match ViredUser  "\S\+" contained nextgroup=ViredGroup skipwhite
    syn match ViredGroup "\S\+" contained nextgroup=ViredSize skipwhite

    syn match ViredSize  "\s*\d\+\%(\.\d\+\)\?[kMGTPEZY]\?" contained nextgroup=ViredDate skipwhite

    syn match ViredDate  "\s*\S\+\s\+\d\+\s\+\%(\d\+:\d\+\|\d\{4\}\)" contained

    syn match ViredNameDir  "\s\zs[^/]\+/$"
    syn match ViredNameExec "\s\zs[^*]\+\*$"
    syn match ViredNameLink "\s\zs[^@]\+@\ze"
    syn match ViredLinkTarget "->.*$"

    hi def link ViredType Structure
    hi def link ViredRead String
    hi def link ViredWrite Error
    hi def link ViredExec Statement
    hi def link ViredDash Comment

    hi def link ViredLinks Number
    hi def link ViredUser Type
    hi def link ViredGroup Type
    hi def link ViredSize Number
    hi def link ViredDate Directory

    hi def link ViredNameDir Directory
    hi def link ViredNameExec String
    hi def link ViredNameLink Constant
    hi def link ViredLinkTarget Comment
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

    var files = systemlist(ls_cmd .. ' ' .. shellescape(b:cwd))
    if len(files) > 0 && files[0] =~ '^total \d\+'
        files = files[1 : -1]
    endif

    if len(files) == 0
        files = ["(empty)"]
    endif
    setline(1, files)

    var bufname = 'vired://' .. b:cwd
    silent! execute 'file ' .. fnameescape(bufname)

    setlocal modified buftype=acwrite bufhidden=wipe
    setlocal noswapfile nonumber filetype=vired nowrap
    &l:statusline = b:cwd
    SetupViredColours()

    augroup ViredEvents
        autocmd! * <buffer>
        autocmd BufWriteCmd <buffer> Sync()
        autocmd CursorMoved,CursorMovedI <buffer> LockCursor()
    augroup END

    nnoremap <buffer><nowait> <CR> <ScriptCmd>Enter()<CR>
    nnoremap <buffer><nowait> U <ScriptCmd>GoUp()<CR>
    nnoremap <buffer><nowait> q <Cmd>setlocal nomodified<CR><Cmd>bdelete<CR>

    cursor(3, 0)
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

def GoUp()
    b:cwd = fnamemodify(b:cwd, ':h')
    Render()
enddef

command! Vired OpenVired()
