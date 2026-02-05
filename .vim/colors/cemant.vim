" cemant colors for vim (.vim/colors/cemant.vim)
" agaric <agaric@protonmail.com>
" modified by zoomlogo

hi clear
if exists("syntax_on")
  sy reset
en
let colors_name = "cemant"

let s:foreground = "#b9bdc5"
let s:background = "#36383f"

let s:Dark    = "#16161d"
let s:Red     = "#a32c2d"
let s:Green   = "#4b7d08"
let s:Yellow  = "#916814"
let s:Blue    = "#3c56aa"
let s:Magenta = "#91328c"
let s:Cyan    = "#237e6f"
let s:Light   = "#92959d"

let s:dark    = "#575a61"
let s:red     = "#cf554d"
let s:green   = "#72a336"
let s:yellow  = "#ba8d3b"
let s:blue    = "#667ad3"
let s:magenta = "#ba59b3"
let s:cyan    = "#4ea494"
let s:light   = "#d2d6de"

exe "hi Normal       guifg=" . s:foreground . " guibg=" . s:background
exe "hi ErrorMsg     term=standout ctermbg=1 ctermfg=15 guibg=" . s:red . " guifg=" . s:Light
exe "hi IncSearch    term=reverse cterm=reverse gui=reverse"
exe "hi ModeMsg      term=bold cterm=bold gui=bold"
exe "hi StatusLine   term=reverse cterm=bold ctermbg=8 ctermfg=15 gui=bold guibg=" . s:Dark . " guifg=" . s:Light
exe "hi StatusLineNC term=reverse cterm=NONE ctermfg=8 gui=NONE guifg=" . s:Dark
exe "hi StatusLineTerm term=reverse cterm=bold ctermbg=2 ctermfg=15 gui=bold guibg=" . s:green . " guifg=" . s:Light
exe "hi StatusLineTermNC term=reverse cterm=NONE ctermbg=2 ctermfg=15 gui=NONE guibg=" . s:green . " guifg=" . s:Light
exe "hi ToolbarLine  cterm=bold ctermbg=8 ctermfg=0 gui=bold guibg=" . s:Dark . " guifg=" . s:dark
exe "hi ToolbarButton term=bold cterm=bold ctermbg=8 ctermfg=15 gui=bold guibg=" . s:Dark . " guifg=" . s:Light
exe "hi VertSplit    term=reverse cterm=NONE ctermfg=7 gui=NONE guifg=" . s:light
exe "hi Visual       term=reverse ctermbg=15 guibg=" . s:Light
exe "hi VisualNOS    term=underline,bold cterm=underline,bold gui=underline,bold"
exe "hi Cursor       term=bold cterm=bold ctermbg=0 ctermfg=15 gui=bold guibg=" . s:dark . " guifg=" . s:Light
exe "hi lCursor      term=bold cterm=bold ctermbg=6 ctermfg=0 gui=bold guibg=" . s:cyan . " guifg=" . s:dark
exe "hi MatchParen   term=reverse ctermbg=14 ctermfg=0 guibg=" . s:Cyan . " guifg=" . s:dark
exe "hi Directory    term=bold     ctermfg=4  guifg=" . s:blue
exe "hi LineNr       ctermfg=7 guifg=" . s:light
exe "hi SignColumn   ctermfg=7 guifg=" . s:light . " guibg=" . s:background
exe "hi ColorColumn  guibg=" . s:light
exe "hi Pmenu        guifg=" . s:Light . " guibg=" . s:Dark
exe "hi PmenuSel     guifg=" . s:Light . " guibg=" . s:dark
exe "hi PmenuSbar    guibg=" . s:Dark
exe "hi MoreMsg      term=bold     ctermfg=2  gui=bold   guifg=" . s:green
exe "hi Question     term=standout ctermfg=2  gui=bold   guifg=" . s:green
exe "hi Search       term=reverse cterm=reverse,bold ctermbg=NONE guibg=" . s:Yellow . " guifg=NONE"
exe "hi SpecialKey   term=bold     ctermfg=0 guifg=" . s:dark
exe "hi NonText   term=bold     ctermfg=0 guifg=" . s:dark
exe "hi Title        term=bold     ctermfg=5  gui=bold   guifg=" . s:magenta
exe "hi WarningMsg   term=standout ctermbg=7  ctermfg=1  guibg=" . s:Red . " guifg=" . s:dark
exe "hi WildMenu     term=standout ctermbg=3  ctermfg=0  guibg=" . s:yellow . " guifg=" . s:dark
exe "hi Folded       term=standout ctermbg=7  ctermfg=4  guibg=" . s:light . " guifg=" . s:blue
exe "hi FoldColumn   term=standout ctermbg=7  ctermfg=4  guibg=" . s:light . " guifg=" . s:blue
exe "hi FoldColumn   term=standout ctermbg=7  ctermfg=4  guibg=" . s:light . " guifg=" . s:blue
exe "hi Conceal      ctermbg=8 ctermfg=7 guibg=" . s:Dark . " guifg=" . s:light
exe "hi DiffAdd      term=bold ctermbg=12 guibg=" . s:Blue
exe "hi DiffChange   term=bold ctermbg=13 guibg=" . s:Magenta
exe "hi DiffDelete   term=bold ctermbg=9 guibg=" . s:Red
exe "hi DiffText     term=bold ctermbg=14 guibg=" . s:Cyan
exe "hi SpellBad     term=bold ctermbg=9 gui=undercurl guibg=" . s:Red . " guisp=" . s:red
exe "hi SpellCap     term=bold ctermbg=12 gui=undercurl guibg=" . s:Blue . " guisp=" . s:blue
exe "hi SpellRare    term=bold ctermbg=13 gui=undercurl guibg=" . s:Magenta . " guisp=" . s:magenta
exe "hi SpellLocal   term=bold ctermbg=14 gui=undercurl guibg=" . s:Cyan . " guisp=" . s:blue
exe "hi CursorLine   term=underline cterm=underline guibg=#aaadb5"
exe "hi CursorColumn term=reverse  ctermbg=7  guibg=#aaadb5"

exe "hi Comment cterm=italic ctermfg=12 term=italic gui=italic guifg=" . s:Blue

exe "hi Boolean   ctermfg=1 guifg=" . s:red
exe "hi Character ctermfg=1 guifg=" . s:red
exe "hi Float     ctermfg=1 guifg=" . s:red
exe "hi Constant  ctermfg=1 guifg=" . s:red
exe "hi Number    ctermfg=1 guifg=" . s:red
exe "hi String    ctermfg=1 guifg=" . s:red

exe "hi Function   term=underline cterm=bold ctermfg=4 guifg=" . s:blue
exe "hi Identifier term=underline cterm=bold ctermfg=4 guifg=" . s:blue

exe "hi Statement   term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Conditional term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Repeat      term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Label       term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Operator    term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Keyword     term=underline ctermfg=3 guifg=" . s:yellow
exe "hi Exception   term=underline ctermfg=3 guifg=" . s:yellow

exe "hi PreProc   ctermfg=5 guifg=" . s:magenta
exe "hi Include   ctermfg=5 guifg=" . s:magenta
exe "hi Define    ctermfg=5 guifg=" . s:magenta
exe "hi Macro     ctermfg=5 guifg=" . s:magenta
exe "hi PreCondit ctermfg=5 guifg=" . s:magenta

exe "hi Type         ctermfg=2 guifg=" . s:green
exe "hi StorageClass ctermfg=2 guifg=" . s:green
exe "hi Structure    ctermfg=2 guifg=" . s:green
exe "hi Typedef      ctermfg=2 guifg=" . s:green

exe "hi Special        ctermfg=13 guifg=" . s:Magenta
exe "hi SpecialChar    ctermfg=13 guifg=" . s:Magenta
exe "hi Tag            ctermfg=13 guifg=" . s:Magenta
exe "hi Delimiter      ctermfg=13 guifg=" . s:Magenta
exe "hi SpecialComment ctermfg=13 guifg=" . s:Magenta
exe "hi Debug          ctermfg=13 guifg=" . s:Magenta

exe "hi Error   term=standout ctermbg=1 ctermfg=15 guibg=" . s:red . " guifg=" . s:Light
exe "hi Ignore  ctermfg=7 guifg=" . s:light
exe "hi Todo    ctermbg=11 ctermfg=0 guibg=" . s:Blue . " guifg=" . s:dark
exe "hi Underlined term=underline cterm=underline ctermfg=12 gui=underline guifg=" . s:Blue

exe "hi DiagnosticError   guifg=" . s:Red    . " guibg=" . s:background
exe "hi DiagnosticWarning guifg=" . s:yellow . " guibg=" . s:background
exe "hi DiagnosticInfo    guifg=" . s:Cyan   . " guibg=" . s:background
exe "hi DiagnosticHint    guifg=" . s:Green  . " guibg=" . s:background

exe "hi DiagnosticsVirtualTextError       guifg=" . s:Red    . " guibg=" . s:background
exe "hi DiagnosticsVirtualTextWarning     guifg=" . s:yellow . " guibg=" . s:background
exe "hi DiagnosticsVirtualTextInformation guifg=" . s:Cyan   . " guibg=" . s:background
exe "hi DiagnosticsVirtualTextHint        guifg=" . s:Green  . " guibg=" . s:background

exe "hi GitSignsAdd    guifg=" . s:Blue    . " guibg=" . s:background
exe "hi GitSignsChange guifg=" . s:Magenta . " guibg=" . s:background
exe "hi GitSignsDelete guifg=" . s:Red     . " guibg=" . s:background
