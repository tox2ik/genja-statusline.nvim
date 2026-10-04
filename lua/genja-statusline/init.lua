local M = {}

M.config = {
	statusline = true, -- set 'statusline'
	tabline = true, -- set 'tabline'
	winbar = true, -- set 'winbar'
	rune = false, -- display precise information about the cursor position
	rename = {}, -- extra function(name, buf) -> name, applied to tab labels
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})
	if M.config.statusline then
		vim.o.statusline = "%{%v:lua.require'genja-statusline'.statusline()%}"
	end
	if M.config.tabline then
		vim.o.tabline = "%{%v:lua.require'genja-statusline'.tabline()%}"
	end
	if M.config.winbar then
		vim.o.winbar = "%{%v:lua.require'genja-statusline'.winbar()%}"
	end
end

function M.statusline()
	return require('genja-statusline.statusline').render()
end

function M.tabline()
	return require('genja-statusline.tabline').render()
end

function M.winbar()
	return require('genja-statusline.winbar').render()
end

return M
