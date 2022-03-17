if exists('g:loaded_othernvim') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim           " reset them to defaults

" commands 
command! -nargs=* Other lua require('other-nvim').open(<f-args>)
command! -nargs=* OtherSplit lua require('other-nvim').openSplit(<f-args>)
command! -nargs=* OtherVSplit lua require('other-nvim').openVSplit(<f-args>)
command! -nargs=* OtherClear lua require('other-nvim').clear(<f-args>)

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_othernvim = 1
