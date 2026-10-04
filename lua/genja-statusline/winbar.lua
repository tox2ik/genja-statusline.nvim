--[[
	https://github.com/ojroques/nvim-hardline
]]

local u = require('genja-statusline.util')
local sl, hl = u.sl, u.hl

local M = {}

function M.render()
	local fname = vim.fn.fnamemodify(sl('%t'), ':r') -- top of path, no extension
	local bufnr = vim.api.nvim_get_current_buf()
	if fname == '' then
		fname = vim.bo[bufnr].filetype
	end
	return (''
		.. hl('WinBarPath', fname)
		.. hl('WinBarModified', sl('%M')) -- modified flag
		.. hl('WinBarPath', sl('%r')) -- read-only [RO]
		.. hl('WinBarPath', sl('%q')) -- [quickfix list]
	)
end

return M
