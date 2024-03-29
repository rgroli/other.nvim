local M = {}

-- converts MyFolder/MyComponent to my-folder/my-component
M.camelToKebap = function(inputString)

	local pathParts = {}

	-- cut along the path separators
	inputString:gsub("%w+[^/]", function(str)
		table.insert(pathParts, str)
	end)

	-- transform to kebap inside of the path fragments
	for i, part in pairs(pathParts) do
		local camelParts = {}
		part:gsub("%u%l+", function(str)
			table.insert(camelParts, str:lower())
		end)
		pathParts[i] = table.concat(camelParts, "-")
	end

	-- rejoin the whole thing
	return table.concat(pathParts, "/")
end

-- converts my-folder/my-component to MyFolder/MyComponent
M.kebapToCamel = function(inputString)

	local pathParts = {}

	-- cut along the path separators
	inputString:gsub("[%w-_]+[^/]", function(str)
		table.insert(pathParts, str)
	end)

	-- transform to kebap inside of the path fragments
	for i, part in pairs(pathParts) do
		local tmp = ""
		for key in part:gmatch("[^-]+") do
			tmp = tmp .. key:sub(1, 1):upper() .. key:sub(2)
		end
		pathParts[i] = tmp
	end

	-- rejoin the whole thing
	return table.concat(pathParts, "/")
end

M.pluralize = function(inputString)
  local lastCharacter = inputString:sub(-1, -1)

  if lastCharacter == "y" then
    local stringWithoutY = inputString:sub(1, -2)

    return stringWithoutY .. "ies"
  elseif lastCharacter == "s" then
    return inputString
  else
    return inputString .. "s"
  end
end

M.singularize = function(inputString)
  local lastCharacter = inputString:sub(-1, -1)

  local lastThreeCharacters = ""

  if #inputString >= 3 then
    lastThreeCharacters = inputString:sub(-3, -1)
  end

  if lastThreeCharacters == "ies" then
    local stringWithoutIes = inputString:sub(1, -4)

    return stringWithoutIes .. "y"
  elseif lastCharacter == "s" then
    return inputString:sub(1, -2)
  else
    return inputString
  end
end

return M
