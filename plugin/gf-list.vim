if !exists('g:Gflist_map_n_gf')
    let g:Gflist_map_n_gf = 'gf'
endif
if !exists('g:Gflist_map_v_gf')
    let g:Gflist_map_v_gf = 'gf'
endif

execute "nnoremap ".g:Gflist_map_n_gf." :call GfList(expand('<cfile>'))<cr>"
execute "vnoremap ".g:Gflist_map_v_gf." :<c-u>call <sid>V_GfList()<cr>"

function GfList(filename)
    let l:files = findfile(a:filename,"",-1)
    if len(l:files) == 0
        echohl ErrorMsg | echomsg "Can't find file \"".a:filename."\" in path" | echohl none
        return
    elseif len(l:files) == 1
        exec "edit ".l:files[0]
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
        augroup vimrc_
            autocmd FileType qf ++once nnoremap <silent> <buffer> <CR> <CR>:cclose<CR>
        augroup END
    else
        augroup vimrc_qf_temp
            autocmd FileType qf nnoremap <silent> <buffer> <CR> <CR>:cclose<CR> | autocmd! vimrc_qf_temp
        augroup END
    endif
    silent copen
endfunction

function s:V_GfList() abort
    let l:reg=getreg('"')
    let l:regtype=getregtype('"')
    normal! gv""y
    let l:filename=@"
    call setreg('"', l:reg, l:regtype)

    call GfList(l:filename)
endfunction
