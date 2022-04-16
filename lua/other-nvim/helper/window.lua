local M = {}

local _caller, _callerBuffer

local lastfile = nil
local api = vim.api
local buf, win
local head

-- Filling the buffer with the files for the given path
local function update_view(files)
	api.nvim_buf_set_option(buf, "modifiable", true)

	local result = {}
	for k, file in pairs(files) do
		result[k] = file:match("^.+/(.+)$")
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, result)
	api.nvim_buf_set_option(buf, "modifiable", false)
end


-- Actually opening the file
local function _openFile(command)
	local str = api.nvim_get_current_line()
	str = head .. str
	lastfile = str
	M.close_window()
	api.nvim_set_current_buf(_callerBuffer)
	api.nvim_command(command .. " " .. str)
end

-- Set the keybindings
local function set_mappings()
	local mappings = {
		["<cr>"] = "open_file()",
        ["<esc>"] = "close_window()",
		o = "open_file()",
		q = "close_window()",
		v = "open_file_vs()",
		s = "open_file_sp()",
	}

	for k, v in pairs(mappings) do
		api.nvim_buf_set_keymap(buf, "n", k, ':lua require"other-nvim.helper.window".' .. v .. "<cr>", {
			nowait = true,
			noremap = true,
			silent = true,
		})
	end

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
	for _, v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

-- Closing the window
function M.close_window()
	api.nvim_win_close(win, true)
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
	print(_callerBuffer);

	lastfile = nil
	head = files[1]:match("^(.*)/.*$") .. "/"

	buf = api.nvim_create_buf(false, true)
	local border_buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", "whid")

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.2 - 4)
	local win_width = math.ceil(width * 0.15)
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}

	local border_lines = {
		"╭"
			.. string.rep("─", win_width / 2 - 9)
			.. "  Pick other file  "
			.. string.rep("─", win_width / 2 - 9)
			.. "╮",
	}
	local middle_line = "│" .. string.rep(" ", win_width) .. "│"
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, "╰" .. string.rep("─", win_width) .. "╯")
	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	api.nvim_win_set_option(win, "cursorline", true) -- it highlight line with the cursor on it
	set_mappings()
	update_view(files)
end

return M
