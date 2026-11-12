--[[
	https://github.com/ojroques/nvim-hardline
]]

local u = require('genja-statusline.util')
local sl, hl = u.sl, u.hl

local M = {}

---Winbar names for plugin windows, by filetype; nvim shows them as [Scratch]
---or the plugin's internal buffer name (undotree_2, DAP Scopes) otherwise.
local FT_LABELS = {
	aerial = 'Outline',
	undotree = 'Undo tree',
	['neotest-summary'] = 'Tests',
	['neotest-output-panel'] = 'Test output',
	OverseerList = 'Tasks',
	['dap-view'] = 'Debug',
	['dap-repl'] = 'REPL',
	dapui_scopes = 'Scopes',
	dapui_stacks = 'Stacks',
	dapui_watches = 'Watches',
	dapui_breakpoints = 'Breakpoints',
	dapui_console = 'Console',
}

---Name of the file an aerial window outlines, without extension; '' when
---unknown. aerial keeps the source buffer in b:source_buffer.
---@param buf integer
---@return string
local function aerial_source(buf)
	local src = vim.b[buf].source_buffer
	if type(src) ~= 'number' or not vim.api.nvim_buf_is_valid(src) then
		return ''
	end
	local name = vim.api.nvim_buf_get_name(src)
	if name == '' then
		return ''
	end
	return vim.fn.fnamemodify(name, ':t:r')
end

---Strings from `winbar_extra`, after the file name. `%<` lets nvim cut them
---from the left when the window is too narrow, so the innermost part stays.
---A failing part is skipped: an error here would repeat on every redraw.
---@param buf integer
---@param win integer
---@return string
local function extras(buf, win)
	local parts = {}
	for _, part in ipairs(require('genja-statusline').config.winbar_extra or {}) do
		local ok, str = pcall(part, buf, win)
		if ok and type(str) == 'string' and str ~= '' then
			table.insert(parts, str)
		end
	end
	if #parts == 0 then
		return ''
	end
	return ' %<' .. table.concat(parts, ' ')
end

---@param path string
---@return string[]
local function components(path)
	local parts = {}
	for part in path:gmatch('[^/\\]+') do
		table.insert(parts, part)
	end
	return parts
end

---Names of the other buffers shown in diff mode in this tab.
---@param win integer
---@return string[][] path components per buffer
local function diff_peers(win)
	local peers = {}
	if not vim.wo[win].diff then
		return peers
	end
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if w ~= win and vim.wo[w].diff then
			local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if name ~= '' then
				table.insert(peers, components(name))
			end
		end
	end
	return peers
end

---Shortest tail of the path (file name plus as many parents as needed) that
---differs from the same-length tail of every diff peer. Without peers, the
---file name alone.
---@param path string
---@param peers string[][]
---@return string
local function distinct_tail(path, peers)
	local mine = components(path)
	local depth = 1
	for _, other in ipairs(peers) do
		local n = 1
		while n < #mine and n <= #other do
			local same = true
			for i = 0, n - 1 do
				if mine[#mine - i] ~= other[#other - i] then
					same = false
					break
				end
			end
			if not same then
				break
			end
			n = n + 1
		end
		depth = math.max(depth, n)
	end
	local tail = {}
	for i = #mine - depth + 1, #mine do
		table.insert(tail, mine[i])
	end
	return table.concat(tail, '/')
end

function M.render()
	local fname = vim.fn.fnamemodify(sl('%t'), ':r') -- top of path, no extension
	-- while the winbar is drawn, the current window is the one it belongs to
	local bufnr = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	local peers = diff_peers(win)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if #peers > 0 and path ~= '' and vim.bo[bufnr].buftype == '' then
		-- diff of same-named files: show enough parents to tell them apart
		fname = vim.fn.fnamemodify(distinct_tail(path, peers), ':r')
	end
	if fname == '' then
		fname = vim.bo[bufnr].filetype
	end
	if u.is_nameless(bufnr) then
		fname = u.NAMELESS
	end
	local ft = vim.bo[bufnr].filetype
	local label = FT_LABELS[ft]
	if label ~= nil then
		fname = label
	end
	if ft == 'aerial' then
		local src = aerial_source(bufnr)
		if src ~= '' then
			fname = label .. ': ' .. src
		end
	end
	-- %t already names a qf buffer ([Quickfix List]); add the command that built the list
	local qf_title = ''
	if vim.bo[bufnr].buftype == 'quickfix' then
		local title = vim.w[win].quickfix_title
		if type(title) == 'string' and title ~= '' then
			qf_title = ' ' .. title:gsub('%%', '%%%%')
		end
	end
	return (''
		.. hl('WinBarPath', fname)
		.. hl('WinBarModified', sl('%M')) -- modified flag
		.. hl('WinBarPath', sl('%r')) -- read-only [RO]
		.. hl('WinBarPath', qf_title)
		.. extras(bufnr, win)
	)
end

return M
