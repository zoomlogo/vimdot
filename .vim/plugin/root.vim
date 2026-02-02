vim9script

if !exists('g:root_cmd')
    g:root_cmd = 'tcd'
endif

if !exists('g:root_patterns')
    g:root_patterns = ['.git', '.gitignore', 'CMakeLists.txt', 'Cargo.toml', 'pyproject.toml']
endif

def FindRoot(): string
    if &buftype != '' | return '' | endif

    var cwd = expand('%:p:h')
    if cwd =~ '^\w\+://' | return '' | endif
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
    endif
enddef

augroup Rooter
    autocmd!
    autocmd BufEnter * Root()
augroup END

command! Root call Root()
