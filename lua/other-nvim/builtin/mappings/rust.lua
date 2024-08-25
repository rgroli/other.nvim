return {
	-- based on https://doc.rust-lang.org/cargo/guide/project-layout.html#package-layout
	-- tests
	{
		context = "test file",
		pattern = "(.*)/(.*)%.rs$",
		target = "**/test_%2.rs",
	},
	{
		context = "implementation file",
		pattern = "(.*)/test_(.*)%.rs$",
		target = "**/%2.rs",
	},
	-- benchmarks
	{
		context = "benchmark file",
		pattern = "(.*)/(.*)%.rs$",
		target = "**/bench_%2.rs",
	},
	{
		context = "implementation file",
		pattern = "(.*)/bench_(.*)%.rs$",
		target = "**/%2.rs",
	},
	-- examples
	{
		context = "example file",
		pattern = "(.*)/(.*)%.rs$",
		target = "**/ex_%2.rs",
	},
	{
		context = "implementation file",
		pattern = "(.*)/ex_(.*)%.rs$",
		target = "**/%2.rs",
	},
}
