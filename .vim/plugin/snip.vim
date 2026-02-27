vim9script
# wip: snippet engine
# GOALS:
# supports vim-snipmate
# robust; entire plugin in vim9script
# inital version will be in a single file (this file)
# will figure out file structure later (and put in a separate repo)
var active_visual_text = ""

# TODO dynamically parse corresponding file and load snippets like so:
# var snippets = {
#     'c': {
#         'once': "#pragma once\n$0",
#         'inc': "#include <${1:stdio}.h>\n$0",
#         'incl': "#include \"${1:stdio}.h\"\n$0",
#         'if': "if (${1:cond}) {\n\t${0:${VISUAL}}\n}\n",
#         'n': "`expand(\"%:t\")`$0",
#     }
# }

# TODO ast format is going to be something like so:
enum AST
    Text,
    Mark,
    Eval,
    Visual
endenum

var compiled_snippets = {
    'c': {
        'once': [
            {type: AST.Text, value: "#pragma once\n"},
            {type: AST.Mark, id: 0},
        ],
        'inc': [
            {type: AST.Text, value: "#include <"},
            {type: AST.Mark, id: 1, value: [{type: AST.Text, value: "stdio"}]},
            {type: AST.Text, value: ".h>\n"},
            {type: AST.Mark, id: 0},
        ],
        'incl': [
            {type: AST.Text, value: "#include \""},
            {type: AST.Mark, id: 1, value: [{type: AST.Text, value: "stdio"}]},
            {type: AST.Text, value: ".h\"\n"},
            {type: AST.Mark, id: 0},
        ],
        'if': [
            {type: AST.Text, value: "if ("},
            {type: AST.Mark, id: 1, value: [{type: AST.Text, value: "cond"}]},
            {type: AST.Text, value: ") {\n\t"},
            {type: AST.Mark, id: 0, value: [{type: AST.Visual}]},
            {type: AST.Text, value: "\n}\n"},
        ],
        'guard': [
            {type: AST.Text, value: "#ifndef "},
            {type: AST.Mark, id: 1, value: [
                {type: AST.Eval, value: 'toupper(expand("%:t:r"))'},
                {type: AST.Text, value: '_DEFINED_H'}
            ]},
            {type: AST.Text, value: "\n#define "},
            {type: AST.Mark, id: 1, value: [
                {type: AST.Eval, value: 'toupper(expand("%:t:r"))'},
                {type: AST.Text, value: '_DEFINED_H'}
            ]},
            {type: AST.Text, value: "\n\n"},
            {type: AST.Mark, id: 0},
            {type: AST.Text, value: "\n\n#endif  // "},
            {type: AST.Mark, id: 1, value: [
                {type: AST.Eval, value: 'toupper(expand("%:t:r"))'},
                {type: AST.Text, value: '_DEFINED_H'}
            ]},
        ],

    }
}

# TODO compile snippet into the sample AST format above
# the hardest part of the snippet engine:
# CompileSnippets()

# TODO get compiled snippet, cache them (into a file)
# XXX is getting a cached AST (json decode) faster or slower than parsing the
#  file again?  is it possible to serialize this data instead?
# compilation happens dynamically when only that file is loaded.
# compilation results are cached for speed
# (recompilation of snippets only happens when the snippets file is updated)
# IMPORTANT: skip caching for the first version.
# GetCompiledSnippet()

# TODO define text properties
# erase them upon jumping to $0 (to keep the thing clear)
# the text properties will hold the following:
# the token id, length of character to select on jump
if empty(prop_type_get('snippet_mark'))
    prop_type_add('snippet_mark', {
        highlight: 'Search',  # debug
        start_incl: true,
        end_incl: true
    })
endif

# TODO
# attach text properties
# jump around in snippet (the second hardest part of the snippet engine)
# replace all text correctly (multiple $n replacements)
# run commands in snippet (surrounded by `)

# expand snippet
def ExpandSnippet(ast: list<dict<any>>)
    var lnum = line('.')
    var ccol = col('.')
    var curline = getline(lnum)

    var prefix = ccol == 1 ? '' : curline[ : ccol - 2]
    var suffix = curline[ccol - 1 : ]

    var lines = [prefix]
    var marks = []

    for token in ast
        var val = ''
        if token.type == AST.Text
            val = token.value
        elseif token.type == AST.Eval
            val ..= eval(token.value)
        elseif token.type == AST.Mark
            if has_key(token, 'value')
                var child_token = token.value
                if child_token.type == AST.Text
                    val = child_token.value
                elseif child_token.type == AST.Eval
                    val ..= eval(child_token.value)
                elseif child_token.type == AST.Visual
                    if active_visual_text != ""
                        val = active_visual_text
                        active_visual_text = ""
                    endif
                endif
            endif
            add(marks, {
                id: token.id,
                line_offset: len(lines) - 1,
                col: len(lines[-1]) + 1,
                len: len(val)
            })
        endif

        if &expandtab
            val = val->substitute('\t', repeat(' ', shiftwidth()), 'g')
        endif
        var parts = split(val, '\n', 1)
        lines[-1] ..= parts[0]
        if len(parts) > 1
            extend(lines, parts[1 : ])
        endif
    endfor

    lines[-1] ..= suffix

    setline(lnum, lines[0])
    if len(lines) > 1
        append(lnum, lines[1 : ])
    endif

    for mark in marks
        prop_add(lnum + mark.line_offset, mark.col, {
            type: 'snippet_mark',
            length: mark.len,
            id: mark.id
        })
    endfor
enddef

def CaptureVisual()
    var saved_register = @"
    normal! gv""y
    active_visual_text = @"
    @" = saved_register
    normal! gv"_d
    startinsert
enddef

def JumpForward()
enddef

def JumpBackward()
enddef

def SmartBind()
enddef

# order of implementation:
# 1. basic snippet expansion from the AST + placement of textprops
# 2. snippet jumping + multi-replacement
# 3. parser
def ExpandSnip(name: string)
    if has_key(compiled_snippets['c'], name)
        ExpandSnippet(compiled_snippets['c'][name])
    endif
enddef

command! -nargs=1 ExpandSnip ExpandSnip(<args>)
inoremap <C-j> <ScriptCmd>JumpForward()<CR>
snoremap <C-j> <ScriptCmd>JumpForward()<CR>
vnoremap <C-j> <ScriptCmd>CaptureVisual()<CR>
inoremap <C-k> <ScriptCmd>JumpBackward()<CR>
snoremap <C-k> <ScriptCmd>JumpBackward()<CR>
