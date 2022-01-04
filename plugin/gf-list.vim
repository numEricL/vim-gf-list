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
    let g:line = getline('.')
    let g:line_index = match(g:line,expand('<cfile>'))
    let [g:filename, g:linenr, g:col] = s:ParseFilename(g:line[g:line_index :], expand('<cfile>'))
    call s:GfList(g:filename, g:linenr, g:col)
endfunction

function s:Map_v_gf() abort
    let l:reg=getreg('"')
    let l:regtype=getregtype('"')
    normal! gv""y
    let [l:filename, l:linenr, l:col] = s:ParseFilename(@", @")
    call setreg('"', l:reg, l:regtype)

    call s:GfList(l:filename, l:linenr, l:col)
endfunction

function s:ParseFilename(line, filename_default) abort
    let l:seperator_index = match(a:line, '[:|(#]')
    if l:seperator_index == -1
        return [ a:filename_default, 0, 0 ]
    endif
    let l:filename = a:line[0:l:seperator_index-1]
    let l:linenr = matchstr(a:line[l:seperator_index+1 :], '\d\+')
    let l:col    = matchstr(a:line[l:seperator_index+1 :], '\d\+', 0, len(l:linenr)+1)
    return [l:filename, l:linenr, l:col]
endfunction
