M = {}

local mappings = {
	"angular",
	"golang",
	"laravel",
	"livewire",
	"rails",
}

-- Include the mapping and add it to the builtin mapping table
local function addMapping(name)
	M[name] = require("other-nvim.builtin.mappings." .. name)
end

-- Iterate over all existing mappings
for _, mapping in pairs(mappings) do
	addMapping(mapping)
end


return M
