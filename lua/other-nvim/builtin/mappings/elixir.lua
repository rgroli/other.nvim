return {
	{
		context = "test file",
		pattern = "lib/(.*).ex$",
		target = "test/%1_test.exs",
	},
	{
		context = "implementation file",
		pattern = "test/(.*)_test.exs$",
		target = "lib/%1.ex",
	},
}
