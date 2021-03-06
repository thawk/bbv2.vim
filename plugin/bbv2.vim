if exists(":Tagbar")
    let g:tagbar_type_bbv2 = {
                \ 'ctagstype' : 'bbv2',
                \ 'kinds' : [
                \     't:Targets:0:0',
                \     'c:Classes and Modules:0:1',
                \     'r:Rules:0:1',
                \     'l:Local Rules:1:1',
                \ ],
                \ 'sort' : 0,
                \ 'deffile' : expand('<sfile>:p:h:h') . '/ctags/bbv2.cnf',
                \ }
endif

let s:task_tpl = {
            \   "isDetected" : 1,
            \   "detectedName" : "b2: ",
            \ }

function! s:InsideSpaceVim()
    return exists("g:spacevim_version")
endfunction

function! s:InsideBoostBuildProj()
    let is_b2_proj = 0

    let tasks = {}

    for l:name in ["Jamfile", "Jamfile.v2", "Jamfile.jam", "Jamroot", "Jamroot.v2", "Jamroot.jam"]
        for l:p in findfile(l:name, ".;", -1)
            let is_b2_proj = 1
            if s:InsideSpaceVim()
                let tasks = extend(tasks, s:get_b2_tasks(l:p))
            endif
        endfor
    endfor

    if is_b2_proj
        let b:b2_detected_tasks = tasks
    endif
    return is_b2_proj
endfunction

function! s:get_b2_tasks(filename) abort
    let relative_path = fnamemodify(a:filename, ":.:h")
    let target_types = ["exe", "lib", "install", "alias", "unit-test", "run"]
    let re = "^\\s*\\(" . join(target_types, "\\|") . "\\)\\s\\+\\([a-zA-Z0-9_-]\\+\\)\\(\\s*:.*\\|\\s*\\)$"

    if filereadable(a:filename)
        let tasks = {}

        call extend(tasks, {
                    \ relative_path : extend(copy(s:task_tpl), {
                    \   "command" : "b2 " . relative_path,
                    \ })})

        let targets = []

        for line in readfile(a:filename, '')
            if line =~# re
                call add(targets, substitute(line, re, "\\1 \\2", ""))
            endif
        endfor
        let targets = uniq(sort(targets))

        for target in targets
            let t = split(target)
            let rel_target = relative_path . "//" . t[1]

            call extend(tasks, {
                        \ t[0] . ": " . rel_target : extend(copy(s:task_tpl), {
                        \   "command" : "b2 " . relative_path . "//" . split(target)[1],
                        \ })})
        endfor

        return tasks
    endif

    return {}
endfunction

function! s:detect_b2_tasks() abort
    if !exists("b:b2_detected_tasks")
        call s:InsideBoostBuildProj()
    endif

    if get(g:, 'bbv2_auto_detect_tasks', 0)
        return get(b:, "b2_detected_tasks", {})
    else
        return {}
    endif
endfunction

if s:InsideSpaceVim()
    " register SpaceVim task provider
    try
        call SpaceVim#plugins#tasks#reg_provider(funcref('s:detect_b2_tasks'))
    endtry
endif

augroup b2_compiler_detect
    " Change compiler to b2 inside Boost Build projects
    au!
    au VimEnter,BufNewFile,BufReadPost * if !get(g:, 'bbv2_disable_project_detect', 0) && s:InsideBoostBuildProj() && &makeprg=='make' | compiler b2 | endif
    au FileType bbv2 if !get(g:, 'bbv2_disable_project_detect', 0) && &makeprg=='make' | compiler b2 | endif
augroup END

" vi: ft=vim:tw=72:ts=4:fo=w2croql
