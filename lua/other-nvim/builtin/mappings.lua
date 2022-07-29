local M = {}

M.laravel = {
	{
		pattern = "/app/Http/Controllers/(.*)Controller.php$",
		target = "/resources/views/%1/",
		transformer = "camelToKebap",
		context = "view"
	},
	{
		pattern = "/resources/views/(.*)/.*",
		target = "/app/Http/Controllers/%1Controller.php",
		transformer = "kebapToCamel",
		context = "controller"
	},
}

local rails_controller_patterns = {
  { target = "/spec/factories/%1.rb", context = "factories", transformer = "singularize" },
  { target = "/app/models/%1.rb", context = "models", transformer = "singularize" },
  { target = "/app/views/%1/**/*.html.*", context = "view" },
}

M.rails = {
  {
    pattern = "/app/models/(.*).rb",
    target = {
      { target = "/spec/factories/%1.rb", context = "factories" },
      { target = "/app/controllers/**/%1_controller.rb", context = "controller", transformer = "pluralize" },
      { target = "/app/views/%1/**/*.html.*", context = "view", transformer = "pluralize" },
    },
  },
  {
    pattern = "/app/controllers/.*/(.*)_controller.rb",
    target = rails_controller_patterns,
  },
  {
    pattern = "/app/controllers/(.*)_controller.rb",
    target = rails_controller_patterns,
  },
  {
    pattern = "/app/views/(.*)/.*.html.*",
    target = {
      { target = "/spec/factories/%1.rb", context = "factories", transformer = "singularize" },
      { target = "/app/models/%1.rb", context = "models", transformer = "singularize" },
      { target = "/app/controllers/**/%1_controller.rb", context = "controller", transformer = "pluralize" },
    },
  }
}

M.livewire = {
	{
		pattern = "/app/Http/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
		context = "view"
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Http/Livewire/%1/",
		transformer = "kebapToCamel",
		context = "controller"
	},
}

M.angular = {
	{
		pattern = "/(.*)/(.*)/.*.ts$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html"
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss"
			},
			{
				target = "/%1/%2/%2.component.spec.ts",
				context = "test"
			}
		}
	},
	{
		pattern = "/(.*)/(.*)/.*.html$",
		target = {
			{
				target = "/%1/%2/%2.component.ts",
				context = "component"
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss"
			}
		}
	},
	{
		pattern = "/(.*)/(.*)/.*.scss$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html"
			},
			{
				target = "/%1/%2/%2.component.ts",
				context = "component"
			},
			{
				target = "/%1/%2/%2.component.spec.ts",
				context = "test"
			}
		}
	},
	{
		pattern = "/(.*)/(.*)/.*.spec.ts$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html"
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss"
			},
			{
				target = "/%1/%2/%2.component.ts",
				context = "component"
			}
		}
	}
}

return M
