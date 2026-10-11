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

-- wrap s in a highlight group
---@param hiGroup string
---@param s string
---@return string
function M.hl(hiGroup, s)
	return '%#' .. hiGroup .. '#' .. s .. '%*'
end

return M
