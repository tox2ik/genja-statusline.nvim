--[[
	https://github.com/ojroques/nvim-hardline
]]

local u = require('genja-statusline.util')
local sl, hl = u.sl, u.hl

local M = {}

---Strings from `winbar_extra`, after the file name. `%<` lets nvim cut them
---from the left when the window is too narrow, so the innermost part stays.
---A failing part is skipped: an error here would repeat on every redraw.
---@param buf integer
---@param win integer
---@return string
local function extras(buf, win)
	local parts = {}
	for _, part in ipairs(require('genja-statusline').config.winbar_extra or {}) do
		local ok, str = pcall(part, buf, win)
		if ok and type(str) == 'string' and str ~= '' then
			table.insert(parts, str)
		end
	end
	if #parts == 0 then
		return ''
	end
	return ' %<' .. table.concat(parts, ' ')
end

function M.render()
	local fname = vim.fn.fnamemodify(sl('%t'), ':r') -- top of path, no extension
	-- while the winbar is drawn, the current window is the one it belongs to
	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	if fname == '' then
		fname = vim.bo[bufnr].filetype
	end
	return (''
		.. hl('WinBarPath', fname)
		.. hl('WinBarModified', sl('%M')) -- modified flag
		.. hl('WinBarPath', sl('%r')) -- read-only [RO]
		.. hl('WinBarPath', sl('%q')) -- [quickfix list]
		.. extras(bufnr, win)
	)
end

return M
