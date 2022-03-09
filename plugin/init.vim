if exists('g:loaded_other') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim           " reset them to defaults

" commands 
command! -nargs=* Other lua require('other').open(<f-args>)
command! -nargs=* OtherSplit lua require('other').openSplit(<f-args>)
command! -nargs=* OtherVSplit lua require('other').openVSplit(<f-args>)

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_other = 1
