return {
	{
		context = "test",
		pattern = "(.*).go$",
		target = "%1_test.go",
	},
	{
		context = "implementation",
		pattern = "(.*)_test.go$",
		target = "%1.go",
	},
}
