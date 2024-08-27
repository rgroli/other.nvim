return {
	{
		pattern = "/app/Http/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/app/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/app/Livewire/(.*).*php",
		target = "/resources/views/livewire/%1.blade.php",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Http/Livewire/%1/",
		transformer = "kebapToCamel",
		context = "controller",
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Livewire/%1/",
		transformer = "kebapToCamel",
		context = "controller",
	},
	{
		pattern = "/resources/views/livewire/(.*).blade.php",
		target = "/app/Livewire/%1.php",
		transformer = "kebapToCamel",
		context = "controller",
	},
}
