vim9script
# Ivy: Vim9Script scratchpad.
# Inspired by the *scratch* buffer / IEML in emacs.
#
# Provides a single command:
# :Ivy -> Opens the scratchpad in a split buffer towards the left of the
# current window.
#
# The execution output is put into the buffer.
# Buffer specific mappings:
# <CR> -> Runs the current line.
# <C-e> -> Runs the current highlighted block / paragraph.


export def IvyBuffer()
    vnew

    setline(1, ['vim9script', '# Ivy: Vim9Script scratchpad. Inspired by *scratch* buffer in emacs.', ''])
    cursor(3, 1)

    setlocal buftype=nofile bufhidden=hide noswapfile filetype=vim nomodified
    setlocal colorcolumn=0 textwidth=0

    nnoremap <buffer> <CR> <ScriptCmd>Run([trim(getline('.'))])<CR>
    nnoremap <buffer> <C-e> <ScriptCmd>Run(getline("'{", "'}"))<CR>
    vnoremap <buffer> <C-e> <Esc><ScriptCmd>Run(getline(getpos("'<")[1], getpos("'>")[1]))<CR>
enddef

# run
def Run(lines: list<string>)
    try
        if len(lines) == 0 || (len(lines) == 1 && lines[0] == '') | return | endif
        var output = execute(lines)

        if output != ''
            appendbufline(bufnr(), line('.'), trim(output))
        endif
    catch
        echohl ErrorMsg | echo v:exception | echohl None
    endtry
enddef

# :Ivy
command! Ivy call IvyBuffer()
