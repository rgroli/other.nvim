-- The module itself
local M = {}

local options = {}

-- Helper functions to pick files from an popup
local window = require("other.window")

-- Include helper
local helper = require("other.helper")

-- Include the builtin mappings and transformers
local builtinMappings = require("other.builtin.mappings")
local transformers = require("other.builtin.transformers")

-- default settings
local defaults = {

	-- by default there are no mappings enabled
	mappings = {},

	-- default transformers
	transformers = {
		camelToKebap = transformers.camelToKebap,
		kebapToCamel = transformers.kebapToCamel,
	},

	openDirCommand = ""
}

-- Find the other file
local function findOther(filename, context)
	-- iterate over all the mapping to check if the filename matches against any "pattern")
	for _, mapping in pairs(options.mappings) do
		local match
		if context == nil then
			match = filename:match(mapping.pattern)
		else
			if mapping.context == context then
				match = filename:match(mapping.pattern)
			end
		end

		if match ~= nil then
			-- if we have a match, optionally transforn the match
			if mapping.transformer ~= nil then
				local transformedMatch = defaults.transformers[mapping.transformer](match)
				filename, _ = filename:gsub(helper.escape_pattern(match), transformedMatch)
			end

			-- return (transformed) match with "target"
			local result, _ = filename:gsub(mapping.pattern, mapping.target)
			return result
		end
	end
	return nil
end

-- Resolve string based builtinMappings
local function resolveBuiltinMappings(mappings)
	local result = {}
	if mappings ~= nil then
		for _, mapping in pairs(mappings) do
			if type(mapping) == "string" then
				if builtinMappings[mapping] ~= nil then
					for _, biM in pairs(builtinMappings[mapping]) do
						table.insert(result, biM)
					end
				end
			else
				table.insert(result, mapping)
			end
		end
	end
	return result
end

-- Default setup method
function M.setup(opts)
	opts.mappings = resolveBuiltinMappings(opts.mappings)
	options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

-- Actual opening
local function open(context, openCommand)
	local match = findOther(vim.api.nvim_buf_get_name(0), context or nil)
	if match ~= nil then

		if vim.fn.isdirectory(match) == 1 then
			if helper.getFilesCount(match) == 1 then
				local filename = helper.getFirstFileInDirectory(match)
				vim.api.nvim_command(": " .. openCommand .. " " .. filename)
			else
				-- If we have a custome command for opening a directory
				if options.openDirCommand ~= "" then
					-- prepare command / cleanup leading colon and trailing cr
					local command = options.openDirCommand:gsub("$path", match)
					command = command:gsub("^:", "")
					command = command:gsub("<cr>", "")

					-- execute command
					vim.api.nvim_command(command)
				else
					-- otherwise use internal file picker
					window.open_window(match)
				end
			end
		else
			vim.api.nvim_command(": " .. openCommand .. " " .. match)
		end
	else
		print("No 'other' file found.")
	end
end

-- Trying to open another file
function M.open(context)
	open(context, "e")
end

-- Trying to open another file in split
function M.openSplit(context)
	open(context, "sp")
end

-- Trying to open another file in vertical split
function M.openVSplit(context)
	open(context, "vs")
end

return M
