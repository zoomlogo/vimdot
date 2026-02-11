vim9script
# GResize: Minimal port of https://github.com/roman/golden-ratio in
# vim9script.

# reciprocal of phi
const R_PHI = 618 # / 1000

def GoldenResize()
    if winnr('$') == 1 | return | endif
    if win_gettype() == 'popup' | return | endif
    if &diff | return | endif

    var target_width = &columns * R_PHI / 1000
    var target_height = &lines * R_PHI / 1000

    var current = winnr()
    var should_resize_horizontally = (winnr('h') != current) || (winnr('l') != current)
    var should_resize_vertically = (winnr('j') != current) || (winnr('k') != current)

    if should_resize_horizontally
        silent! execute 'vertical resize ' .. target_width
    endif

    if should_resize_vertically
        silent! execute 'resize ' .. target_height
    endif
enddef

augroup GoldenResize
    autocmd!
    autocmd WinEnter * GoldenResize()
augroup END
