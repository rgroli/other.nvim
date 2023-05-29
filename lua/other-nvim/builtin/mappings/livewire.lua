return {
	{
		pattern = "/app/Http/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Http/Livewire/%1/",
		transformer = "kebapToCamel",
		context = "controller",
	},
}
