"TODO rename to Find, add command
if !exists('g:GfList_map_n_gf')
    let g:GfList_map_n_gf = 'gf'
endif
if !exists('g:GfList_map_n_gF')
    let g:GfList_map_n_gF = 'gF'
endif
if !exists('g:GfList_map_v_gf')
    let g:GfList_map_v_gf = 'gf'
endif

execute "nnoremap ".g:GfList_map_n_gf." :call GfList(expand('<cfile>'), 0, 0)<cr>"
execute "nnoremap ".g:GfList_map_n_gF." :call <sid>List_n_gF()<cr>"
execute "vnoremap ".g:GfList_map_v_gf." :<c-u>call <sid>List_v_gf()<cr>"

function GfList(filename, line, col)
    let l:files = findfile(a:filename,"",-1)
    if len(l:files) == 0
        echohl ErrorMsg | echomsg "Can't find file \"".a:filename."\" in path" | echohl none
        return
    elseif len(l:files) == 1
        exec "edit ".l:files[0]
        call setpos('.', [0,a:line,a:col,0])
        return
    endif

    let l:qflist=[]
    let l:counter = 0
    for l:file in l:files
        let l:qfdict = {}
        let l:qfdict['filename'] = l:file
        call add(l:qflist, l:qfdict)
    endfor

    call setqflist(l:qflist)
    echohl ErrorMsg | echomsg "Multiple Files Found!" | echohl none
    if v:version > 801 || v:version == 801 && has("patch1113")
        augroup GfList
            autocmd FileType qf ++once nnoremap <silent> <buffer> <CR> <CR>:cclose<CR>
        augroup END
    else
        augroup GfList
            autocmd FileType qf nnoremap <silent> <buffer> <CR> <CR>:cclose<CR> | autocmd! GfList
        augroup END
    endif
    silent copen
endfunction

function s:List_n_gF() abort
    let [l:cfile, l:linenr, l:col] = GfList_GetCFile()
    call GfList(l:cfile, l:linenr, l:col)
endfunction

function s:List_v_gf() abort
    let l:reg=getreg('"')
    let l:regtype=getregtype('"')
    normal! gv""y
    let l:filename=@"
    call setreg('"', l:reg, l:regtype)

    call GfList(l:filename, line, col)
endfunction

function GfList_GetCFile() abort
    let l:line = getline('.')
    let l:cfile = expand('<cfile>')
    let regex = '[(:|]\(\d\+\) col \(\d\+\)|'
    let l:file_matches = matchlist(l:line, l:cfile..l:regex)
    let l:linenr = empty(l:file_matches[1])? 0 : l:file_matches[1]
    let l:col = empty(l:file_matches[2])? 0 : l:file_matches[2]
    return [l:cfile, l:linenr, l:col]
endfunction
