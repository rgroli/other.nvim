return {
	{
		pattern = "/(.*)/(.*)/([a-zA-Z-_]*).*.ts$",
		target = {
			{
				target = "/%1/%2/%3.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%3.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%3.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/([a-zA-Z-_]*).*html$",
		target = {
			{
				target = "/%1/%2/%3.component.ts",
				context = "component",
			},
			{
				target = "/%1/%2/%3.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%3.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/([a-zA-Z-_]*).*scss$",
		target = {
			{
				target = "/%1/%2/%3.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%3.component.ts",
				context = "component",
			},
			{
				target = "/%1/%2/%3.component.spec.ts",
				context = "test",
			},
		},
	},
	{
		pattern = "/(.*)/(.*)/([a-zA-Z-_]*).*spec.ts$",
		target = {
			{
				target = "/%1/%2/%3.component.html",
				context = "html",
			},
			{
				target = "/%1/%2/%3.component.scss",
				context = "scss",
			},
			{
				target = "/%1/%2/%3.component.ts",
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
