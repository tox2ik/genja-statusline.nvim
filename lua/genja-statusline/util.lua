local M = {}

M.DOTm = '·'
M.Space = ' '
M.Empty = ''

-- resolve statusline %items to plain text
function M.sl(a, b)
	return vim.api.nvim_eval_statusline(a, b or {}).str
end

-- wrap s in a highlight group
function M.hl(hiGroup, s)
	return '%#' .. hiGroup .. '#' .. s .. '%*'
end

return M
