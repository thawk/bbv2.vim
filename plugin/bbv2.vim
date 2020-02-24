function! s:InsideBoostBuildProj()
    let is_b2_proj = 0

    let tasks = {
                \ "Build" : {
                \   "command" : "b2",
                \   "isDetected" : 1,
                \   "detectedName" : "b2: ",
                \ }}

    for l:name in ["Jamfile", "Jamfile.v2", "Jamfile.jam", "Jamroot", "Jamroot.v2", "Jamroot.jam"]
        for l:p in findfile(l:name, ".;", -1)
            let is_b2_proj = 1
            if exists("g:spacevim_version")
                let tasks = extend(tasks, s:get_b2_tasks(l:p))
            endif
        endfor
    endfor

    if is_b2_proj && exists("g:spacevim_version")
        let b:b2_tasks = tasks
    endif
    return is_b2_proj
endfunction

function! s:get_b2_tasks(filename) abort
    let relative_filename = fnamemodify(a:filename, ":.:h")
    let target_types = ["exe", "lib", "install", "alias", "unit-test", "run"]
    let re = "^\\s*\\(" . join(target_types, "\\|") . "\\)\\s\\+\\([a-zA-Z0-9_-]\\+\\)\\(\\s*:.*\\|\\s*\\)$"

    if filereadable(a:filename)
        let targets = []

        for line in readfile(a:filename, '')
            if line =~# re
                call add(targets, substitute(line, re, "\\1 \\2", ""))
            endif
        endfor
        let targets = uniq(sort(targets))

        let tasks = {}

        for target in targets
            call extend(tasks, {
                        \ target : {
                        \   "command" : "b2 " . relative_filename . "//" . split(target)[1],
                        \   "isDetected" : 1,
                        \   "detectedName" : "b2: ",
                        \ }})
        endfor

        return tasks
    endif

    return {}
endfunction

function! s:detect_b2_tasks() abort
    if !exists("b:b2_tasks")
        " sometimes, s:InsideBoostBuildProj() is not called, so we call it now
        call s:InsideBoostBuildProj()
    endif

    return get(b:, "b2_tasks", {})
endfunction

if exists("g:spacevim_version")
    " register SpaceVim task provider
    try
        call SpaceVim#plugins#tasks#reg_provider(funcref('s:detect_b2_tasks'))
    endtry
endif

augroup b2_compiler_detect
    " Change compiler to b2 inside Boost Build projects
    au!
    au VimEnter,BufNewFile,BufReadPost * if !get(g:, 'bbv2_disable_project_detect', 0) && &makeprg=='make' && s:InsideBoostBuildProj() | compiler b2 | endif
    au FileType bbv2 if !get(g:, 'bbv2_disable_project_detect', 0) && &makeprg=='make' | compiler b2 | endif
augroup END

" vi: ft=vim:tw=72:ts=4:fo=w2croql
