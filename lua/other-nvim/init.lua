-- The module itself
local M = {}

local options = {}

-- Helper functions to pick files from an popup
local window = require("other-nvim.helper.window")

-- Include utils
local util = require("other-nvim.helper.util")

-- Include the builtin mappings and transformers
local builtinMappings = require("other-nvim.builtin.mappings")
local transformers = require("other-nvim.builtin.transformers")

-- default settings
local defaults = {
	-- by default there are no mappings enabled
	mappings = {},

	-- default transformers
	transformers = {
		camelToKebap = transformers.camelToKebap,
		kebapToCamel = transformers.kebapToCamel,
		pluralize = transformers.pluralize,
		singularize = transformers.singularize,
		telescope = false, -- Use Telescope for file picking
	},

	-- Should the window show files which do not exist yet based on
	-- pattern matching. Selecting the files will create the file.
	showMissingFiles = true,

	-- Enable this to use Telescope for file picking instead of using the internarl file picker
	telecope = false,

	-- When a mapping requires an initial selection of the other file, this setting controls,
	-- wether the selection should be remembered for the current user session.
	-- When this option is set to false reference between the two buffers are never saved.
	-- Existing references can be removed on the buffer with :OtherClear
	rememberBuffers = true,

	keybindings = {
		["<cr>"] = "open_file_by_command()",
		["<esc>"] = "close_window()",
		o = "open_file()",
		t = "open_file_tabnew()",
		q = "close_window()",
		v = "open_file_vs()",
		s = "open_file_sp()",
	},

	hooks = {
		-- This hook which is executed when the file-picker is shown.
		-- It could be used to filter or reorder the files in the filepicker.
		-- The function must return a lua table with the same structure as the input parameter.
		--
		-- The input parameter "files" is a lua table with each entry containing:
		-- @param table (filename (string), context (string), exists (boolean))
		-- @return table
		filePickerBeforeShow = function(files)
			return files
		end,

		-- This hook is called whenever a file is about to be opened.
		-- One example how this can be used: a non existing file needs to be opened by another plugin, which provides a template.
		--
		-- @param filename (string) the full-path of the file
		-- @param exists (boolean) doess the file already exist
		-- @return (boolean) When true (default) the plugin takes care of opening the file, when the function returns false this indicated that opening of the file is done in the hook.
		onOpenFile = function(filename, exists)
			return true
		end,

		-- This hook is called whenever the plugin tries to find other files.
		-- It returns the matches found by the plugin. It can be used to filter or reorder the files or use the matches with another plugin.
		--
		-- @param matches (table) lua table with each entry containing: (filename (string), context (string), exists (boolean))
		-- @return (matches) Make sure to return the matches, otherwise the plugin will not work as expected.
		onFindOtherFiles = function(matches)
			return matches
		end,
	},

	style = {
		-- How the plugin paints its window borders
		-- Allowed values are none, single, double, rounded, solid and shadow
		border = "solid",

		-- Column seperator for the window
		seperator = "|",

		-- Indicator showing that the file does not yet exist
		newFileIndicator = "(* new *)",

		-- width of the window in percent. e.g. 0.5 is 50%, 1 is 100%
		width = 0.7,

		-- min height in rows.
		-- when more columns are needed this value is extended automatically
		minHeight = 2,
	},
}

-- Saving the last matches in a global variable.
local saveLastMatches = function(matches)
	vim.g.other_lastmatches = matches
end

-- Find the potential other file(s)
-- Returns a table of matches.
local findOther = function(filename, context)
	local matches = {}

	-- iterate over all the mapping to check if the filename matches against *any* pattern)
	for _, mapping in pairs(options.mappings or {}) do
		local match

		if mapping.context == context or context == nil then
			match = filename:match(mapping.pattern)
		end

		if match ~= nil then
			local fn = filename
			local result, _ = fn:gsub(mapping.pattern, function(...)
				local captureds = { ... }
				local transformed_parts = {}
				for _, part in ipairs(captureds) do
					local transformed_part = mapping.transformer and options.transformers[mapping.transformer](part) or part
					table.insert(transformed_parts, transformed_part)
				end
				return mapping.target:gsub("%%(%d)", function(n)
					return transformed_parts[tonumber(n)] or ''
				end)
			end)

			local showMissingFiles = options.showMissingFiles
			local dirMatching = false
			local mappingMatches = {}

			-- if result includes wildcards it can't be a suggested missing file,
			-- because it can't be created on opening
			if result:match("*") then
				showMissingFiles = false
			end

			-- get a list of candidates based on the transformed match.
			-- additional glob-patterns in the target are respected
			if vim.fn.isdirectory(result) ~= 0 then
				result = result .. "*"
				dirMatching = true
			end

			if showMissingFiles and not dirMatching then
				table.insert(mappingMatches, result)
			else
				-- escape special characters in path before globbing
				result = result:gsub("%[", "\\[")
				result = result:gsub("%]", "\\]")
				result = result:gsub("%%%+", "+")
				mappingMatches = vim.fn.glob(result, true, true) or {}
			end

			for _, value in pairs(mappingMatches) do
				-- check wether the file is already added to the result
				local found = false
				for _, checkValue in pairs(matches) do
					vim.inspect(checkValue)
					if checkValue.filename == value then
						found = true
					end
				end

				if found == false and fn ~= value then
					table.insert(matches, {
						context = mapping.context,
						filename = value,
						exists = (vim.fn.filereadable(value) == 1 and true or false),
					})
				end
			end
		end
	end

	if options.showMissingFiles == true then
		-- non existing entries to the bottom
		table.sort(matches, function(a, b)
			if a.exists == true and b.exists == false then
				return true
			else
				return false
			end
		end)
	end

	matches = options.hooks.onFindOtherFiles(matches)
	saveLastMatches(matches)

	return matches
end

local flattenMapping = function(mapping, result)
	-- multiple patterns for a mapping
	if type(mapping.target) == "table" then
		for _, t in pairs(mapping.target) do
			local m = vim.deepcopy(mapping)

			if type(t) == "string" then
				m.target = t
			end
			if type(t) == "table" then
				for key, tv in pairs(t) do
					m[key] = tv
				end
			end
			table.insert(result, m)
		end
	else
		table.insert(result, mapping)
	end
	return result
end

-- Resolve string based builtinMappings
local resolveBuiltinMappings = function(mappings)
	local result = {}
	if mappings ~= nil then
		for _, mapping in pairs(mappings) do
			if type(mapping) == "string" then
				if builtinMappings[mapping] ~= nil then
					for _, biM in pairs(builtinMappings[mapping]) do
						result = flattenMapping(biM, result)
					end
				end
			else
				result = flattenMapping(mapping, result)
			end
		end
	end
	return result
end

M.setOtherFileToBuffer = function(otherFile, bufferHandle)
	if options.rememberBuffers == true then
		if otherFile then
			vim.api.nvim_buf_set_var(bufferHandle, "onv_otherFile", otherFile)
		end
	end
end

local getOtherFileFromBuffer = function()
	return vim.b.onv_otherFile
end

-- Actual opening
local open_with_telescope = function(matches)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	pickers.new({}, {
		prompt_title = "Find Other File",
		finder = finders.new_table {
			results = matches,
			entry_maker = function(entry)
				return {
					value = entry.filename,
					display = entry.filename .. (entry.exists and "" or " (* new *)"),
					ordinal = entry.filename,
				}
			end,
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					util.openFile("e", selection.value, options.hooks.onOpenFile)
				end
			end)
			return true
		end,
	}):find()
end

local open = function(context, openCommand)
	if options.telescope then
		local matches = findOther(vim.api.nvim_buf_get_name(0), context or nil)
		if #matches > 0 then
			open_with_telescope(matches)
		else
			print("No 'other' file found.")
		end
		return
	end
	local fileFromBuffer = nil

	-- only check for remembered value if no context is given.
	if context == nil then
		fileFromBuffer = getOtherFileFromBuffer()
	end
	-- when we had a match before, open that
	if fileFromBuffer then
		util.openFile(openCommand, fileFromBuffer, options.hooks.onOpenFile)
	else
		local matches = findOther(vim.api.nvim_buf_get_name(0), context or nil)
		local matchesCount = #matches
		if matchesCount > 0 then
			-- when dealing with a single file -> just open it
			if matchesCount == 1 then
				M.setOtherFileToBuffer(matches[1].filename, vim.api.nvim_get_current_buf())
				util.openFile(openCommand, matches[1].filename, options.hooks.onOpenFile)
			else
				matches = options.hooks.filePickerBeforeShow(matches)

				if not matches or #matches == 0 then
					return
				end
				-- otherwise open a window to pick a file
				if options.telescope then
					open_with_telescope(matches)
				else
					window.open_window(matches, M, vim.api.nvim_get_current_buf(), openCommand)
				end
			end
		else
			print("No 'other' file found.")
		end
	end
end

-- custom colors
M.colors = {
	Selector = "Error",
	Underlined = "Underlined",
}

-- -- -- -- -- -- -- -- -- -- PUBLIC -- -- -- -- -- -- -- -- --

-- Default setup method
M.setup = function(opts)
	opts.mappings = resolveBuiltinMappings(opts.mappings)
	options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
	vim.g.other_lastmatches = {}
	vim.g.other_lastopened = nil

	-- setting hl groups
	for hl_group, link in pairs(M.colors) do
		vim.api.nvim_set_hl(0, "Other" .. hl_group, {
			link = link,
			default = true,
		})
	end

end

-- Trying to open another file
M.open = function(context)
	open(context, "e")
end

-- Trying to open another file in new tab
M.openTabNew = function(context)
	open(context, "tabnew")
end

-- Trying to open another file in split
M.openSplit = function(context)
	open(context, "sp")
end

-- Trying to open another file in vertical split
M.openVSplit = function(context)
	open(context, "vs")
end

-- return the currently set options
M.getOptions = function()
	return options
end

-- Removing the memorized "other" file from the current buffer
M.clear = function()
	vim.b.onv_otherFile = nil
end

-- Made public to be used in other implementations 
M.findOther = function(filename, context)
	return findOther(filename, context)
end

return M
