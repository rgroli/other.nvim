local M = {}

-- Helper for escaping the lua-regexes.
function M.escape_pattern(text)
	return text:gsub("([^%w])", "%%%1")
end

-- Getting the count of files in a directory
function M.getFilesCount(path)
	local result = 0
	local files = vim.fn.glob(path .. "*", 0, 1)
	for _, f in pairs(files) do
		if vim.fn.isdirectory(f) == 0 then
			result = result + 1
		end
	end
	return result
end

-- Getting the full path of the first file in a directory
function M.getFirstFileInDirectory(path)
	local files = vim.fn.glob(path .. "*", 0, 1)
	for _, f in pairs(files) do
		if vim.fn.isdirectory(f) == 0 then
			return f
		end
	end
end


return M
