# genja-statusline.nvim

Personal statusline, tabline and winbar. Loaded from disk by the config's
`../../lua/lazyp/new/genja-statusline.lua` with `lazy = false`. Read README.md
and `doc/genja-statusline.txt`.

How this file is kept: one heading per feature, one bullet per decision.
Unmarked bullets were stated by jaro. `(inferred)` marks Claude's reading of the
code or history: confirm or delete. `Hint:` is a working note for Claude.

## Layout

- `lua/genja-statusline/init.lua`: `setup(opts)` with `statusline`, `tabline`, `winbar`, `rune`, `rename`, `winbar_extra`.
- `statusline.lua`, `tabline.lua`, `winbar.lua`, `util.lua`: one part each.
- `keypath.lua`: json/yaml key path at the cursor (treesitter); not wired up by default.
- `plugin/genja-statusline.lua`: runtime glue.
- `autoload/genja_statusline.vim`: `noop` click handler for the tabline outside the labels.
- `zold/`: the old pre-plugin files. (inferred: reference only, don't edit)

## Decisions

- Split out of the config as its own plugin; next steps are its own GitHub repo, then removing it from the home-nvim repo (`todo-2026-neovim011.txt`).
- The config uses `laststatus = 3` (one global statusline).
- It still needs three helpers from the config: `require('genja.fn').Join`, global `Split`, global `OsDependant` (README). Removing that tie is open. (inferred)
- Breadcrumbs from other plugins are embedded through `winbar_extra`; genja owns 'winbar'. The config passes dropbar.nvim's `_G.dropbar()` this way. (idea 13)
- Hint: `setup()` options are passed by the spec; an earlier bug was opts never reaching `setup()`.
- Tabline areas outside the labels get a no-op click handler: nvim's "click without label = next tab" made nvim-qt window resizes (frameless, `ginit.vim`) walk to the last tab. Vimscript autoload, not a Lua global. (idea 32)
