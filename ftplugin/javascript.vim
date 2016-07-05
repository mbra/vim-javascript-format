if exists("b:did_ftplugin")
    finish                 
endif                      
let b:did_ftplugin = 1     

autocmd BufWritePre <buffer> call javascript#Format()

" This will run "javascript-lint --fix" on your unsaved buffer 
" If you are using syntastic, it will see the already fixed code 
" Most of this is stolen from vim-go go#fmt#Format
function! javascript#Format()
    " Save cursor position and many other things
    let l:curw=winsaveview()

    " Write current unsaved buffer to a temp file
    let l:tmpname = tempname()
    call writefile(getline(1, '$'), l:tmpname)

    " Save our undo file to be restored after we are done. This is needed to
    " prevent an additional undo jump due to BufWritePre auto command and also
    " restore 'redo' history because it's getting being destroyed every BufWritePre
    let l:tmpundofile=tempname()
    exe 'wundo! ' . tmpundofile
	
	call system("eslint --fix " . l:tmpname) 

    if v:shell_error == 0
        " remove undo point caused via BufWritePre
        try | silent undojoin | catch | endtry

        " Replace current file with temp file, then reload buffer
        let old_fileformat = &fileformat
        call rename(l:tmpname, expand('%'))
        silent edit!
        let &fileformat = old_fileformat
        let &syntax = &syntax
    endif

    " restore our undo history
    silent! exe 'rundo ' . l:tmpundofile
    call delete(tmpundofile)

    " restore our cursor/windows positions
    call winrestview(l:curw)
endfunction

