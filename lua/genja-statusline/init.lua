local M = {}

---@alias genja-statusline.Rename fun(name: string, buf: integer): string
---Statusline-format string shown after the winbar's file name; '' for none.
---@alias genja-statusline.WinbarPart fun(buf: integer, win: integer): string
---Statusline-format string shown on the right half of the statusline; '' for none.
---@alias genja-statusline.StatuslinePart fun(buf: integer): string

---@class genja-statusline.Opts
---@field statusline? boolean set 'statusline'
---@field tabline? boolean set 'tabline'
---@field winbar? boolean set 'winbar'
---@field rune? boolean display precise information about the cursor position
---@field rename? genja-statusline.Rename[] applied to tab labels
---@field winbar_extra? genja-statusline.WinbarPart[] parts after the winbar's file name (breadcrumbs etc.)
---@field statusline_extra? genja-statusline.StatuslinePart[] parts at the start of the statusline's right half (task counts etc.)
---@field clicks? genja-statusline.Clicks statusline parts that react to the mouse

---Called on a click: `button` is 'l', 'm' or 'r', `clicks` 1 for a single click.
---@alias genja-statusline.ClickFn fun(button: string, clicks: integer)

---@class genja-statusline.Clicks
---@field file? genja-statusline.ClickFn the file name
---@field branch? genja-statusline.ClickFn the git branch (shown from gitsigns' b:gitsigns_head)
---@field diagnostics? genja-statusline.ClickFn the diagnostics count (shown when there are any)

---Click ids in the %@...@ regions, in this order.
M.CLICK_NAMES = { 'file', 'branch', 'diagnostics' }

---@type genja-statusline.Opts
M.config = {
	statusline = true, -- set 'statusline'
	tabline = true, -- set 'tabline'
	winbar = true,  -- set 'winbar'
	rune = false,   -- display precise information about the cursor position
	rename = {},    -- extra function(name, buf) -> name, applied to tab labels
	winbar_extra = {}, -- function(buf, win) -> statusline string, after the file name
	statusline_extra = {}, -- function(buf) -> statusline string, right half, before the branch
	clicks = {},    -- file / branch / diagnostics -> function(button, clicks)
}

---Run the click handler with id `id` (index into CLICK_NAMES); from autoload/genja_statusline.vim.
---@param id integer
---@param clicks integer
---@param button string
function M.click(id, clicks, button)
	local name = M.CLICK_NAMES[id]
	if not name then
		return
	end
	local fn = M.config.clicks[name]
	if fn then
		fn(button, clicks)
	end
end

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
