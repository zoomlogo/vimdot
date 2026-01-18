vim9script
var ls_cmd = 'ls -laF --group-directories-first'
var fname_regex = '^\%(\s*\S\+\s\+\)\{8}\zs.*'

# track
sign define ViredTracker text=> texthl=Comment

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

# maps
def NormalMappings()
    nnoremap <buffer><nowait> <CR> <ScriptCmd>Enter()<CR>
    nnoremap <buffer><nowait> U <ScriptCmd>GoUp()<CR>
    nnoremap <buffer><nowait> q <Cmd>bd<CR>
    nnoremap <buffer><nowait> d <ScriptCmd>Delete()<CR>
    nnoremap <buffer><nowait> r <ScriptCmd>Rename()<CR>
    nnoremap <buffer><nowait> o <ScriptCmd>New()<CR>

    nnoremap <buffer><nowait> a <ScriptCmd>EditMode()<CR>
    nnoremap <buffer><nowait> i <ScriptCmd>EditMode()<CR>

    nnoremap <buffer><nowait> j <ScriptCmd>MoveCursor(1)<CR>
    nnoremap <buffer><nowait> k <ScriptCmd>MoveCursor(-1)<CR>
enddef

def EditMappings()
    nnoremap <buffer><nowait> cc <scriptcmd>Commit()<CR>
    nnoremap <buffer><nowait> q <scriptcmd>Render()<CR>

    silent! nunmap <buffer> <CR>
    silent! nunmap <buffer> U
    silent! nunmap <buffer> d
    silent! nunmap <buffer> r
    silent! nunmap <buffer> o

    silent! nunmap <buffer> a
    silent! nunmap <buffer> i

    silent! nunmap <buffer> j
    silent! nunmap <buffer> k
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

def MoveCursor(dir: number)
    if dir == 1
        execute 'normal! ' .. v:count1 .. 'j'
    elseif dir == -1
        execute 'normal! ' .. v:count1 .. 'k'
    endif

    var col = match(getline('.'), fname_regex)
    if col != -1
        cursor(line('.'), col + 1)
    else
        normal! 0
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

    setlocal nomodifiable buftype=nofile bufhidden=wipe
    setlocal noswapfile nonumber filetype=vired nowrap
    &l:statusline = b:cwd
    SetupViredColours()

    sign_unplace('ViredGroup', {'buffer': bufnr()})
    b:emode_map = {}

    MoveCursor(0)
    NormalMappings()
enddef

# edit mode
def EditMode()
    if &modifiable
        echo "in edit mode, press <enter> to commit"
        return
    endif

    b:emode_map = {}
    var id = 1
    var lines = getline(1, '$')

    for i in range(len(lines))
        var name = GetFileName(lines[i])
        if name == '' | continue | endif

        sign_place(id, 'ViredGroup', 'ViredTracker', bufnr(), {lnum: i + 1})
        b:emode_map[id] = name
        id += 1
    endfor

    setlocal modifiable
    EditMappings()
enddef

def Commit()
    var signs = sign_getplaced(bufnr(), {group: 'ViredGroup'})[0].signs
    var map = {}
    for s in signs | map[s.lnum] = s.id | endfor

    var seen = {}
    var lines = getline(1, '$')
    for i in range(len(lines))
        var lnum = i + 1
        if !has_key(map, lnum)
            NewFileOrDir(lines[i])
            continue
        endif

        var id = map[lnum]
        var name = b:emode_map[id]
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
                echoerr "Cannot rename: Destination exists " .. nname
                continue
            endif

            if rename(src, dst) == 0
                echo name .. " -> " .. nname
            else
                echoerr "failed to rename " .. name
            endif
        endif
    endfor

    for idt in keys(b:emode_map)
        var id = str2nr(idt)
        if !has_key(seen, id)
            var name = b:emode_map[idt]
            var fp = b:cwd .. '/' .. name
            if delete(fp, 'rf') == 0
                echo "deleted " .. name
            else
                echoerr "failed to delete " .. name
            endif
        endif
    endfor

    b:emode_map = {}
    Render()
enddef

# file ops
def Delete()
    var name = GetFileName(getline('.'))
    if name == '' || name == '.' || name == '..' | return | endif

    var fp = b:cwd .. '/' .. name
    echo 'delete ' .. name .. '? (y/n): '
    var choice = getcharstr()
    redraw

    if choice == 'y'
        if delete(fp, 'rf') == 0
            echo "deleted " .. name
            Render()
        else
            echoerr "failed to delete " .. name
        endif
    else
        echo "cancelled..."
    endif
enddef

def Rename()
    var name = GetFileName(getline('.'))
    if name == '' || name == '.' || name == '..' | return | endif

    var fp0 = b:cwd .. '/' .. name
    var new_name = input('rename `' .. name .. '` to? ')
    redraw

    if new_name == '' || new_name == name | echo "cancelled..." | return | endif
    var fp1 = b:cwd .. '/' .. new_name

    if rename(fp0, fp1) == 0
        echo "renamed to " .. new_name
        Render()
    else
        echoerr "failed to rename " .. name
    endif
enddef

def New()
    if &modifiable | return | endif
    setlocal modifiable

    normal! o
    augroup ViredCreate
        autocmd!
        autocmd InsertLeave <buffer> ++once MakeNew()
    augroup END

    startinsert!
enddef

def MakeNew()
    var lines = getline(1, '$')

    for line in lines
        if line == '(empty)' | continue | endif
        if match(line, fname_regex) != -1 | continue | endif

        NewFileOrDir(line)
    endfor
    Render()
enddef

# movement
def Enter()
    var name = GetFileName(getline('.'))

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

def OpenVired()
    enew
    b:cwd = getcwd()
    Render()
enddef

command! Vired OpenVired()
