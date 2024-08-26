return {
	-- based on https://doc.rust-lang.org/cargo/guide/project-layout.html#package-layout
	-- tests
	{
		context = "test file nested",
		pattern = "/src/(.*)/(.*)%.rs$",
		target = "/tests/%1/test_%2.rs",
	},
	{
		context = "implementation file nested",
		pattern = "/tests/(.*)/test_(.*)%.rs$",
		target = "/src/%1/%2.rs",
	},
	{
		context = "test file top-level",
		pattern = "/src/(.*)%.rs$",
		target = "/tests/test_%1.rs",
	},
	{
		context = "implementation file top-level",
		pattern = "/tests/test_(.*)%.rs$",
		target = "/src/%1.rs",
	},
	-- benchmarks
	{
		context = "benchmark file nested",
		pattern = "/src/(.*)/(.*)%.rs$",
		target = "/benches/%1/bench_%2.rs",
	},
	{
		context = "implementation file nested",
		pattern = "/benches/(.*)/bench_(.*)%.rs$",
		target = "/src/%1/%2.rs",
	},
	{
		context = "benchmark file top-level",
		pattern = "/src/(.*)%.rs$",
		target = "/benches/bench_%1.rs",
	},
	{
		context = "implementation file top-level",
		pattern = "/benches/bench_(.*)%.rs$",
		target = "/src/%1.rs",
	},
	-- examples
	{
		context = "example file nested",
		pattern = "/src/(.*)/(.*)%.rs$",
		target = "/examples/%1/ex_%2.rs",
	},
	{
		context = "implementation file nested",
		pattern = "/examples/(.*)/ex_(.*)%.rs$",
		target = "/src/%1/%2.rs",
	},
	{
		context = "example file top-level",
		pattern = "/src/(.*)%.rs$",
		target = "/examples/ex_%1.rs",
	},
	{
		context = "implementation file top-level",
		pattern = "/examples/ex_(.*)%.rs$",
		target = "/src/%1.rs",
	},
}
