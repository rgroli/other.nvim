local util = require("other-nvim.helper.util")

local State = {
	buf = nil,
	win = nil,
	matches = nil,
	lastFile = nil,
	width = nil,
	height = nil,
	otherInstance = nil,
	currentBuffer = nil,
	windowOpenCommand = nil,
	options = nil,
}

local shortcut_chars = {
	"a",
	"d",
	"f",
	"g",
	"w",
	"e",
	"u",
	"o",
	"p",
	"n",
	"m",
	"r",
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

-- Module
local M = {}

-- Pure utility functions
local function getMaxContextLength(files)
	local result = 0
	for _, file in pairs(files) do
		if file.context and #file.context > result then
			result = #file.context
		end
	end
	return result
end

local function openFile(command, position)
	local pos = position or vim.api.nvim_win_get_cursor(0)[1]

	if State.matches[pos] then
		local filename = State.matches[pos].filename
		State.lastFile = filename

		M.close_window()
		vim.api.nvim_set_current_buf(State.currentBuffer)

		if State.options and State.options.hooks and State.options.hooks.onOpenFile then
			util.openFile(command, filename, State.options.hooks.onOpenFile)
		else
			util.openFile(command, filename)
		end
	end
end

local function prepareLines(files)
	State.matches = files

	local colSeparator = " " .. (State.options.style.seperator or "|") .. " "
	local newFileIndicator = State.options.style.newFileIndicator or "(* new *)"
	local maxContextLength = getMaxContextLength(files)

	local result = {}
	for k, file in pairs(files) do
		local filename = file.filename
		local fileNotExistsMarker = (not file.exists and newFileIndicator .. " " or "")
		filename = filename:gsub(util.escape_pattern(vim.fn.getcwd()) .. "/*", "")
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
			fn = string.sub(filename, -State.width + #result[k] + 4, #filename)
			if #fn < #filename then
				fn = ".." .. fn
			end
			result[k] = result[k] .. fn .. "  "
		else
			result[k] = "  " .. shortcut_chars[k] .. " " .. colSeparator .. "../" .. filename
		end
	end
	return result, maxContextLength
end

local function buildWindow(linesCount)
	local maxWidth = vim.o.columns
	local maxHeight = vim.o.lines

	State.height = linesCount >= State.height and linesCount or State.height

	local window_config = {
		relative = "editor",
		width = State.width,
		height = State.height,
		col = (maxWidth - State.width) / 2,
		row = (maxHeight - State.height) / 2,
		style = "minimal",
		focusable = false,
		border = State.options.style.border or "single",
	}

	State.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[State.buf].bufhidden = "wipe"
	vim.bo[State.buf].filetype = "whid"

	State.win = vim.api.nvim_open_win(State.buf, true, window_config)
	vim.wo[State.win].cursorline = true
	vim.wo[State.win].winhighlight = "Normal:NormalFloat,FloatBorder:NormalFloat"
end

local function setMappings()
	-- Disable reserved keybindings
	for _, v in ipairs(disabled_chars) do
		local opts = { nowait = true, noremap = false, silent = true }
		vim.api.nvim_buf_set_keymap(State.buf, "n", v, "", opts)
		vim.api.nvim_buf_set_keymap(State.buf, "n", v:upper(), "", opts)
		vim.api.nvim_buf_set_keymap(State.buf, "n", "<c-" .. v .. ">", "", opts)
	end

	-- Add configured keybindings
	for k, v in pairs(State.options.keybindings or {}) do
		vim.api.nvim_buf_set_keymap(
			State.buf,
			"n",
			k,
			':lua require"other-nvim.helper.window".' .. v .. "<cr>",
			{ nowait = true, noremap = true, silent = true }
		)

		local pos = util.indexOf(shortcut_chars, k)
		if pos then
			table.remove(shortcut_chars, pos)
		end
	end

	-- Add shortcut bindings
	for i, v in ipairs(shortcut_chars) do
		local baseOpts = { nowait = true, noremap = true, silent = true }

		vim.api.nvim_buf_set_keymap(
			State.buf,
			"n",
			v,
			':lua require"other-nvim.helper.window".open_file(' .. i .. ")<cr>",
			baseOpts
		)

		vim.api.nvim_buf_set_keymap(
			State.buf,
			"n",
			v:upper(),
			':lua require"other-nvim.helper.window".open_file_sp(' .. i .. ")<cr>",
			baseOpts
		)

		vim.api.nvim_buf_set_keymap(
			State.buf,
			"n",
			"<c-" .. v .. ">",
			':lua require"other-nvim.helper.window".open_file_vs(' .. i .. ")<cr>",
			baseOpts
		)
	end
end

local function updateView(lines, maxContextLength, newFileIndicator)
	vim.bo[State.buf].modifiable = true
	vim.api.nvim_buf_set_lines(State.buf, 0, -1, false, lines)

	for k, _ in pairs(lines) do
		vim.api.nvim_buf_add_highlight(State.buf, -1, "OtherSelector", k - 1, 2, 3)
		vim.api.nvim_buf_add_highlight(State.buf, -1, "OtherUnderlined", k - 1, 2, 3)

		if not State.matches[k].exists then
			vim.api.nvim_buf_add_highlight(
				State.buf,
				-1,
				"Underlined",
				k - 1,
				maxContextLength + 10,
				maxContextLength + 10 + #newFileIndicator
			)
			vim.api.nvim_buf_add_highlight(State.buf, -1, "Conceal", k - 1, maxContextLength + 10 + #newFileIndicator + 1, -1)
		end
	end

	vim.bo[State.buf].modifiable = false
end

-- Public API

-- Closing the window
function M.close_window()
	if State.win then
		vim.api.nvim_win_close(State.win, true)
		if State.otherInstance and State.otherInstance.setOtherFileToBuffer then
			State.otherInstance.setOtherFileToBuffer(State.lastFile, State.currentBuffer)
		end
	end
end

-- Opening the file with last opening command based on how "other" was initially opened. (Other, OtherTab, OtherSplit, OtherVSplit)
function M.open_file_by_command(pos)
	openFile(":" .. State.windowOpenCommand, pos)
end

function M.open_file(pos)
	openFile(":e", pos)
end

-- Opening the file in a new tab
function M.open_file_tabnew(pos)
	openFile(":tabnew", pos)
end

-- Opening the file in a regular split
function M.open_file_sp(pos)
	openFile(":sp", pos)
end

-- Opening the file in a vertical split
function M.open_file_vs(pos)
	openFile(":vs", pos)
end

-- Main function to open the window
function M.open_window(files, callerInstance, callerBuffer, openCommand)
	State.otherInstance = callerInstance
	State.currentBuffer = callerBuffer
	State.windowOpenCommand = openCommand
	State.lastFile = nil

	-- Get and store options
	State.options = {
		style = {
			width = 0.7,
			minHeight = 2,
			border = "single",
			seperator = "|",
			newFileIndicator = "(* new *)",
		},
		keybindings = {},
		hooks = {},
	}

	-- Safely merge options if available
	if callerInstance and type(callerInstance.getOptions) == "function" then
		local instanceOptions = callerInstance.getOptions()
		if instanceOptions then
			State.options = vim.tbl_deep_extend("force", State.options, instanceOptions)
		end
	end

	-- Calculate dimensions
	State.width = math.floor(State.options.style.width * vim.o.columns)
	State.height = State.options.style.minHeight

	-- Build window contents
	local lines, maxContextLength = prepareLines(files)
	buildWindow(#files)
	setMappings()
	updateView(lines, maxContextLength, State.options.style.newFileIndicator)
end

return M
