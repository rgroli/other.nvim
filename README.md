# other.nvim
Open alternative files for the current buffer. 

## tldr; ##
With this plugin you can open other/related files for the currently active buffer.  
For instance when editing a controller you can easily open a view, a model or a testcase without the need open a fuzzy finder or a tree.

## Dependencies ##
Neovim > 0.5

## Usage ##
After setting up the plugin with some builtin or custom mapping, the plugin provides this set of command: 

| Command   | Description |
|--------------|-----------|
| `:Other` |Opens the other/alternative file according to the configured mapping.   |
| `:OtherSplit`  | Like `:Other`but opens the file in a vertical split. |
| `:OtherVSplit`  | Like `:Other`but opens the file in a horizontal split. |

For each command you can pass an optional `context` which are described under mappings. 
For example `:Other test` could be used to open the testcase for the current buffer.


## Installation / Setup ##
```
Plug 'rgroli/other.nvim'
```
After the installation the plugin needs to be setup. When your're using a `init.lua` an example setup could look like:  
```lua
require("other").setup({
    mappings = {
        -- builtin mappings
        "livewire", "angular", "laravel",
        
        -- custom mapping 
        {
            pattern = "/path/to/file/src/app/(.*)/.*.ext$",
        	target = "/path/to/file/src/view/%1/",
        	transformer = "lowercase"
        }
    },
    transformers = {
        -- defining a custom transformer
        lowercase = function (inputString)
            return inputString:lower()
        end
    },
    openDirCommand = "Telescope find_files cwd=$path",
})
```

## Configuration
To adjust the behaviour of the plugin, you the pass a configuration to the setup function.
The default-configuration looks like:

```lua
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
```

| Value   | Description |
|--------------|-----------|
| `mappings` | Descriptions how to find other/alternative files for the current buffer. |
| `transformers`  | List of functions which are used to transform values when mapping the target file. |
| `openDirCommand` | Sometimes it is not possible to finde an exact match for the current buffer. In this case the plugin provides a popup to pick the correct file. The `openDirCommand` is used to open a _different_ picker to select the file. For instance when using [Telescope](https://github.com/nvim-telescope/telescope.nvim) this can be set to `"Telescope find_files cwd=$path"` where path is the "$path" is the directory to open|


### Mappings ###
Mappings are the heart of the plugin and describe how to find the other/alternative file for the current buffer. 

For example in an angular project, the mapping of a html-template to a typescript component and vice-versa can be done as follows: 
```lua
require("other").setup({
    mappings = {
    	{
    		pattern = "/src/app/(.*)/.*.ts$",
    		target = "/src/app/%1/%1.component.html",
    	},
    	{
    		pattern = "/src/app/(.*)/.*.html$",
    		target = "/src/app/%1/%1.component.ts",
    	}
	}
})
```

The mapping between a controller and a view file in a laravel project can be done with: 
```lua
require("other").setup({
    mappings = {
        	{
        		pattern = "/app/Http/Controllers/(.*)Controller.php$",
        		target = "/resources/views/%1/",
        		transformer = "camelToKebap",
        	},
        	{
        		pattern = "/resources/views/(.*)/.*",
        		target = "/app/Http/Controllers/%1Controller.php",
        		transformer = "kebapToCamel",
        	},
	}
})
```

A mapping can have the following settings: 

| Setting   | Description |
|--------------|-----------|
| `pattern` | A regular expression for finding an available mapping for the current buffer. The pattern should have one capturing group `(.*)` which can be used in the target setting      |
| `target`  | A string for resolving the other/alternative file. The `%1` of the string is represented by whatever was found in the capturing group of the pattern. |
| `transformer` | A function to transform the captured group of the pattern before it is used in the target.|
| `context` (optional) | A string defining an extra context beyond the standard mapping. An example would be "test" for opening the testcase of a component. |

#### Builtin Mappings ####
Right now there are builtin mappings for `angular`, `laravel` and `livewire`. The implementation of the the mappings is straightforward and can be viewed [here](https://github.com/rgroli/other.nvim/blob/main/lua/other/builtin/mappings.lua). I'd ❤️ to see contributions to extend this list. 
To the builtin mappings they can be passed as string to the mappings in the setup. 

```lua
require("other").setup({
    -- [...]
    mappings = {
        "livewire", "laravel", "angular"
    }
    -- [...]
})
```
Beware that the order in which the mappings are defined in the setup matters! The first match will be always be used.

### Transformers ###
Transformers are functions to transform the captured group of the pattern before being used in the target. 
Right now the plugin has two builtin transformers `camelToKebap` and `kebapToCamel`. 

It is easy to create a custom transformers in the setup as well. A transformer must have this signature: 
```lua
function (inputString)
   -- transforming here
   return transformedValue;
end
```

Custom transformers are defined in the setup and can directly used in the mappings. In this example the custom `lowercase` transformer.

```lua
require("other").setup({
    -- [...]
    mappings = {
        -- custom mapping
        {
            pattern = "/path/to/file/src/app/(.*)/.*.ext$",
            target = "/path/to/file/src/view/%1/",
            transformer = "lowercase"
        }
    },
    transformers = {
        lowercase = function (inputString)
            return inputString:lower()
        end
    },
    -- [...]
})
```

Of course, it would be great if the list of commonly used transformers could be extended by contributions.
