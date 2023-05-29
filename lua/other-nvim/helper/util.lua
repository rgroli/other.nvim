local M = {}

-- Actual opening
function M.openFile(openCommand, filename, onOpenFileHook)
	local exists = (vim.fn.filereadable(filename) == 1 and true or false)
	local shouldOpenFile = onOpenFileHook(filename, exists)
	if shouldOpenFile then
		vim.api.nvim_command(":" .. openCommand .. " " .. filename)
		vim.g.other_lastopened = filename
	end
end

-- Helper for escaping the lua-regexes.
function M.escape_pattern(text)
	return text:gsub("([^%w])", "%%%1")
end

-- Getting the count of files in a directory
function M.getFilesCount(path)
	local result = 0
	local files = vim.fn.glob(path .. "*", false, true)
	for _, f in pairs(files) do
		if vim.fn.isdirectory(f) == 0 then
			result = result + 1
		end
	end
	return result
end

-- Getting the full path of the first file in a directory
function M.getFirstFileInDirectory(path)
	local files = vim.fn.glob(path .. "*", false, true)
	for _, f in pairs(files) do
		if vim.fn.isdirectory(f) == 0 then
			return f
		end
	end
end

-- Getting the index of an element in a two-dimensional lua table
function M.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

return M
