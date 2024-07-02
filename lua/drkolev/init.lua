require("drkolev.remap")
require("drkolev.set")

local augroup = vim.api.nvim_create_augroup
local maGroup = augroup('maGroup', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

-- vim.cmd("autocmd BufWritePre <buffer> EslintFixAll")
-- vim.cmd("

-- vim.api.nvim_create_autocmd('FileType', {
-- 	pattern = 'typescriptreact',
-- 	group = vim.api.nvim_create_augroup('typescriptAutoSave', { clear = true }),
-- 	callback = function ()
-- 		vim.api.nvim_create_autocmd('BufWritePre', {
-- 			vim.lsp.buf.format()
-- 		})
-- 	end,
-- })

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

local function is_eslint_installed()
  local root_files = {
    '.eslintrc',
    '.eslintrc.json',
    '.eslintrc.js',
    'node_modules/.bin/eslint'
  }

  for _, file in ipairs(root_files) do
    if vim.fn.glob(file) ~= '' then
      return true
    end
  end

  return false
end

autocmd({"BufWritePre"}, {
    group = maGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

if is_eslint_installed() then
  autocmd({"BufWritePost"}, {
      group = maGroup,
      pattern = {"*.jsx", "*.js", "*.ts", "*.tsx"},
      command = ":EslintFixAll",
  })
end

autocmd('LspAttach', {
    group = maGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})
