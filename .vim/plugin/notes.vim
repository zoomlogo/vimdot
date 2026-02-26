vim9script
# Notes: Note taking plugin for Vim.
# Depends on fuzzbox.vim
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
# <BS> -> Uses fuzzbox to search through notes showing those which link to the
#   current note.

g:notes_global_directory = get(g:, 'notes_global_directory', expand('~/notes'))
const note_extension = '.note'
const daily_dirext = '/daily'

def FollowLink()
    # find [[link]]; SINGLE WORD ONLY
    var word = expand('<cWORD>')
    var start = matchstrpos(word, '\[\[')[2]
    var end = matchstrpos(word, '\]\]')[1]
    if start == -1 || end == -1 | return | endif
    var link = word[start : end - 1]

    # make subdirectories:
    var target_file = g:notes_global_directory .. '/' .. link .. note_extension
    var parents = fnamemodify(target_file, ':h')
    if !isdirectory(parents)
        mkdir(parents, 'p')
        echo "[Notes] Created directories: " .. parents
    endif

    # update current buffer and goto [[link]]
    update
    execute 'edit ' .. fnameescape(target_file)
    if line('$') == 1 && getline(1) == ''
        var template = ['# ' .. link, 'Tags: #inbox', 'Ref: [[index]]', '']
        setline(1, template)
        cursor(1, 3)
    endif
enddef

def WhatLinksHere()
    if !exists('*fuzzbox#internal#launcher#Start')
        echoerr 'Requires fuzzbox.vim'
        return
    endif

    var note = fnamemodify(expand('%'), ':p:s?^' .. g:notes_global_directory .. '/??:r')
    var pattern = '[[' .. note .. ']]'
    fuzzbox#internal#launcher#Start('grep', {
        cwd: g:notes_global_directory,
        title: 'Backlinks',
        prompt_text: pattern,
    })
enddef

def SearchTags()
    if !exists('*fuzzbox#internal#launcher#Start')
        echoerr 'Requires fuzzbox.vim'
        return
    endif

    fuzzbox#internal#launcher#Start('grep', {
        cwd: g:notes_global_directory,
        title: 'Tags',
        prompt_text: '#',
    })
enddef

def OpenDaily()
    var date = strftime('%Y-%m-%d')
    var daily_dir = g:notes_global_directory .. daily_dirext

    var target_file = daily_dir .. '/' .. date .. note_extension
    if !isdirectory(daily_dir)
        mkdir(daily_dir, 'p')
    endif

    if expand('%:e') == 'note'
        execute 'edit ' .. fnameescape(target_file)
    else
        execute 'vsplit ' .. fnameescape(target_file)
    endif

    if line('$') == 1 && getline(1) == ''
        var daily_template = ['# ' .. date, 'Tags: #daily', '']
        setline(1, daily_template)
        normal! G$
    endif
enddef

def NDayJump(skip: number)
    var cur = expand('%:t:r')
    var time = strptime('%Y-%m-%d', cur)

    var target = time + skip * 86400
    var target_file = strftime('%Y-%m-%d', target)
    target_file = g:notes_global_directory .. daily_dirext .. '/' .. target_file .. note_extension

    if filereadable(target_file)
        update
        execute 'edit ' .. fnameescape(target_file)
    endif
enddef

def SetupUI()
    syntax region WikiLink start='\[\[' end='\]\]' contains=WikiLinkText oneline
    highlight default link WikiLink Special

    syntax match WikiLinkText /[^\[\]]\+/ contained
    highlight default link WikiLinkText Special

    setlocal colorcolumn=78 textwidth=78 formatoptions=tcqn joinspaces
    setlocal conceallevel=2

    nnoremap <buffer> <CR> <ScriptCmd>FollowLink()<CR>
    nnoremap <buffer> <BS> <ScriptCmd>WhatLinksHere()<CR>
    nnoremap <buffer> ]d <ScriptCmd>NDayJump(v:count1)<CR>
    nnoremap <buffer> [d <ScriptCmd>NDayJump(-1 * v:count1)<CR>
    nnoremap <buffer> <C-f> <Cmd>SearchNotes<CR>
    nnoremap <buffer> <C-t> <Cmd>SearchTags<CR>
enddef

augroup Notes
    autocmd!
    autocmd BufNewFile,BufRead *.note set filetype=note.markdown
    autocmd FileType note.markdown SetupUI()
augroup END

command! Daily OpenDaily()
command! Notes execute 'vsplit ' .. fnameescape(g:notes_global_directory .. '/index.note')
command! -bang SearchNotes call fuzzbox#internal#launcher#Start('files', { cwd: g:notes_global_directory })
command! -bang SearchTags SearchTags()
