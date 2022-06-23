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
	}
}

return M
