-- Key path at the cursor in json/jsonc/yaml, e.g. `spec.containers[0].image`.
-- Walks from the treesitter node under the cursor up to the root, so the cost
-- follows nesting depth, not file size. Needs the json/yaml parsers.
--
-- Not wired up. To show it in the winbar, add a part in the spec's opts
-- (lua/lazyp/new/genja-statusline.lua):
--
--   winbar_extra = {
--   	function(buf, win) return require('genja-statusline.keypath').render(buf, win) end,
--   },
--
-- With dropbar in winbar_extra too, json/yaml would show both; let the dropbar
-- part return '' when `require('genja-statusline.keypath').supports(buf)`.

local M = {}

local FILETYPES = { json = true, jsonc = true, json5 = true, yaml = true, ['yaml.ansible'] = true }
local KEYED = { pair = true, block_mapping_pair = true, flow_pair = true }
local LISTS = { array = true, block_sequence = true, flow_sequence = true }
local MAX_WIDTH = 60

---Whether `buf` is a filetype the key path is built for.
---@param buf integer
---@return boolean
function M.supports(buf)
	return FILETYPES[vim.bo[buf].filetype] == true
end

---Position of `child` among the named, non-comment children of `list`.
---@param list TSNode
---@param child TSNode
---@return integer index 0-based
local function index_of(list, child)
	local i = 0
	for node in list:iter_children() do
		if node:id() == child:id() then
			return i
		end
		if node:named() and node:type() ~= 'comment' then
			i = i + 1
		end
	end
	return i
end

---Key path at the cursor of `win`, plain text ('' when there is none).
---@param buf integer
---@param win integer
---@return string
function M.get(buf, win)
	local cursor = vim.api.nvim_win_get_cursor(win)
	-- the tree comes from treesitter highlighting; no parser means no path
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = buf,
		pos = { cursor[1] - 1, cursor[2] },
		ignore_injections = true,
	})
	if not ok or not node then
		return ''
	end
	local path = ''
	local child = nil
	while node do
		local kind = node:type()
		if KEYED[kind] then
			local key = node:field('key')[1]
			if key then
				local text = vim.treesitter.get_node_text(key, buf):gsub('^["\']', ''):gsub('["\']$', '')
				path = '.' .. text .. path
			end
		elseif LISTS[kind] and child then
			path = '[' .. index_of(node, child) .. ']' .. path
		end
		child = node
		node = node:parent()
	end
	return (path:gsub('^%.', ''))
end

---Key path for the winbar: highlighted, `%` escaped, cut from the left.
---@param buf integer
---@param win integer
---@return string
function M.render(buf, win)
	if not M.supports(buf) then
		return ''
	end
	local path = M.get(buf, win)
	if path == '' then
		return ''
	end
	if vim.fn.strchars(path) > MAX_WIDTH then
		path = '…' .. vim.fn.strcharpart(path, vim.fn.strchars(path) - MAX_WIDTH + 1)
	end
	return '%#WinBarPath#' .. path:gsub('%%', '%%%%') .. '%*'
end

return M
