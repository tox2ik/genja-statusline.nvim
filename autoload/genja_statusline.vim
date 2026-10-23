" Click handler for tabline areas outside the labels (tabline.lua).
" Nvim switches to the next tab on a click where there is no label, and opens
" a new tab on a double click; this region takes those clicks and does nothing.
" Frameless nvim-qt sends resize drags on the top edge as clicks on row 0.
function! genja_statusline#noop(minwid, clicks, button, mods) abort
endfunction
