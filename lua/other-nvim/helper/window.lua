local M = {}

local util = require("other-nvim.helper.util")

local _caller, _callerBuffer

local lastfile = nil
local buf, win
local matches

local colSeparator = " | "
local maxContextLength = 0
local shortcut_chars = {
	"a",
	"d",
	"f",
	"g",
	"w",
	"e",
	"t",
	"u",
	"i",
	"p",
	"n",
	"m",
}

-- Disable the following keys in the window
local other_chars = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"i",
	"n",
	"p",
	"r",
	"t",
	"u",
	"w",
	"x",
	"y",
	"z",
}

local function _getMaxContextLength(files)
	local result = 0
	for _, file in pairs(files) do
		if file.context ~= nil and #file.context > result then
			result = #file.context
		end
	end
	return result
end

-- Actually opening the file
local function _openFile(command, position)
	-- Getting the current line number
	local pos = position or vim.api.nvim_win_get_cursor(0)[1]

	-- reading the filename from the matches table
	local filename = matches[pos - 1].filename
	lastfile = filename

	M.close_window()
	vim.api.nvim_set_current_buf(_callerBuffer)

	-- actual opening
	util.openFile(command, filename)
end

-- Set the keybindings
local function _set_mappings()
	local mappings = {
		["<cr>"] = "open_file()",
		["<esc>"] = "close_window()",
		o = "open_file()",
		q = "close_window()",
		v = "open_file_vs()",
		s = "open_file_sp()",
	}

	-- Set default bindings
	for _, v in ipairs(other_chars) do
		vim.api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = false, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = false, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = false, silent = true })
	end

	-- remove other default bindings
	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, "n", k, ':lua require"other-nvim.helper.window".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end

	-- add shortcut bindings
	for i, v in ipairs(shortcut_chars) do
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			v,
			':lua require"other-nvim.helper.window".open_file(' .. i+1 .. ')<cr>',
			{ nowait = true, noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			v:upper(),
			':lua require"other-nvim.helper.window".open_file_sp(' .. i+1 .. ')<cr>',
			{ nowait = true, noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			"<c-" .. v .. ">",
			':lua require"other-nvim.helper.window".open_file_vs(' .. i+1 .. ')<cr>',
			{ nowait = true, noremap = true, silent = true }
		)
	end
end

-- Filling the buffer with the files for the given path
local function _update_view(files)
	matches = files
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	local result = {}
	for k, file in pairs(files) do
		local filename = file.filename
		local context = file.context or ""
		if maxContextLength > 0 then
			result[k] = "  "
				.. shortcut_chars[k]
				.. " "
				.. colSeparator
				.. context
				.. string.rep(" ", maxContextLength - #context)
				.. colSeparator
				.. "../"
				.. filename:match("^.+/(.+/.+/.+)$")
		else
			result[k] = "  " .. shortcut_chars[k] .. " " .. colSeparator .. "../" .. filename:match("^.+/(.+/.+/.+)$")
		end
	end

	vim.api.nvim_buf_set_lines(buf, 1, -1, false, result)

	for k, _ in pairs(files) do
		vim.api.nvim_buf_add_highlight(buf, -1, "Underlined", k, 2, 3)
		vim.api.nvim_buf_add_highlight(buf, -1, "Bold", k, 2, 3)
		vim.api.nvim_buf_add_highlight(buf, -1, "Error", k, 2, 3)
	end

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Building the window
local function _buildWindow(linesCount)
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	local minWidth = 70
	local minHeight = 6
	if linesCount > minHeight then
		if linesCount < (height - 4) then
			minHeight = linesCount + 2
		else
			minHeight = height - 4
		end
	end

	local window_config = {
		relative = "editor",
		width = minWidth,
		height = minHeight,
		col = (width - minWidth) / 2,
		row = (height - minHeight) / 2,
		style = "minimal",
		focusable = false,
		border = "shadow",
	}

	-- setup window buffer
	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "whid")

	win = vim.api.nvim_open_win(buf, true, window_config)
	vim.api.nvim_win_set_option(win, "cursorline", true)
end

-- -- -- -- -- -- -- -- -- -- PUBLIC -- -- -- -- -- -- -- -- --

-- Closing the window
function M.close_window()
	vim.api.nvim_win_close(win, true)
	_caller.setOtherFileToBuffer(lastfile, _callerBuffer)
end

-- Opening the file
function M.open_file(pos)
	_openFile(":e", pos)
end

-- Opening the file in a regular split
function M.open_file_sp(pos)
	_openFile(":sp", pos)
end

-- Opening the file in a vertical split
function M.open_file_vs(pos)
	_openFile(":vs", pos)
end

-- Main function to open the window
function M.open_window(files, callerInstance, callerBuffer)
	_caller = callerInstance
	_callerBuffer = callerBuffer

	maxContextLength = _getMaxContextLength(files)
	lastfile = nil

	_buildWindow(#files)
	_set_mappings()
	_update_view(files)
end

return M
