return {
	{
		pattern = "/(.*)/(.*)/.*.ts$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%2.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/.*.html$",
		target = {
			{
				target = "/%1/%2/%2.component.ts",
				context = "component",
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%2.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/.*.scss$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%2.component.ts",
				context = "component",
			},
			{
				target = "/%1/%2/%2.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/.*.spec.ts$",
		target = {
			{
				target = "/%1/%2/%2.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%2.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%2.component.ts",
				context = "component",
			},
		},
	},
	{
		pattern = "/(.*)/(.*).service.ts$",
		target = {
			{
				target = "/%1/%2.service.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*).service.spec.ts$",
		target = {
			{
				target = "/%1/%2.service.ts",
				context = "service",
			},
		},
	},
}
