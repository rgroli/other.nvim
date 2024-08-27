return {
	{
		context = "associated test file",
		pattern = "(.*)/(.*)%.py$",
		target = "**/test_%2.py",
	},
	{
		context = "associated implementation file",
		pattern = "(.*)/test_(.*)%.py$",
		target = "**/%2.py",
	},
}
