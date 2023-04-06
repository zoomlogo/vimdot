se nocp nohls nowrap et ts=4 sw=4 nobk ru is nu rnu ls=2 tgc noswf nowb so=1 title
se stal=2 list lcs=tab:→\ ,space:· bg=dark gfn=sevka,agave_NF_r:h13 cole=1 pp+=~/.vim
se bs=2 sc wmnu shm=asWIcq ttimeout ttm=100 top rtp+=~/k/vim-k enc=utf-8
au bufreadpost * sil! norm! g`"zv
au bufnew,bufnewfile,bufread *.k :se ft=k
au vimleave * se gcr=a:ver25
au filetype python nn <cr> :w<cr>:!clear && python %<cr>
au filetype k nn <cr> :w<cr>:!clear && ~/k/k %<cr>
au filetype c nn <cr> :w<cr>:!clear && gcc % -Wall -Wextra -O2 -std=c17 && ./a.out<cr>
au filetype cpp nn <cr> :w<cr>:!clear && g++ % -Wall -Wextra -O2 -std=c++20 && ./a.out<cr>
au bufnew,bufnewfile,bufread *.flx nn <cr> :w<cr>:!flax f %<cr>
au filetype make se noet
filet plugin indent on
sy enable
colo decino
let g:colorscheme_changer_colors=['decino','defun','decino','cemant','everforest']
nm <space> <nop>
let g:rainbow_active=1
let mapleader=" "
nm Q @q
nm <leader>w <cmd>w<cr>
nm <leader>h <cmd>vsplit<cr>
nm <leader>v <cmd>split<cr>
nm <leader>t <cmd>tabnew<cr>
nm <leader>p <cmd>tabnext<cr>
nm <leader>cd <cmd>cd %/..<cr>
nm <leader>cc <cmd>ChangeColor<cr>
nm D d$
nm Y y$
nm <m-w> viw
if has('nvim')
 se scl=yes ls=3
 nm <f1> <cmd>lua vim.diagnostic.goto_next()<cr>
 nm <f2> <cmd>lua vim.diagnostic.goto_prev()<cr>
 nm gD <cmd>lua vim.lsp.buf.declaration()<cr>
 nm gd <cmd>lua vim.lsp.buf.definition()<cr>
 nm K <cmd>lua vim.lsp.buf.hover()<cr>
 nm gr <cmd>lua vim.lsp.buf.references()<cr>
 nm <leader>r <cmd>lua vim.lsp.buf.rename()<cr>
 nm <leader>ff <cmd>Telescope find_files<cr>
 nm <leader>fg <cmd>Telescope live_grep<cr>
 nm <leader>m <cmd>MRU<cr>
 au textyankpost * lua vim.highlight.on_yank{higroup="IncSearch", timeout=150, on_visual=true}
lua << EOF
  require("notify").setup({stages="slide", icons={
   ERROR="", WARN="", INFO="", DEBUG="d", TRACE="t",
  }})
  vim.notify = require("notify")
  require("colorizer").setup()
  require("gitsigns").setup()
  require("which-key").setup()
  local signs = { Error=" ", Warning=" ", Hint=" ", Information=" " }
  for type, icon in pairs(signs) do
   local hl = "LspDiagnosticsSign" .. type
   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
  local cmp = require("cmp")
  cmp.setup({ snippet={ expand=function(args)
   vim.fn["vsnip#anonymous"](args.body)
    end,
   },
   mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
     i = cmp.mapping.abort(),
     c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = function(fallback)
     if cmp.visible() then
      cmp.select_next_item()
     else
      fallback()
     end
    end,
   },
   sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "buffer" },
    { name = "path" },
   })
  })
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require("nvim-lsp-installer").on_server_ready(function(server)
   local opts = { capabilities = capabilities }
   server:setup(opts)
  end)
EOF
end
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
