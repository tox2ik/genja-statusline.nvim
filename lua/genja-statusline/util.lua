local M = {}

M.DOTm = '·'
M.Space = ' '
M.Empty = ''

-- resolve statusline %items to plain text
---@param a string statusline expression
---@param b? vim.api.keyset.eval_statusline
---@return string
function M.sl(a, b)
	return vim.api.nvim_eval_statusline(a, b or {}).str
end

-- make s clickable when a handler for `name` is configured (see init.lua `clicks`)
---@param name string 'file', 'branch' or 'diagnostics'
---@param s string
---@return string
function M.click(name, s)
	local sl = require('genja-statusline')
	if s == '' or not sl.config.clicks[name] then
		return s
	end
	for id, n in ipairs(sl.CLICK_NAMES) do
		if n == name then
			return '%' .. id .. '@genja_statusline#click@' .. s .. '%X'
		end
	end
	return s
end

-- wrap s in a highlight group
---@param hiGroup string
---@param s string
---@return string
function M.hl(hiGroup, s)
	return '%#' .. hiGroup .. '#' .. s .. '%*'
end

return M
