local M = {}

M.laravel = {
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

-- default alternative targets
local rails_alternative_targets = {
	{ context = "model", target = "/app/models/%1.rb", transformer = "singularize" },
	{ context = "controller", target = "/app/controllers/%1_controller.rb"},
	{ context = "view", target = "/app/views/%1/*.html*" },
	{ context = "view", target = "/app/views/%1/*.html*", transformer = "singularize" },
	{ context = "channel", target = "/app/channels/%1_channel.rb" },
	{ context = "mailer", target = "/app/mailers/%1_mailer.rb" },
	{ context = "serializer", target = "/app/serializers/%1_serializer.rb" },
	{ context = "mailer", target = "/app/mailers/%1_mailer.rb" },
	{ context = "service", target = "/app/services/%1_service.rb" },
	{ context = "worker", target = "/app/workers/**/%1_worker.rb" },
	{ context = "factories", target = "/spec/factories/%1.rb", transformer = "singularize" },
}

M.rails = {
	{
		-- generic test mapping for minitest and rspec
		pattern = "/app/(.*)/(.*).rb",
		target = {
			{ context = "test", target = "/test/unit/%1/%2_test.rb" },
			{ context = "test", target = "/test/functional/%1/%2_test.rb" },
			{ context = "test", target = "/test/functional/%2_test.rb" },
			{ context = "test", target = "/test/integration/%1/%2_test.rb" },
			{ context = "test", target = "/test/integration/%2_test.rb" },

			{ context = "test", target = "/test/%1/%2_test.rb" },
			{ context = "test", target = "/test/%1/%2_test.rb" },
			{ context = "test", target = "/test/%2_test.rb" },
			{ context = "test", target = "/test/%1/%2_test.rb" },
			{ context = "test", target = "/test/%2_test.rb" },

			{ context = "test", target = "/spec/unit/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/functional/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/functional/%2_spec.rb" },
			{ context = "test", target = "/spec/integration/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/integration/%2_spec.rb" },

			{ context = "test", target = "/spec/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/%2_spec.rb" },
			{ context = "test", target = "/spec/%1/%2_spec.rb" },
			{ context = "test", target = "/spec/%2_spec.rb" },
		},
	},
	-- going back to source from tests
	{
		pattern = "/test/unit/(.*)/(.*)_test.rb",
		target = {
			{ target = "/app/%1/%2.rb" },
		}
	},
	{
		pattern = "/test/functional/(.*)_(.*)_test.rb",
		target = {
			{ target = "/app/%2s/%1_%2.rb" },
		}
	},
	{
		pattern = "/test/integration/(.*)_(.*)_test.rb",
		target = {
			{ target = "/app/%2s/%1_%2.rb" },
		}
	},
	-- Additional mappings per filetype
	{
		pattern = "/app/controllers/(.*)_controller.rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/views/(.*)/.+.html*",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/models/(.*).rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/channels/(.*)_channel.rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/mailers/(.*)_mailer.rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/serializers/(.*)_serializer.rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/services/(.*)_service.rb",
		target = rails_alternative_targets,
	},
	{
		pattern = "/app/workers/(.*)/(.*)_worker.rb",
		target = rails_alternative_targets,
	}
}

M.livewire = {
	{
		pattern = "/app/Http/Livewire/(.*)/.*php",
		target = "/resources/views/livewire/%1/",
		transformer = "camelToKebap",
		context = "view",
	},
	{
		pattern = "/resources/views/livewire/(.*)/.*",
		target = "/app/Http/Livewire/%1/",
		transformer = "kebapToCamel",
		context = "controller",
	},
}

M.angular = {
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
}

return M
