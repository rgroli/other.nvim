return {
	{
		context = "test",
		pattern = "lib/(.*).ex$",
		target = "test/%1_test.exs",
	},
	{
		context = "implementation",
		pattern = "test/(.*)_test.exs$",
		target = "lib/%1.ex",
	},
}
