return {
	{
		pattern = "(.*).([tj]sx?)$",
		target = "%1.test.%2",
		context = "test",
	},
	{
		pattern = "(.*).test.([tj]sx?)$",
		target = "%1.%2",
		context = "implementation",
	},
}
