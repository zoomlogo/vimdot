vim9script
# Notes: Note taking plugin for Vim.
# Depends on fzf.vim
#
# Has a single option:
# g:notes_global_directory -> Tells the plugin where to store ALL notes.
#
# Provides three commands:
# :Daily -> Opens the daily note in the daily/ directory.
# :Notes -> Opens the notes index.
# :SearchNotes -> Uses fzf to search through the notes.
#
# Buffer specific mappings:
# <CR> -> Follow link. Links are defined by [[link]]. New file is created if
#   required.
# <BS> -> Uses fzf to search through notes showing those which link to the
#   current note.

g:notes_global_directory = get(g:, 'notes_global_directory', expand('~/notes'))
const note_extension = '.note'

def FollowLink()
    var line = getline('.')
    var col = col('.')

    # find [[link]]
    var link = ''
    var index = 0
    while true
        var match = matchstrpos(line, '\[\[.\{-1,}\]\]', index)
        if match[1] == -1 | break | endif

        if col >= (match[1] + 1) && col <= match[2]
            link = trim(match[0][2 : -3])
            break
        endif

        index = match[2]
    endwhile
    if link == '' | return | endif

    # make subdirectories:
    var target_file = g:notes_global_directory .. '/' .. link .. note_extension
    var parents = fnamemodify(target_file, ':h')
    if !isdirectory(parents)
        mkdir(parents, 'p')
        redraw | echo "[Notes] Created directories: " .. parents
    endif

    # update current buffer and goto [[link]]
    update
    execute 'edit ' .. fnameescape(target_file)
enddef

def WhatLinksHere()
    if !exists('*fzf#vim#grep')
        echoerr 'Requires fzf.vim'
        return
    endif

    var note = fnamemodify(strpart(expand('%:p'), len(g:notes_global_directory) + 1), ':r')
    var pattern = '[[' .. note .. ']]'

    var cmd = 'rg --column --line-number --no-heading --color=always --smart-case -F ' .. shellescape(pattern) .. ' ' ..  shellescape(g:notes_global_directory) .. ' || true'
    var spec = fzf#vim#with_preview({'options': ['--prompt', 'Backlinks> ']})

    fzf#vim#grep(cmd, 1, spec, 0)
enddef

def OpenDaily()
    var date = strftime('%Y-%m-%d')
    var daily_dir = g:notes_global_directory .. '/daily'

    var target_file = daily_dir .. '/' .. date .. note_extension
    if !isdirectory(daily_dir)
        mkdir(daily_dir, 'p')
    endif

    execute 'vsplit ' .. fnameescape(target_file)
    if line('$') == 1 && getline(1) == ''
        var daily_template = ['# ' .. date, 'Ref: [[index]]']
        setline(1, daily_template)
        normal! G$
    endif
enddef

def SetupUI()
    syntax region WikiLink start='\[\[' end='\]\]' contains=WikiLinkText oneline
    highlight default link WikiLink Special

    syntax match WikiLinkText /[^\[\]]\+/ contained
    highlight default link WikiLinkText Special

    nnoremap <buffer> <CR> <ScriptCmd>FollowLink()<CR>
    nnoremap <buffer> <BS> <ScriptCmd>WhatLinksHere()<CR>
enddef

augroup Notes
    autocmd!
    autocmd BufNewFile,BufRead *.note setfiletype markdown
    autocmd Filetype markdown if expand('%:e') == 'note' | SetupUI() | endif
augroup END

command! Daily OpenDaily()
command! Notes execute 'vsplit ' .. fnameescape(g:notes_global_directory ..  '/index.note')
command! -bang SearchNotes call fzf#vim#files(g:notes_global_directory, fzf#vim#with_preview(), <bang>0)
