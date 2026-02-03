vim9script
const PHI = 1.61803398875

def GoldenResize()
    if winnr('$') == 1 | return | endif
    if win_gettype() == 'popup' | return | endif
    if &diff | return | endif

    var target_width = float2nr(&columns / PHI)
    var target_height = float2nr(&lines / PHI)

    var current = winnr()
    var should_resize_horizontally = (winnr('h') != current) || (winnr('l') != current)
    var should_resize_vertically = (winnr('j') != current) || (winnr('k') != current)

    if should_resize_horizontally | silent! execute 'vertical resize ' .. target_width | endif
    if should_resize_vertically | silent! execute 'resize ' .. target_height | endif
enddef

augroup GoldenResize
    autocmd!
    autocmd WinEnter * GoldenResize()
augroup END
