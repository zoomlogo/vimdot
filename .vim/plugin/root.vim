vim9script
# Root: Minimal port of https://github.com/airblade/vim-rooter in vim9script.


g:root_cmd = get(g:, 'root_cmd', 'tcd')
g:root_patterns = get(g:, 'root_patterns', ['.git', '.gitignore', 'CMakeLists.txt', 'Cargo.toml', 'pyproject.toml'])

# load local vimrc
const trust_file = expand('~/.vim/trusted_configs')
const untrust_file = expand('~/.vim/untrusted_configs')

def IsTrusted(path: string): bool
    if !filereadable(trust_file) | return false | endif
    return index(readfile(trust_file), path) != -1
enddef

def IsNotTrusted(path: string): bool
    if !filereadable(untrust_file) | return false | endif
    return index(readfile(untrust_file), path) != -1
enddef

def TrustPath(path: string)
    var trusted = filereadable(trust_file) ? readfile(trust_file) : []
    if index(trusted, path) == -1
        add(trusted, path)
        writefile(trusted, trust_file)
    endif
enddef

def DontTrustPath(path: string)
    var untrusted = filereadable(untrust_file) ? readfile(untrust_file) : []
    if index(untrusted, path) == -1
        add(untrusted, path)
        writefile(untrusted, untrust_file)
    endif
enddef

def LocalLVimrc(root: string)
    var confpath = simplify(root .. '/.vimrc')
    if !filereadable(confpath) | return | endif
    if IsNotTrusted(confpath) | return | endif

    if IsTrusted(confpath)
        execute 'source ' .. fnameescape(confpath)
        return
    endif

    var msg = 'Found local config: ' .. confpath .. '. Load it?'
    var choice = confirm(msg, "&1. Always \n &2. Never \n &3. Yes \n &4. No", 4)

    if choice == 1
        TrustPath(confpath)
        execute 'source ' .. fnameescape(confpath)
    elseif choice == 2
        DontTrustPath(confpath)
    elseif choice == 3
        execute 'source ' .. fnameescape(confpath)
    endif
enddef

# rooter:
def FindRoot(): string
    if &buftype != '' | return '' | endif

    var cwd = expand('%:p:h')
    if cwd =~ '^\w\+://' || cwd =~# '/notes' | return '' | endif
    if cwd == '' | return '' | endif

    var root = ''
    for pattern in g:root_patterns
        var found = finddir(pattern, cwd .. ';')
        if found == ''
            found = findfile(pattern, cwd .. ';')
        endif

        if found != ''
            root = fnamemodify(found, ':p:h:h')
            break
        endif
    endfor

    return root
enddef

def Root()
    var root = FindRoot()
    var ccwd = getcwd()

    if g:root_cmd == 'lcd'
        ccwd = getcwd(0, 0)
    elseif g:root_cmd == 'tcd'
        ccwd = getcwd(0, 2)
    endif

    if root != '' && root != ccwd
        execute g:root_cmd .. ' ' .. fnameescape(root)
        LocalLVimrc(root)
    endif
enddef

augroup Rooter
    autocmd!
    autocmd BufReadPost,TabEnter * Root()
augroup END

command! Root Root()
