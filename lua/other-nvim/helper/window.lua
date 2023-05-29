local M = {}

local util = require("other-nvim.helper.util")

local otherInstance, currentBuffer

local lastfile = nil
local buf, win
local matches

local width, height

local border
local colSeparator
local newFileIndicator
local keybindings

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
	"o",
	"p",
	"n",
	"m",
	"r",
	"t",
	"z",
	"b",
	"v",
	"s",
	"c",
	"x",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
}

-- Disable the following keys in the window
local disabled_chars = {}

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
		vim.api.nvim_set_current_buf(currentBuffer)

		-- actual opening
		util.openFile(command, filename, otherInstance.getOptions()["hooks"].onOpenFile)
	end
end

-- Set the keybindings
local function _set_mappings()
	-- Disable reserved keybindings
	for _, v in ipairs(disabled_chars) do
		vim.api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = false, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = false, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = false, silent = true })
	end

	-- Add the defaultkeybindings from the config to open, close, splits, etc..
	for k, v in pairs(keybindings) do
		vim.api.nvim_buf_set_keymap(buf, "n", k, ':lua require"other-nvim.helper.window".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})

		-- make sure that the defined config keybindings are not part of the file shortcuts
		local pos_shortcut_chars = util.indexOf(shortcut_chars, k)
		if pos_shortcut_chars ~= nil then
			table.remove(shortcut_chars, pos_shortcut_chars)
		end
	end

	-- add shortcut bindings to the files list
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
		local fileNotExistsMarker = (not file.exists and newFileIndicator .. " " or "")
		filename = fileNotExistsMarker .. filename

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
			if #fn < #filename then
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
		if not matches[k].exists then
			vim.api.nvim_buf_add_highlight(
				buf,
				-1,
				"Underlined",
				k - 1,
				maxContextLength + 10,
				maxContextLength + 10 + #newFileIndicator
			)
			vim.api.nvim_buf_add_highlight(buf, -1, "Conceal", k - 1, maxContextLength + 10 + #newFileIndicator + 1, -1)
		end
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
	otherInstance.setOtherFileToBuffer(lastfile, currentBuffer)
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
	otherInstance = callerInstance
	currentBuffer = callerBuffer

	local styleOptions = otherInstance.getOptions()["style"]
	colSeparator = " " .. styleOptions["seperator"] .. " "
	newFileIndicator = styleOptions["newFileIndicator"]
	border = styleOptions["border"]

	keybindings = otherInstance.getOptions()["keybindings"]

	width = math.floor(styleOptions["width"] * vim.api.nvim_get_option("columns"))
	height = styleOptions["minHeight"]

	maxContextLength = _getMaxContextLength(files)
	lastfile = nil

	_buildWindow(#files)
	_set_mappings()
	_update_view(_prepareLines(files))
end

return M
