--[[
	Each status line item (%) is of the form:
	All fields except the {item} are optional.
	  %-0{minwid}.{maxwid}{item}
	  %= alignment / splitter
	  %< where to truncate
	  %# set highlight group
	  %* restore to normal (see hl-User1..9)
	Empty groups like this will disappear if no flags are set
	:set statusline=...%(\ [%M%R%H]%)...
	:redrawstatus will force an update
]]

local u = require('genja-statusline.util')
local sl, hl = u.sl, u.hl
local DOTm, Space = u.DOTm, u.Space

local M = {}

-- plain in terminals, a Nerd Font glyph in the GUI; other picks: ∘ ·
local Dirseparator = (vim.fn.has('gui_running') == 1 and '󰞱' or '·')

local function os_icon()
	if vim.fn.has('mac') == 1 then
		return ''
	elseif vim.fn.has('win32') == 1 then
		return '󰖳'
	elseif vim.fn.has('linux') == 1 then
		return ''
	elseif vim.fn.has('bsd') == 1 then
		return 'bsd'
	elseif vim.fn.has('unix') == 1 then
		return 'posix'
	end
	return 'other'
end
local OS_ICON = os_icon()

local mode_map = {
	n = 'norm', i = 'ins',
	v = '  ☭ vis', V = '  ☭vlin', ['\22'] = '  ☭vblk', -- \22 is CTRL-V
	c = 'comm', t = 'term', R = 'irep',
}

local function get_mode()
	local mode = vim.fn.mode()
	return mode_map[mode] or ('«' .. mode .. '»')
end

---Git branch from gitsigns (b:gitsigns_head), '' when none; clickable with `clicks.branch`.
---@return string
local function branch()
	local head = vim.b.gitsigns_head
	if type(head) ~= 'string' or head == '' then
		return ''
	end
	return u.click('branch', hl('StatusLineWeak', ' ' .. head:gsub('%%', '%%%%')) .. Space)
end

---Error and warning counts of the buffer (`E2 W1`), '' when none; clickable with `clicks.diagnostics`.
---@return string
local function diagnostics()
	local count = vim.diagnostic.count(0)
	local parts = {}
	local function add(severity, group, letter)
		local n = count[severity] or 0
		if n > 0 then
			table.insert(parts, hl(group, letter .. n))
		end
	end
	add(vim.diagnostic.severity.ERROR, 'DiagnosticError', 'E')
	add(vim.diagnostic.severity.WARN, 'DiagnosticWarn', 'W')
	if #parts == 0 then
		return ''
	end
	return u.click('diagnostics', table.concat(parts, ' ')) .. Space
end

---Strings from `statusline_extra`, joined with a space, each followed by one.
---A failing part is skipped: an error here would repeat on every redraw.
---@param buf integer
---@return string
local function extras(buf)
	local out = ''
	for _, part in ipairs(require('genja-statusline').config.statusline_extra or {}) do
		local ok, str = pcall(part, buf)
		if ok and type(str) == 'string' and str ~= '' then
			out = out .. str .. Space
		end
	end
	return out
end

function M.render()
	local config = require('genja-statusline').config

	local _mod = string.format('%1s', sl('%M'))
	if _mod == '-' then _mod = ' ' end

	local _hwq, _ro = sl('%h%w%q '), sl('%R')
	-- [RO] only where it says something: help, preview and quickfix windows are read-only anyway.
	-- _hwq is at least ' ', so test what is in it (2026-11-10: the old `if _hwq` never showed [RO]).
	if vim.trim(_hwq) ~= '' then
		_ro = ''
	end

	local _rune, _pos = '', ''
	if config.rune or vim.g.genja_statusline_rune then
		_rune = ' rune{%03b %04B}'
		_pos = ' pos{%04o %O}'
	end

	local _showcmd = sl('%S')
	local _file = sl('%.50f'):gsub('[~\\/]', '/')
	if u.is_nameless(vim.api.nvim_get_current_buf()) then
		_file = u.NAMELESS
	end
	_file = vim.fn.fnamemodify(_file, ':r') -- no extension
	_file = table.concat(vim.split(_file, '/+', { trimempty = true }), hl('StatusLineWeak', Dirseparator))

	local _ft_fmt_enc = table.concat({ vim.bo.filetype, vim.bo.fileformat, vim.bo.fileencoding }, ' ')
	local _mode = string.format('%7s', get_mode())

	return table.concat({
		hl('StatusLineWeak', _mode .. Space .. DOTm .. sl('%n') .. DOTm .. Space), -- %n is bufnr

		u.click('file', _file), _mod, _hwq, -- file/buffer name and flags
		' %<',
		'%=',
		extras(vim.api.nvim_get_current_buf()),
		branch(),
		diagnostics(),
		'%a', -- argument list status
		Space,
		'%<',
		hl('StatusLineWeak', _ft_fmt_enc),
		'%<',
		_ro,
		hl('StatusLineWeak', Space .. DOTm .. Space),

		OS_ICON,
		_showcmd,

		_rune,
		_pos,

		'%3cc %3lʟ', Space, '%-3L␤ %P', -- column, line, total lines, percentage
	})
end

return M
