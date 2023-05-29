return {
	{
		pattern = "/app/Http/Controllers/(.*)Controller.php$",
		target = "/resources/views/%1/",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/resources/views/(.*)/.*",
		target = "/app/Http/Controllers/%1Controller.php",
		transformer = "kebapToCamel",
		context = "controller",
	},
}
