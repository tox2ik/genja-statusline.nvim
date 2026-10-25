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

-- label for a normal buffer without a name, instead of nvim's [No Name]
M.NAMELESS = '[Nameless]'

---True for a buffer nvim shows as [No Name]: no name and a normal buftype
---(nofile, quickfix, help... have their own labels).
---@param buf integer
---@return boolean
function M.is_nameless(buf)
	return vim.api.nvim_buf_get_name(buf) == '' and vim.bo[buf].buftype == ''
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
