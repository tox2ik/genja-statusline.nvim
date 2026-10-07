if vim.g.loaded_genja_statusline then
	return
end
vim.g.loaded_genja_statusline = true


-- Fallbacks for the custom highlight groups. `default = true` means a
-- colorscheme (or your own config) that defines them wins.
local function highlights()
	vim.api.nvim_set_hl(0, 'StatusLineWeak', { link = 'StatusLineNC', default = true })
	vim.api.nvim_set_hl(0, 'WinBarPath', { link = 'WinBar', default = true })
	vim.api.nvim_set_hl(0, 'WinBarModified', { link = 'WinBar', default = true })
end

highlights()
vim.api.nvim_create_autocmd('ColorScheme', {
	group = vim.api.nvim_create_augroup('genja_statusline', { clear = true }),
	callback = highlights,
})
