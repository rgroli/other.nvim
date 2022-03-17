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
		pattern = "/src/app/components/(.*)/.*.spec.ts$",
		target = "/src/app/components/%1/%1.component.ts",
		context = "test",
	},
	{
		pattern = "/src/app/components/(.*)/.*.ts$",
		target = "/src/app/components/%1/%1.component.html",
	},
	{
		pattern = "/src/app/components/(.*)/.*.html$",
		target = "/src/app/components/%1/%1.component.ts",
	},
	{
		pattern = "/src/app/components/(.*)/.*.ts$",
		target = "/src/app/components/%1/%1.component.spec.ts",
		context = "test",
	},
	{
		pattern = "/src/app/components/(.*)/.*.scss$",
		target = "/src/app/components/%1/%1.component.ts",
		context = "scss",
	},
	{
		pattern = "/src/app/components/(.*)/.*.ts$",
		target = "/src/app/components/%1/%1.component.scss",
		context = "scss",
	},
}

return M
