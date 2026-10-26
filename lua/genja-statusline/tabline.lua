local u = require('genja-statusline.util')
local hl = u.hl
local Join = require('genja.fn').Join
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


local wincount_label = {
    -- [1] = '⋅',
    [1] = '',
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
	function(nam, buf)
		local z = nam
		if 'oil' == vim.bo[buf].filetype then
			z = vim.api.nvim_buf_get_name(buf)
			z = z:gsub([[/$]], '') -- want last dir (:path:tail)
			z = 'o:' .. vim.fn.fnamemodify(z, ':p:t')
		end
		return z
	end,
}

local function bufname(tabpage, charsleft)
	local win = vim.api.nvim_tabpage_get_win(tabpage)
	local buf = vim.api.nvim_win_get_buf(win)
	local bn = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t:r')
	if bn == Empty then bn = vim.bo[buf].filetype end
	if bn == Empty then bn = 'none' end
	for _, tr in ipairs(rename_buf_fns) do
		bn = tr(bn, buf)
	end
	for _, tr in ipairs(require('genja-statusline').config.rename) do
		bn = tr(bn, buf)
	end

	-- out of room: shorten labels, more so the further they are from the current tab
	local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
	local distance = math.abs(vim.fn.tabpagenr() - tabnum)
	if charsleft < 0 then
		if distance > 3 then
			if #bn > 3 then return bn:sub(1, 3) .. Ellipsis end
		elseif distance > 2 then
			if #bn > 4 then return bn:sub(1, 4) .. Ellipsis end
		elseif distance > 1 then
			if #bn > 12 then return bn:sub(1, 12) .. Ellipsis end
		end
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

-- returns the tabline items and a rough count of the width they take
-- clicks outside the labels go here and do nothing (autoload/genja_statusline.vim);
-- without it nvim goes to the next tab, so nvim-qt resize drags walked the tabs
local Noclick = '%@genja_statusline#noop@'

local function tablabels(charsleft)
	local tl = { Noclick, hl('WinBarPath', Triangle_upper), '' }
	local total = 2 -- triangle, close button
	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnum = vim.api.nvim_tabpage_get_number(tabpage)
		local bn = bufname(tabpage, charsleft)
		local sp = separator(tabpage, charsleft)
		table.insert(tl, hilite(tabpage))
		table.insert(tl, '%' .. tabnum .. 'T')
		table.insert(tl, bn)
		table.insert(tl, close_tab_button(tabnum, tabpage))
		table.insert(tl, hl('StatusLineWeak', sp))
		total = total + #sp + #bn + 1 -- separator, label, close button
	end
	table.insert(tl, '%<')
	table.insert(tl, '%<')
	table.insert(tl, '%#TabLineFill#' .. Noclick)
	table.insert(tl, '%=%#TabLine#%999X' .. Close)
	return tl, total
end

local Ww = 0

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
	return Join(tl)
end

return M
