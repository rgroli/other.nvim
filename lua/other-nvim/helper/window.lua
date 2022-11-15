local M = {}

local util = require("other-nvim.helper.util")

local _caller, _callerBuffer

local lastfile = nil
local buf, win
local matches

local width, height

local border
local colSeparator

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
	"q",
	"r",
	"t",
	"z",
	"b",
	"c",
	"x",
}

-- Disable the following keys in the window
local other_chars = {
	"a",
	"d",
	"e",
	"f",
	"g",
	"i",
	"u",
	"w",
	"y",
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
	if matches[pos] ~= nil then
		local filename = matches[pos].filename
		lastfile = filename

		M.close_window()
		vim.api.nvim_set_current_buf(_callerBuffer)

		-- actual opening
		util.openFile(command, filename)
	end
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
			':lua require"other-nvim.helper.window".open_file(' .. i .. ")<cr>",
			{ nowait = true, noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			v:upper(),
			':lua require"other-nvim.helper.window".open_file_sp(' .. i .. ")<cr>",
			{ nowait = true, noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(
			buf,
			"n",
			"<c-" .. v .. ">",
			':lua require"other-nvim.helper.window".open_file_vs(' .. i .. ")<cr>",
			{ nowait = true, noremap = true, silent = true }
		)
	end
end

local function _prepareLines(files)
	matches = files

	local result = {}
	for k, file in pairs(files) do
		local filename = file.filename
		local context = file.context or ""
		local shortcut = shortcut_chars[k] or ""
		if maxContextLength > 0 then
			result[k] = "  "
				.. shortcut
				.. " "
				.. colSeparator
				.. context
				.. string.rep(" ", maxContextLength - #context)
				.. colSeparator

			local fn = ""
			-- cut filename from the right side minus the window width and result[k]
			fn = string.sub(filename, -width + #result[k] + 4, #filename)
			if (#fn < #filename) then
				fn = ".." .. fn
			end 
			result[k] = result[k] .. fn .. "  "
		else
			result[k] = "  " .. shortcut_chars[k] .. " " .. colSeparator .. "../" .. filename
		end
	end
	return result
end

-- Filling the buffer with the files for the given path
local function _update_view(lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for k, _ in pairs(lines) do
		vim.api.nvim_buf_add_highlight(buf, -1, "Error", k - 1, 2, 3)
		vim.api.nvim_buf_add_highlight(buf, -1, "Underlined", k - 1, 2, 3)
	end

	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Building the window
local function _buildWindow(linesCount)
	local maxWidth = vim.api.nvim_get_option("columns")
	local maxHeight = vim.api.nvim_get_option("lines")

	if linesCount >= height then
		height = linesCount
	end

	local window_config = {
		relative = "editor",
		width = width,
		height = height,
		col = (maxWidth - width) / 2,
		row = (maxHeight - height) / 2,
		style = "minimal",
		focusable = false,
		border = border,
	}

	-- setup window buffer
	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "filetype", "whid")

	win = vim.api.nvim_open_win(buf, true, window_config)
	vim.api.nvim_win_set_option(win, "cursorline", true)
	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:NormalFloat,FloatBorder:NormalFloat")
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

	styleOptions = _caller.getOptions()["style"]
	colSeparator = " " .. styleOptions["seperator"] .. " "
	border = styleOptions["border"]

	width = math.floor(styleOptions["width"] * vim.api.nvim_get_option("columns"))
	height = styleOptions["minHeight"]

	maxContextLength = _getMaxContextLength(files)
	lastfile = nil

	_buildWindow(#files)
	_set_mappings()
	_update_view(_prepareLines(files))
end

return M
