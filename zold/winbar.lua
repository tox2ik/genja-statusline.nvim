--[[
	https://github.com/ojroques/nvim-hardline
]]


local function sl(var, opt) return vim.api.nvim_eval_statusline(var, (opt or {})).str end
local function hl(hiGroup, s) return  '%#' .. hiGroup .. '#' .. s .. '%*' end

function Winbar()
	local fname = vim.fn.fnamemodify(sl('%t'), ':r')  -- top of path, no extension
	local bufnr = vim.api.nvim_get_current_buf()
	if fname == '' then
		fname = vim.bo[bufnr].filetype
	end
	return (''
	..hl('WinBarPath',     fname)
	..hl('WinBarModified', sl('%M')) -- modified flag
	..hl('WinBarPath',     sl('%r')) -- read-only [RO]
	..hl('WinBarPath',     sl('%q')) -- [quickfix list]
	)
end

return {
	Winbar = Winbar
}
