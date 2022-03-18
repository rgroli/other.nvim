local M = {}

M.laravel = {
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

M.livewire = {
	{
		pattern = "/app/Http/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Http/Livewire/%1/",
		transformer = "kebapToCamel",
	},
}

M.angular = {
	{
		pattern = "/(.*)/(.*)/.*.spec.ts$",
		target = "/%1/%2/%2.component.ts",
		context = "test",
	},
	{
		pattern = "/(.*)/(.*)/.*.ts$",
		target = "/%1/%2/%2.component.spec.ts",
		context = "test",
	},
	{
		pattern = "/(.*)/(.*)/.*.spec.ts$",
		target = "/%1/%2/%2.component.ts",
	},
	{
		pattern = "/(.*)/(.*)/.*.ts$",
		target = "/%1/%2/%2.component.html",
	},
	{
		pattern = "/(.*)/(.*)/.*.html$",
		target = "/%1/%2/%2.component.ts",
	},
	{
		pattern = "/(.*)/(.*)/.*.scss$",
		target = "/%1/%2/%2.component.ts",
	},
	{
		pattern = "/(.*)/(.*)/.*.ts$",
		target = "/%1/%2/%2.component.scss",
	},
}

return M
