local window = require("other-nvim.helper.window")
local util = require("other-nvim.helper.util")
local builtinMappings = require("other-nvim.builtin.mappings")
local transformers = require("other-nvim.builtin.transformers")

---@class OtherNvimConfig
---@field options table Configuration options
---@field highlights table Highlight groups
local Config = {
	options = {},
	highlights = {
		Selector = "Error",
		Underlined = "Underlined",
	},
}

---@class FileMatch
---@field context string Context of the match
---@field filename string Full path to the file
---@field exists boolean Whether the file exists

local default_config = {
	mappings = {},

	-- default transformers
	transformers = {
		camelToKebap = transformers.camelToKebap,
		kebapToCamel = transformers.kebapToCamel,
		pluralize = transformers.pluralize,
		singularize = transformers.singularize,
	},

	-- Should the window show files which do not exist yet based on
	-- pattern matching. Selecting the files will create the file.
	showMissingFiles = true,

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

---@param pattern string Pattern to escape for glob
local function escape_glob(pattern)
	return pattern:gsub("([%[%]])", "\\%1"):gsub("%%%+", "+")
end

---@param pattern string Pattern to glob
---@return string[] Matching files
local function get_matching_files(pattern)
	return vim.fn.glob(escape_glob(pattern), true, true) or {}
end

---@param value string Value to transform
---@param transformer_name string|nil Name of transformer to use
---@param options table Options containing transformers
---@return string Transformed value
local function transform_value(value, transformer_name, options)
	if not transformer_name then
		return value
	end
	local transformer = options.transformers[transformer_name]
	return transformer and transformer(value) or value
end

---@param captures table Captured values
---@param mapping table Mapping configuration
---@param options table Options
---@return table Transformed captures
local function apply_transforms(captures, mapping, options)
	return vim.tbl_map(function(capture)
		return transform_value(capture, mapping.transformer, options)
	end, captures)
end

---@param pattern string Pattern with placeholders
---@param values table Values to substitute
local function substitute_placeholders(pattern, values)
	return pattern:gsub("%%(%d)", function(n)
		return values[tonumber(n)] or ""
	end)
end

---@param context string Context
---@param filename string Filename
---@return FileMatch File match object
local function create_file_match(context, filename)
	return {
		context = context,
		filename = filename,
		exists = vim.fn.filereadable(filename) == 1,
	}
end

---@param matches FileMatch[] Existing matches
---@param filename string Filename to check
---@return boolean Whether filename exists in matches
local function is_duplicate(matches, filename)
	return vim.tbl_contains(
		vim.tbl_map(function(m)
			return m.filename
		end, matches),
		filename
	)
end

---@param matches FileMatch[] Matches to sort
---@return FileMatch[] Sorted matches
local function sort_by_existence(matches)
	if not Config.options.showMissingFiles then
		return matches
	end

	table.sort(matches, function(a, b)
		return (a.exists and not b.exists)
	end)
	return matches
end

---@param pattern string|function Pattern to match
---@param current_file string Current file path
---@return table|nil Matched captures
local function get_pattern_matches(pattern, current_file)
	if type(pattern) == "function" then
		return pattern(current_file)
	elseif type(pattern) == "string" then
		local match = { current_file:match(pattern) }
		return #match > 0 and match or nil
	end
	return nil
end

-- Mapping functions
---@param mapping table Single mapping configuration
---@param current_file string Current file path
---@param matches FileMatch[] Existing matches
---@return FileMatch[] Updated matches
local function process_single_mapping(mapping, current_file, matches)
	if not mapping.pattern then
		return matches
	end

	local captured = get_pattern_matches(mapping.pattern, current_file)
	if not captured then
		return matches
	end

	local target = type(mapping.pattern) == "string"
			and current_file:gsub(mapping.pattern, function(...)
				local transformed = apply_transforms({ ... }, mapping, Config.options)
				return substitute_placeholders(mapping.target, transformed)
			end)
		or substitute_placeholders(mapping.target, apply_transforms(captured, mapping, Config.options))

	local is_dir = vim.fn.isdirectory(target) == 1
	local candidates = is_dir and get_matching_files(target .. "*")
		or (Config.options.showMissingFiles and not target:match("*") and { target } or get_matching_files(target))

	for _, candidate in ipairs(candidates) do
		if not is_duplicate(matches, candidate) and current_file ~= candidate then
			table.insert(matches, create_file_match(mapping.context, candidate))
		end
	end

	return matches
end

---@param mapping table Mapping to expand
---@return table[] Expanded mappings
local function expand_mapping(mapping)
	if type(mapping.target) ~= "table" then
		return { mapping }
	end

	return vim.tbl_map(function(target)
		local new_mapping = vim.deepcopy(mapping)
		if type(target) == "string" then
			new_mapping.target = target
		else
			for k, v in pairs(target) do
				new_mapping[k] = v
			end
		end
		return new_mapping
	end, mapping.target)
end

---@param mappings table[] Mappings to resolve
---@return table[] Resolved mappings
local function resolve_mappings(mappings)
	local result = {}
	for _, mapping in ipairs(mappings or {}) do
		if type(mapping) == "string" and builtinMappings[mapping] then
			for _, builtin in ipairs(builtinMappings[mapping]) do
				vim.list_extend(result, expand_mapping(builtin))
			end
		else
			vim.list_extend(result, expand_mapping(mapping))
		end
	end
	return result
end

-- Core functionality
---@param filename string File to find others for
---@param context string|nil Context to filter by
---@return FileMatch[] Matching files
local function find_other_files(filename, context)
	local matches = {}

	for _, mapping in ipairs(Config.options.mappings or {}) do
		if mapping.context == context or context == nil then
			matches = process_single_mapping(mapping, filename, matches)
		end
	end

	local sorted = sort_by_existence(matches)
	local processed = Config.options.hooks.onFindOtherFiles(sorted)
	vim.g.other_lastmatches = processed
	return processed
end

---@param other_file string File to reference
---@param buffer number Buffer to set reference in
local function manage_buffer_reference(other_file, buffer)
	if Config.options.rememberBuffers and other_file then
		vim.api.nvim_buf_set_var(buffer, "onv_otherFile", other_file)
	end
end

---@param context string|nil Context to filter by
---@param command string Command to open file with
local function open_other_file(context, command)
	local current_buffer = vim.api.nvim_get_current_buf()
	local remembered = context == nil and vim.b.onv_otherFile

	if remembered then
		util.openFile(command, remembered, Config.options.hooks.onOpenFile)
		return
	end

	local matches = find_other_files(vim.api.nvim_buf_get_name(0), context)

	if #matches == 0 then
		vim.notify("No 'other' file found.", vim.log.levels.WARN)
		return
	end

	if #matches == 1 then
		manage_buffer_reference(matches[1].filename, current_buffer)
		util.openFile(command, matches[1].filename, Config.options.hooks.onOpenFile)
		return
	end

	local filtered = Config.options.hooks.filePickerBeforeShow(matches)
	if not filtered or #filtered == 0 then
		return
	end

	window.open_window(filtered, M, current_buffer, command)
end

-- Public API
local M = {}

---@param opts table|nil Configuration options
function M.setup(opts)
	opts = opts or {}
	opts.mappings = resolve_mappings(opts.mappings)
	Config.options = vim.tbl_deep_extend("force", {}, default_config, opts)

	-- Initialize global state
	vim.g.other_lastmatches = {}
	vim.g.other_lastopened = nil

	-- Set up highlights
	for group, link in pairs(Config.highlights) do
		vim.api.nvim_set_hl(0, "Other" .. group, {
			link = link,
			default = true,
		})
	end
end

-- File opening commands
function M.open(context)
	open_other_file(context, "e")
end
function M.openTabNew(context)
	open_other_file(context, "tabnew")
end
function M.openSplit(context)
	open_other_file(context, "sp")
end
function M.openVSplit(context)
	open_other_file(context, "vs")
end
function M.clear()
	vim.b.onv_otherFile = nil
end

-- Utility functions
function M.getOptions()
	return Config.options
end
function M.findOther(...)
	return find_other_files(...)
end
function M.setOtherFileToBuffer(...)
	return manage_buffer_reference(...)
end

return M
