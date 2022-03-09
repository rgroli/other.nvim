local M = {}

local api = vim.api
local buf, win

-- Filling the buffer with the files for the given path
local function update_view(path)
	api.nvim_buf_set_option(buf, "modifiable", true)

	local paths = vim.split(vim.fn.glob(path .. "*"), "\n")
	local result = {}
	for k, file in pairs(paths) do
		result[k] = file
	end

	api.nvim_buf_set_lines(buf, 0, -1, false, result)
	api.nvim_buf_set_option(buf, "modifiable", false)
end

-- Closing the window
function M.close_window()
	api.nvim_win_close(win, true)
end

-- Opening the file
function M.open_file()
	local str = api.nvim_get_current_line()
	M.close_window()
	api.nvim_command("edit " .. str)
end

-- Opening the file in a regular split
function M.open_file_sp()
	local str = api.nvim_get_current_line()
	M.close_window()
	api.nvim_command("sp " .. str)
end

-- Opening the file in a vertical split
function M.open_file_vs()
	local str = api.nvim_get_current_line()
	M.close_window()
	api.nvim_command("vs " .. str)
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
		api.nvim_buf_set_keymap(buf, "n", k, ':lua require"other.window".' .. v .. "<cr>", {
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

-- Main function to open the window
function M.open_window(path)
	buf = api.nvim_create_buf(false, true)
	local border_buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", "whid")

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.3 - 4)
	local win_width = math.ceil(width * 0.4)
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
	update_view(path)
end

return M
