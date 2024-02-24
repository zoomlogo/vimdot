so ~/.vimrc
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
se stl=%#PmenuSel#\ %{mode()}\ %#Statusline#\ %f\ %m%r%h%=%y\ %l:%c\ %2p%%
