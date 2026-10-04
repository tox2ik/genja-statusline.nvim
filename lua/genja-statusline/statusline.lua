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
local Join = require('genja.fn').Join
-- Split and OsDependant are expected to exist as globals
local DOTm, Space = u.DOTm, u.Space

local M = {}

local Dirseparator = '󰞱'

local function get_os_icon()
	return OsDependant('󰖳', '', '', 'bsd', 'posix', 'other')
end

local mode_map = {
	n = 'norm', i = 'ins',
	v = '  ☭ vis', V = '  ☭vlin', ['\22'] = '  ☭vblk', -- \22 is CTRL-V
	c = 'comm', t = 'term', R = 'irep',
}

local function get_mode()
	local mode = vim.fn.mode()
	return mode_map[mode] or ('«' .. mode .. '»')
end

function M.render()
	local config = require('genja-statusline').config

	local _mod = string.format('%1s', sl('%M'))
	if _mod == '-' then _mod = ' ' end

	local _hwq, _ro = sl('%h%w%q '), sl('%R')
	-- NOTE: _hwq is never nil, so this always clears the read-only flag.
	-- Kept as it was in the original config.
	if _hwq then _ro = '' end

	local _rune, _pos = '', ''
	if config.rune or vim.g.genja_statusline_rune then
		_rune = ' rune{%03b %04B}'
		_pos = ' pos{%04o %O}'
	end

	local _showcmd = sl('%S')
	local _file = sl('%.50f'):gsub('[~\\/]', '/')
	_file = vim.fn.fnamemodify(_file, ':r') -- no extension
	_file = Join(Split(_file, '/'), hl('StatusLineWeak', Dirseparator))

	local _ft_fmt_enc = Join({ vim.bo.filetype, vim.bo.fileformat, vim.bo.fileencoding }, ' ')
	local _mode = string.format('%7s', get_mode())

	return Join({
		hl('StatusLineWeak', _mode .. Space .. DOTm .. sl('%n') .. DOTm .. Space), -- %n is bufnr

		_file, _mod, _hwq, -- file/buffer name and flags
		' %<',
		'%=',
		'%a', -- argument list status
		Space,
		'%<',
		hl('StatusLineWeak', _ft_fmt_enc),
		'%<',
		_ro,
		hl('StatusLineWeak', Space .. DOTm .. Space),

		get_os_icon(),
		_showcmd,

		_rune,
		_pos,

		'%3cc %3lʟ', Space, '%-3L␤ %P', -- column, line, total lines, percentage
	})
end

return M
