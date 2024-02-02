-- prevent loading twice
if (vim.g.loaded_othernvim) then
  return
end

vim.cmd([[
	let s:save_cpo = &cpo " save user coptions
	set cpo&vim           " reset them to defaults
]])

vim.cmd([[
	command! -nargs=* Other lua require('other-nvim').open(<f-args>)
	command! -nargs=* OtherTabNew lua require('other-nvim').openTabNew(<f-args>)
	command! -nargs=* OtherSplit lua require('other-nvim').openSplit(<f-args>)
	command! -nargs=* OtherVSplit lua require('other-nvim').openVSplit(<f-args>)
	command! -nargs=* OtherClear lua require('other-nvim').clear(<f-args>)
]])

vim.g.loaded_othernvim = 1
