vim9script
# wip: snippet engine
# GOALS:
# supports vim-snipmate
# robust; entire plugin in vim9script
# inital version will be in a single file (this file)
# will figure out file structure later (and put in a separate repo)

# TODO dynamically parse corresponding file and load snippets like so:
var snippets = {
    'c': {
        'once': "#pragma once\n$0",
        'inc': "#include <${1:stdio}.h>\n$0",
        'incl': "#include \"${1:stdio}.h\"\n$0",
        'if': "if (${1:cond}) {\n\t${0:${VISUAL}}\n}\n",
        'n': "`expand(\"%:t\")`$0",
    }
}

# TODO ast format is going to be something like so:
enum AST
    Text,
    Mark,
    Eval
endenum

var compiled_snippets = {
    'c': {
        'once': [
            {type: AST.Text, value: "#pragma once\n"},
            {type: AST.Mark, id: 0},
        ],
        'inc': [
            {type: AST.Text, value: "#include <"},
            {type: AST.Mark, id: 1, value: "stdio"},
            {type: AST.Text, value: ".h>\n"},
            {type: AST.Mark, id: 0},
        ],
        'incl': [
            {type: AST.Text, value: "#include \""},
            {type: AST.Mark, id: 1, value: "stdio"},
            {type: AST.Text, value: ".h\"\n"},
            {type: AST.Mark, id: 0},
        ],
        'if': [
            {type: AST.Text, value: "if ("},
            {type: AST.Mark, id: 1, value: "cond"},
            {type: AST.Text, value: ") {\n\t"},
            {type: AST.Mark, id: 0, value: "{VISUAL}"},
            {type: AST.Text, value: "\n}\n"},
        ],
        'n': [
            {type: AST.Eval, value: 'expand("%:t")'},
            {type: AST.Mark, value: 0},
        ]
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
            val = eval(token.value)
        elseif token.type == AST.Mark
            val = has_key(token, 'value') ? token.value : ''
            add(marks, {
                id: token.id,
                line_offset: len(lines) - 1,
                col: len(lines[-1]) + 1,
                len: len(val)
            })
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

def JumpAround()
enddef

def SmartBind()
enddef

# order of implementation:
# 1. basic snippet expansion from the AST + placement of textprops
# 2. snippet jumping + multi-replacement
# 3. parser
command! -nargs=1 TestExpand ExpandSnippet(<args>)
