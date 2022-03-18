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
	},
}

-- Find the other file
local findOther = function(filename, context)
	-- iterate over all the mapping to check if the filename matches against any "pattern")
	for _, mapping in pairs(options.mappings) do
		local match

		if mapping.context == context then
			match = filename:match(mapping.pattern)
		end

		if match ~= nil then
			-- if we have a match, optionally transforn the match
			if mapping.transformer ~= nil then
				local transformedMatch = defaults.transformers[mapping.transformer](match)
				filename, _ = filename:gsub(util.escape_pattern(match), transformedMatch)
			end

			-- return (transformed) match with "target"
			local result, _ = filename:gsub(mapping.pattern, mapping.target)
			return result
		end
	end
	return nil
end

-- Resolve string based builtinMappings
local resolveBuiltinMappings = function(mappings)
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

M.setOtherFileToBuffer = function(otherFile)
	if otherFile then
		vim.b.onv_otherFile = otherFile
	end
end

local getOtherFileFromBuffer = function()
	return vim.b.onv_otherFile
end

-- Actual opening
local open = function(context, openCommand)
	local match = findOther(vim.api.nvim_buf_get_name(0), context or nil)
	if match ~= nil then
		-- if match is a directory
		if vim.fn.isdirectory(match) == 1 then
			-- open it when there's only one file inside
			if util.getFilesCount(match) == 1 then
				local filename = util.getFirstFileInDirectory(match)
				vim.api.nvim_command(":" .. openCommand .. " " .. filename)
				return openCommand, filename
			else
				-- when we had a match before, open that
				if getOtherFileFromBuffer() then
					local fileFromBuffer = getOtherFileFromBuffer()
					vim.api.nvim_command(":" .. openCommand .. " " .. fileFromBuffer)
					return openCommand, fileFromBuffer
				else
					-- otherwise open a window to pick a file
					window.open_window(match, M)
					M.setOtherFileToBuffer(window.lastfile)
					return "internal", match
				end
			end
		else
			M.setOtherFileToBuffer(match)
			vim.api.nvim_command(":" .. openCommand .. " " .. match)
			return openCommand, match
		end
	else
		print("No 'other' file found.")
		return false, false
	end
end

-- -- -- -- -- -- -- -- -- -- PUBLIC -- -- -- -- -- -- -- -- --

-- Default setup method
M.setup = function(opts)
	opts.mappings = resolveBuiltinMappings(opts.mappings)
	options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

-- Trying to open another file
M.open = function(context)
	return open(context, "e")
end

-- Trying to open another file in split
M.openSplit = function(context)
	return open(context, "sp")
end

-- Trying to open another file in vertical split
M.openVSplit = function(context)
	return open(context, "vs")
end

-- Removing the memorized "other" file from the current buffer
M.clear = function()
	vim.b.onv_otherFile = nil
end

return M
