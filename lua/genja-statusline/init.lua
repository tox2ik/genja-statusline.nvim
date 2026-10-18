local M = {}

---@alias genja-statusline.Rename fun(name: string, buf: integer): string
---Statusline-format string shown after the winbar's file name; '' for none.
---@alias genja-statusline.WinbarPart fun(buf: integer, win: integer): string

---@class genja-statusline.Opts
---@field statusline? boolean set 'statusline'
---@field tabline? boolean set 'tabline'
---@field winbar? boolean set 'winbar'
---@field rune? boolean display precise information about the cursor position
---@field rename? genja-statusline.Rename[] applied to tab labels
---@field winbar_extra? genja-statusline.WinbarPart[] parts after the winbar's file name (breadcrumbs etc.)

---@type genja-statusline.Opts
M.config = {
	statusline = true, -- set 'statusline'
	tabline = true, -- set 'tabline'
	winbar = true,  -- set 'winbar'
	rune = false,   -- display precise information about the cursor position
	rename = {},    -- extra function(name, buf) -> name, applied to tab labels
	winbar_extra = {}, -- function(buf, win) -> statusline string, after the file name
}

---@param opts? genja-statusline.Opts
function M.setup(opts)
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})

	if M.config.statusline then
		vim.o.statusline = "%{%v:lua.require'genja-statusline'.Statusline()%}"
	end

	if M.config.tabline then
		vim.o.tabline = "%{%v:lua.require'genja-statusline'.Tabline()%}"
	end

	if M.config.winbar then
		vim.o.winbar = "%{%v:lua.require'genja-statusline'.Winbar()%}"
	end
end

function M.Statusline() return require('genja-statusline.statusline').render() end
function M.Tabline() return require('genja-statusline.tabline').render() end
function M.Winbar() return require('genja-statusline.winbar').render() end

return M
