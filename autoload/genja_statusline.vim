" Click handler for tabline areas outside the labels (tabline.lua).
" Nvim switches to the next tab on a click where there is no label, and opens
" a new tab on a double click; this region takes those clicks and does nothing.
" Frameless nvim-qt sends resize drags on the top edge as clicks on row 0.
function! genja_statusline#noop(minwid, clicks, button, mods) abort
endfunction

" Click handler for the statusline parts in the `clicks` option; minwid is the part's id.
function! genja_statusline#click(minwid, clicks, button, mods) abort
	call luaeval("require('genja-statusline').click(_A[1], _A[2], _A[3])", [a:minwid, a:clicks, a:button])
endfunction
