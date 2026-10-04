-- [[ʟ %l/%L c %c]]

-- vim.o.statusline = ' %f %m%r%h%w%y [%{&fileencoding}] [%{&fileformat}]'
-- vim.o.statusline = ' %f %m%r%h%w%y [%{&fileencoding}] [%{&fileformat}]'

--[[
	Each status line item (%) is of the form:
	All fields except the {item} are optional.
	  %-0{minwid}.{maxwid}{item}
	  %= alignment / splitter
	  %< where to truncate
	  %# set highlight group
	  %* ?? takes value from minwid? diff is applied to StatusLineNC? see hl-User1..9
	  %* ?? restore to normal
	  %0* restore to normal
	Empty groups like this will disappear if no flags are set
	:set statusline=...%(\ [%M%R%H]%)...
	:redrawstatus will force an update
]]


Join = require('genja.fn').Join



local function sl(a, b) b=b or {}; return vim.api.nvim_eval_statusline(a, b).str end
local function hl(hiGroup, s) return  '%#' .. hiGroup .. '#' .. s .. '%*' end

local DOTm = '·'
local Space = ' '
local Empty = ''

local Tabsep = '' -- '%=%='
local Dirseparator = '󰞱' -- '⧸' '/'

local function get_os_icon()
	return OsDependant( '󰖳', '', '', 'bsd', 'posix', 'other')
end

-- i = "", n = "", v = "vis", V = "vlin", [''] = "vblk",
local mode_map = {
	n = "norm", i = "ins",
	v = "  ☭ vis", V = "  ☭vlin", [''] = "  ☭vblk",
	c = "comm", t = "term", R = 'irep', }
local function get_mode()
	local mode = vim.fn.mode()
	return mode_map[mode]
	    or ('«' .. mode ..'»')
end

local wincount_label = {
	[1] =   '⋅', [2] =   '²', [3] =   '³', [4] =   '⁴', [5] =   '⁵',
	[6] =   '⁶', [7] =   '⁷', [8] =   '⁸', [9] =   '⁹', [10] =  '¹⁰'}
local function tl_close_tab_button(tabnum, tabpage)
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)
	local x = '󱀬'; if wincount_label[#wins] then x = wincount_label[#wins] end
	return '%'.. tabnum .. 'X'..x
end

local function tl_hilite(tabpage)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local hilite = '%#TabLine#'
	if tabnum == vim.fn.tabpagenr() then
		hilite = '%#TabLineSel#' end
	return hilite
end

local rename_buf_fns = {
	--[[ function(nam, buf) return nam end, ]]--
	function(nam, buf)
		local z = nam
		if 'oil' == vim.bo[buf].filetype then
			z = vim.api.nvim_buf_get_name(buf)
			z = z:gsub([[/$]], '') -- want last dir (:path:tail)
			z = 'o:'..vim.fn.fnamemodify( z, ':p:t')
		end
		return z
	end,
}
local tl_bufname = function(tabpage, charsleft)
	local win = vim.api.nvim_tabpage_get_win(tabpage)
	local buf = vim.api.nvim_win_get_buf(win)
	local bn = vim.fn.fnamemodify( vim.api.nvim_buf_get_name(buf), ':t:r')
	if bn == Empty then
		bn = vim.api.nvim_buf_get_option(buf, 'filetype'); end
	if bn == Empty then
		bn = 'none'; end
	for _, tr in pairs(rename_buf_fns) do
		bn = tr(bn, buf)
	end
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = vim.fn.abs(vim.fn.tabpagenr() - tabnum)
	-- if tabnum == 1 then
		-- bn = ' ' .. bn
	-- end
	if charsleft < 0 then
		if distance > 3 then
			if #bn > 3 then
				return bn:sub(1, 3) .. '…'
			end
		elseif distance > 2 then
			if #bn > 4 then
				return bn:sub(1, 4) .. '…'
			end
		elseif distance > 1 then
			if #bn > 12 then
				return bn:sub(1, 12) .. '…'
			end
		end
	end
	return bn
end

local function tl_separator(tabpage, charsleft)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = vim.fn.abs(vim.fn.tabpagenr() - tabnum)
	if charsleft < 0 then
		if distance > 2 then
			return ''
		elseif distance > 1 then
			return Tabsep..Space
		end
	end
	return Space..Tabsep..Space
end

local total = 0
local function count_len(str)
	total = total + #str
	return str
end

local Triangle_upper = ' ' -- must use Nerd Font ?
Triangle_upper = '\\'
Triangle_upper = ' '




local function tablabels(charsleft)
	-- local tl = {  };
	total = 0
	local tl = { hl('WinBarPath', Triangle_upper ), '' };
	total = total + 2 -- triangle, close button
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
		local bn = tl_bufname(tabpage, charsleft)
		local sp = tl_separator(tabpage, charsleft)
		table.insert(tl, tl_hilite(tabpage))
		table.insert(tl, '%' .. tabnum .. 'T') -- this is only necessary if we use statusline %items ? - but we resolve them manually with sl()...
		table.insert(tl, bn)
		table.insert(tl, tl_close_tab_button(tabnum, tabpage))
		table.insert(tl, hl('StatusLineWeak', sp))
		count_len(sp) -- tab separator
		count_len(bn)  -- tab label
		count_len('x') -- close button
    end
	table.insert(tl, '%<')
	table.insert(tl, '%<')
	table.insert(tl, '%#TabLineFill#%T')
	table.insert(tl, '%=%#TabLine#%999X󱀬')
	return tl
end

function ctot(Ww)
	if false then
		local extra = 6 -- :E+T:t
		extra = extra + 2 -- mode
		extra = extra + #tostring(Ww) + #tostring(total) + #tostring(Ww-total)
		extra = extra + #tostring(Ww - total - extra)
		return extra
	end
	return 0
end

local Ww = 0
function Tabline()
	local M = (vim.fn.mode()):sub(1,1)
	local N = ''
	if M == 'c' then
		Ww = Ww
	else
		-- Ww = tonumber(vim.api.nvim_command_output("echo &columns")) or 0
		Ww = tonumber(vim.o.columns) or 0
	end
	local tl = tablabels(0)
	-- local Total = total
	-- local Dotal = 0
	local extra = ctot(Ww)
	local diff = Ww - total - extra
	if diff > 0 then
		-- N = M..'.'..Ww..':E'..extra..'+T'..Total..'t'..Dotal..':'..(diff)
		return N..Join(tl)
	else
		tl = tablabels(diff)
		-- Dotal = total
		diff = Ww - total - extra
		-- N = M..'.'..Ww..':E'..extra..'+T'..Total..'t'..Dotal..':'..(diff)
		return N..Join(tl)
	end
end

function Statusline()
	local sline = ''

	local _mod = string.format('%1s', sl('%M'))
	if _mod == '-' then _mod = ' ' end

	local _hwq, _ro = sl('%h%w%q '), sl('%R')
	if _hwq then _ro = '' end

	local _rune, _pos = '', ''
	if vim.g.genja_statusline_rune then
		_rune = ' rune{%03b %04B}'
		_pos = ' pos{%04o %O}'
	end

	local _showcmd, _file = sl('%S'), ''
	_file = sl('%.50f'):gsub('[~\\/]', '/')
	_file = vim.fn.fnamemodify(_file, ':r') -- no extension
	_file = Join(Split(_file, '/'), hl('StatusLineWeak', Dirseparator))

	local _ft_fmt_enc =  Join({ vim.bo['filetype'], vim.bo['fileformat'], vim.bo['fileencoding']}, ' ')
	local _mode = string.format('%7s', get_mode())

	local elts = {

		hl('StatusLineWeak', _mode..Space..DOTm..sl('%n')..DOTm..Space), -- %n is bufnr

		_file, _mod, _hwq, -- file/buffer name and ro status
		' %<',
		'%=',
		'%a', -- argument list status
		Space,
		'%<',
		hl('StatuslineWeak', _ft_fmt_enc),
		'%<',
		_ro,
		hl('StatusLineWeak', Space..DOTm..Space),

		get_os_icon(),
		_showcmd,

		_rune,
		_pos,

		'%3cc %3lʟ', Space, '%-3L␤ %P', -- column line total lines percentage
	}
	return Join(elts)
end


return {
	Statusline = Statusline,
	Tabline = Tabline
}


