local u = require('genja-statusline.util')
local hl = u.hl
local Space, Empty = u.Space, u.Empty

local M = {}

local Triangle_upper = ' ' -- left edge; ' ' is the Nerd Font triangle
local Close = 'x'
local Ellipsis = '…'
local Tabsep = '∘'

if vim.fn.has('gui_running') == 1 then
	Tabsep = ''
	Close = '󱀬'
end

-- window count per tab, shown on the close button; one window: no mark
local wincount_label = {
	[1] = '', -- was '⋅'
	[2] = '²', [3] = '³', [4] = '⁴', [5] = '⁵',
	[6] = '⁶', [7] = '⁷', [8] = '⁸', [9] = '⁹', [10] = '¹⁰',
}

-- the close button doubles as a window count for the tab
local function close_tab_button(tabnum, tabpage)
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)
	local x = wincount_label[#wins] or Close
	return '%' .. tabnum .. 'X' .. x
end

local function hilite(tabpage)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	if tabnum == vim.fn.tabpagenr() then
		return '%#TabLineSel#'
	end
	return '%#TabLine#'
end

-- function(name, buf) -> name; more can be added with setup({ rename = { ... } })
local rename_buf_fns = {
	-- oil: `o:<dir name>`
	function(name, buf)
		if vim.bo[buf].filetype ~= 'oil' then
			return name
		end
		local dir = vim.api.nvim_buf_get_name(buf):gsub('/$', '')
		return 'o:' .. vim.fn.fnamemodify(dir, ':p:t')
	end,
}

local function bufname(tabpage, charsleft)
	local win = vim.api.nvim_tabpage_get_win(tabpage)
	local buf = vim.api.nvim_win_get_buf(win)
	local bn = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t:r')
	if bn == Empty then
		bn = vim.bo[buf].filetype
	end
	if bn == Empty then
		bn = 'none'
	end
	for _, rename in ipairs(rename_buf_fns) do
		bn = rename(bn, buf)
	end
	for _, rename in ipairs(require('genja-statusline').config.rename) do
		bn = rename(bn, buf)
	end

	if charsleft >= 0 then
		return bn
	end
	-- out of room: shorten labels, more so the further they are from the current tab
	local distance = math.abs(vim.fn.tabpagenr() - vim.api.nvim_tabpage_get_number(tabpage))
	local max = nil
	if distance > 3 then
		max = 3
	elseif distance > 2 then
		max = 4
	elseif distance > 1 then
		max = 12
	end
	if max and #bn > max then
		return bn:sub(1, max) .. Ellipsis
	end
	return bn
end

local function separator(tabpage, charsleft)
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = math.abs(vim.fn.tabpagenr() - tabnum)
	if charsleft < 0 then
		if distance > 2 then
			return ''
		elseif distance > 1 then
			return Tabsep .. Space
		end
	end
	return Space .. Tabsep .. Space
end

-- clicks outside the labels go here and do nothing (autoload/genja_statusline.vim);
-- without it nvim goes to the next tab, so nvim-qt resize drags walked the tabs
local Noclick = '%@genja_statusline#noop@'

---Tabline items and a rough count of the width they take.
---@param charsleft integer below 0: out of room, labels get shorter
local function tablabels(charsleft)
	local tl = { Noclick, hl('WinBarPath', Triangle_upper), '' }
	local total = 2 -- triangle, close button
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
		local bn = bufname(tabpage, charsleft)
		local sp = separator(tabpage, charsleft)
		vim.list_extend(tl, {
			hilite(tabpage),
			'%' .. tabnum .. 'T',
			bn,
			close_tab_button(tabnum, tabpage),
			hl('StatusLineWeak', sp),
		})
		total = total + #sp + #bn + 1 -- separator, label, close button
	end
	vim.list_extend(tl, { '%<', '%<', '%#TabLineFill#' .. Noclick, '%=%#TabLine#%999X' .. Close })
	return tl, total
end

local Ww = 0 -- editor width, kept while in the command line

function M.render()
	-- keep the last known width while in the command line
	if vim.fn.mode():sub(1, 1) ~= 'c' then
		Ww = tonumber(vim.o.columns) or 0
	end
	local tl, total = tablabels(0)
	local diff = Ww - total
	if diff <= 0 then
		tl = tablabels(diff)
	end
	return table.concat(tl)
end

return M
