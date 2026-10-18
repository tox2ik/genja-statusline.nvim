# genja-statusline.nvim

A small personal statusline, tabline and winbar for Neovim.

- **Statusline**: mode, buffer number, file path (extension dropped, custom
  path separator), flags, filetype / fileformat / encoding, OS icon, pending
  command, cursor position.
- **Tabline**: one label per tab, named after its current buffer. The close
  button doubles as a window count. Labels shrink the further they are from
  the current tab when the line gets too long.
- **Winbar**: file name without extension, modified, read-only and quickfix
  flags, then any `winbar_extra` parts (breadcrumbs and the like).
- **Key path** (optional module): the json/yaml key path at the cursor, e.g.
  `spec.containers[0].image`, from treesitter.

## Requirements

- Neovim 0.9 or newer
- A [Nerd Font](https://www.nerdfonts.com/) for the icons
- Three helpers that are not part of this plugin (yet) and have to exist
  before the first redraw:
  - `require('genja.fn').Join(list, sep)`
  - a global `Split(str, sep)`
  - a global `OsDependant(windows, linux, mac, bsd, posix, other)`

## Install

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ 'USERNAME/genja-statusline.nvim', opts = {} }
```

Built-in `vim.pack` (Neovim 0.12+):

```lua
vim.pack.add({ 'https://github.com/USERNAME/genja-statusline.nvim' })
require('genja-statusline').setup()
```

## Setup

Nothing is changed until `setup()` is called. These are the defaults:

```lua
require('genja-statusline').setup({
	statusline = true, -- set 'statusline'
	tabline = true,    -- set 'tabline'
	winbar = true,     -- set 'winbar'
	rune = false,      -- show character code and byte offset under the cursor
	rename = {},       -- extra function(name, buf) -> name for tab labels
	winbar_extra = {}, -- function(buf, win) -> statusline string, after the file name
})
```

`rune` can also be toggled at runtime with `vim.g.genja_statusline_rune`.

Tab labels for [oil.nvim](https://github.com/stevearc/oil.nvim) buffers are
shown as `o:<directory>`. Add your own rules with `rename`:

```lua
require('genja-statusline').setup({
	rename = {
		function(name, buf)
			if vim.bo[buf].filetype == 'help' then return 'h:' .. name end
			return name
		end,
	},
})
```

`winbar_extra` parts run in order and are joined with a space. Return `''`
to show nothing; a part that errors is skipped. They come after a `%<`, so a
narrow window cuts them from the left. Example with the key path module:

```lua
require('genja-statusline').setup({
	winbar_extra = {
		function(buf, win) return require('genja-statusline.keypath').render(buf, win) end,
	},
})
```

Another plugin's bar can be embedded the same way, e.g. dropbar.nvim with its
`bar.enable = false` and a part returning `_G.dropbar()`.

The pending command (`%S`) only shows up with `vim.o.showcmdloc = 'statusline'`.

## Highlight groups

| Group            | Used for                                        | Default link   |
| ---------------- | ----------------------------------------------- | -------------- |
| `StatusLineWeak` | dimmed parts and separators                     | `StatusLineNC` |
| `WinBarPath`     | winbar file name and flags, tabline left edge   | `WinBar`       |
| `WinBarModified` | winbar modified flag                            | `WinBar`       |

The tabline also uses the standard `TabLine`, `TabLineSel` and `TabLineFill`.

## License

MIT
