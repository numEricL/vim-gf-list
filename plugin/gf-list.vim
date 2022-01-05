"TODO rename to Find, add command
if !exists('g:GfList_map_n_gf')
    let g:GfList_map_n_gf = 'gf'
endif
if !exists('g:GfList_map_v_gf')
    let g:GfList_map_v_gf = 'gf'
endif

execute "nnoremap ".g:GfList_map_n_gf." :call <sid>Map_n_gf()<cr>"
execute "vnoremap ".g:GfList_map_v_gf." :<c-u>call <sid>Map_v_gf()<cr>"

function s:GfList(filename, line, col) abort
    let l:files = findfile(a:filename,"",-1)
    if len(l:files) == 0
        echohl ErrorMsg | echomsg "Can't find file \"".a:filename."\" in path" | echohl none
        return
    elseif len(l:files) == 1
        exec "edit ".l:files[0]
        call setpos('.', [0,a:line,a:col,0])
        return
    endif

    let l:list=[]
    for l:file in l:files
        call add(l:list, {'filename' : l:file})
    endfor

    call setloclist(0,l:list)
    echo "Multiple Files Found!"
    if v:version > 801 || v:version == 801 && has("patch1113")
        augroup GfList
            autocmd FileType qf ++once nnoremap <silent> <buffer> <CR> <CR>:lclose<CR>
        augroup END
    else
        augroup GfList
            autocmd FileType qf nnoremap <silent> <buffer> <CR> <CR>:lclose<CR> | autocmd! GfList
        augroup END
    endif
    silent lopen
    silent lfirst
    normal! p
endfunction

function s:Map_n_gf() abort
    let l:line = getline('.')
    let l:line_index = match(l:line,expand('<cfile>'))
    let [l:filename, l:linenr, l:col] = s:ParseFilename(l:line[l:line_index :], expand('<cfile>'))
    call s:GfList(l:filename, l:linenr, l:col)
endfunction

function s:Map_v_gf() abort
    let l:reg=getreg('"')
    let l:regtype=getregtype('"')
    normal! gv""y
    let [l:filename, l:linenr, l:col] = s:ParseFilename(@", "")
    call setreg('"', l:reg, l:regtype)

    call s:GfList(l:filename, l:linenr, l:col)
endfunction

function s:ParseFilename(line, filename) abort
    let l:filename_end = matchend(a:line, a:filename)
    let l:seperator_index = match(a:line[l:filename_end :], '[:|(#]')
    if l:seperator_index == -1
        let l:filename = !empty(a:filename)? a:filename : a:line
        let l:linenr = 0
        let l:col = 0
    else
        let l:filename = !empty(a:filename)? a:filename : a:line[0:l:seperator_index-1]
        let l:linenr = matchstr(a:line[l:seperator_index+1 :], '\d\+')
        let l:col = matchstr(a:line[l:seperator_index+1 :], '\d\+', 0, len(l:linenr)+1)
    endif
    return [l:filename, l:linenr, l:col]
endfunction
