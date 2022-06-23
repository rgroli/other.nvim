local M = {}

local _caller, _callerBuffer

local lastfile = nil
local buf, win
local head

local colSeparator = " | "
local maxContextLength = 0

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
local function _openFile(command)
	local str = vim.api.nvim_get_current_line()
	local filename = ""
	if maxContextLength > 0 then
		filename = string.sub(str, maxContextLength + #colSeparator + 1)
	else
		filename = str
	end
	filename = head .. filename
	lastfile = filename
	M.close_window()
	vim.api.nvim_set_current_buf(_callerBuffer)
	vim.api.nvim_command(command .. " " .. filename)
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

	for k, v in pairs(mappings) do
		vim.api.nvim_buf_set_keymap(buf, "n", k, ':lua require"other-nvim.helper.window".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end

	-- Disable the following keys in the window
	local other_chars = {
		"a", "b", "c", "d", "e", "f", "g", "i", "n", "p", "r", "t", "u", "w", "x", "y", "z",
	}

	for _, v in ipairs(other_chars) do
		vim.api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

-- Filling the buffer with the files for the given path
local function _update_view(files)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)

	local result = {}
	for k, file in pairs(files) do
		local filename = file.filename
		local context = file.context or ""
		if maxContextLength > 0 then
			result[k] =  context
				.. string.rep(" ", maxContextLength - #context)
				.. colSeparator
				.. filename:match("^.+/(.+)$")
		else
			result[k] = filename:match("^.+/(.+)$")
		end
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
end


-- Building the window
local function _buildWindow()
	local minWidth = 60
	local minHeight = 5

	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	local window_config = {
		relative = "editor",
		width = minWidth,
		height = minHeight,
		col = (width - minWidth) / 2,
		row = (height - minHeight) / 2,
		style = 'minimal',
		focusable = false,
		border = "rounded"
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
function M.open_file()
	_openFile(":e")
end

-- Opening the file in a regular split
function M.open_file_sp()
	_openFile(":sp")
end

-- Opening the file in a vertical split
function M.open_file_vs()
	_openFile(":vs")
end

-- Main function to open the window
function M.open_window(files, callerInstance, callerBuffer)
	_caller = callerInstance
	_callerBuffer = callerBuffer

	maxContextLength = _getMaxContextLength(files)
	lastfile = nil
	head = files[1].filename:match("^(.*)/.*$") .. "/"

	_buildWindow()
	_set_mappings()
	_update_view(files)
end

return M
