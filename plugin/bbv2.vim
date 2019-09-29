function! s:InsideBoostBuildProj()
    for l:name in ["Jamfile", "Jamfile.v2", "Jamfile.jam", "Jamroot", "Jamroot.v2", "Jamroot.jam"]
        for l:p in findfile(l:name, ".;", -1)
            return 1
        endfor
    endfor

    return 0
endfunction

augroup b2_compiler_detect
    " Change compiler to b2 inside Boost Build projects
    au!
    au VimEnter,BufNewFile,BufReadPost * if !get(g:, 'bbv2_disable_project_detect', 0) && &makeprg=='make' && s:InsideBoostBuildProj() | compiler b2 | endif
    au FileType bbv2 if !get(g:, 'bbv2_disable_project_detect', 0) && &makeprg=='make' | compiler b2 | endif
augroup END

" vi: ft=vim:tw=72:ts=4:fo=w2croql
