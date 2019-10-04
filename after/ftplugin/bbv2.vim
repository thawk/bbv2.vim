if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

" Make sure the continuation lines below do not cause problems in
" compatibility mode.
let s:save_cpo = &cpo

setlocal commentstring=#%s

if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
    let b:browsefilter = "Jamfiles (Jamroot Jamfile *.jam)\tJamroot*;Jamfile*;*.jam\n" .
	  \ "All Files (*.*)\t*.*\n"
endif

if exists("loaded_matchit")
    let s:sol = '\%(\s;\s\+\|^\s*\)\@<='  " start of line
    let b:match_words =
                \ s:sol.'if\>:' . s:sol.'else\>'
endif

" Undo the stuff we changed.
let b:undo_ftplugin = "setlocal cms< | unlet! b:browsefilter b:match_words"

" Restore the saved compatibility options.
let &cpo = s:save_cpo
unlet s:save_cpo
