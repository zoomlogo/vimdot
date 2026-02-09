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

    setline(1, 'vim9script')
    append(1, '# Ivy: Vim9Script scratchpad. Inspired by *scratch* buffer in emacs.')
    append(2, '')
    cursor(3, 1)

    setlocal buftype=nofile bufhidden=hide noswapfile filetype=vim nomodified

    nnoremap <buffer> <CR> <ScriptCmd>RunLine()<CR>
    nnoremap <buffer> <C-e> vip<Esc><ScriptCmd>RunBlock()<CR>
    vnoremap <buffer> <C-e> <Esc><ScriptCmd>RunBlock()<CR>
enddef

# run line/block commands
def RunLine()
    var line = getline('.')
    if trim(line) == '' | return | endif

    try
        var output = execute(line)
        if output != ''
            var result = split(trim(output), '\n')
            append(line('.'), result)
            cursor(line('.') + len(result), 1)
        endif
    catch
        echohl ErrorMsg | echo v:exception | echohl None
    endtry
enddef

def RunBlock()
    var start = getpos("'<")[1]
    var end = getpos("'>")[1]

    # Get the lines
    var lines = getline(start, end)

    try
        var code = join(lines, "\n")
        var output = execute(code)

        if output != ''
            var result = split(trim(output), '\n')
            append(line('.'), result)
            cursor(line('.') + len(result), 1)
        endif
    catch
        echohl ErrorMsg | echo v:exception | echohl None
    endtry
enddef

# :Ivy
command! Ivy call IvyBuffer()
