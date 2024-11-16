local rootPath = vim.loop.cwd()

-- Closing all buffers.
local function closeAllBuffers()
	local buffers = vim.api.nvim_list_bufs()
	for _, buffer in pairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buffer) and vim.api.nvim_buf_is_valid(buffer) then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end
	end
end

local function runOther(filename)
	closeAllBuffers()
	vim.cmd([[
		command! -nargs=* Other lua require('other-nvim').open(<f-args>)
		command! -nargs=* OtherTabNew lua require('other-nvim').openTabNew(<f-args>)
		command! -nargs=* OtherSplit lua require('other-nvim').openSplit(<f-args>)
		command! -nargs=* OtherVSplit lua require('other-nvim').openVSplit(<f-args>)
		command! -nargs=* OtherClear lua require('other-nvim').clear(<f-args>)
	]])

	local fnInput = rootPath .. filename

	vim.api.nvim_command(":e " .. fnInput)
	vim.api.nvim_command(":Other")
end

local function checkForStringAtPos(position, string)
	local lastmatches = vim.g.other_lastmatches
	local result = nil

	if lastmatches[position] ~= nil then
		result = lastmatches[position].filename:find(string) ~= nil
	end
	if result == nil then
		print(position, string)
	end
	if result == false then
		print(position, lastmatches[position].filename, string)
	end
	return result
end

describe("rails-mapping", function()
	it("minitest", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				"rails",
			},
		})

		runOther("/lua/spec/fixtures/rails-minitest/app/channels/user_channel.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/channels/user_channel_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/channels/api/v1/feature_channel.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/channels/api/v1/feature_channel_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/api/v1/feature_controller.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/channels/user_channel.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/channels/user_channel_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/controllers/api/v1/feature_controller.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/controllers/api/v1/feature_controller_test.rb"))
		assert.is_true(checkForStringAtPos(2, "test/functional/api/v1/feature_controller_test.rb"))
		assert.is_true(checkForStringAtPos(3, "test/functional/api/v2/feature_controller_test.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(4, "test/integration/api/v1/feature_controller_test.rb"))
		assert.is_true(checkForStringAtPos(5, "test/integration/api/v2/feature_controller_test.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(6, "app/channels/api/v1/feature_channel.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/controllers/api/v2/feature_controller.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/controllers/api/v2/feature_controller_test.rb"))
		assert.is_true(checkForStringAtPos(2, "test/functional/api/v1/feature_controller_test.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(3, "test/functional/api/v2/feature_controller_test.rb"))
		assert.is_true(checkForStringAtPos(4, "test/integration/api/v1/feature_controller_test.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(5, "test/integration/api/v2/feature_controller_test.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/controllers/user_controller.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/controllers/user_controller_test.rb"))
		assert.is_true(checkForStringAtPos(2, "test/functional/user_controller_test.rb"))
		assert.is_true(checkForStringAtPos(3, "test/integration/user_controller_test.rb"))
		assert.is_true(checkForStringAtPos(4, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(6, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(7, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(8, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(10, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(11, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/mailers/user_mailer.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/mailers/user_mailer_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/models/submodule/subfeature.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/models/submodule/subfeature_test.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/models/feature.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/models/feature_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/api/v1/feature_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/api/v2/feature_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/channels/api/v1/feature_channel.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/models/user.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/models/user_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(5, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/serializers/user_serializer.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/serializers/user_serializer_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/services/user_service.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/services/user_service_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/views/user/create.html")
		assert.is_true(checkForStringAtPos(1, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(4, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(5, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(6, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(8, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/views/user/index.html")
		assert.is_true(checkForStringAtPos(1, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(4, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(5, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(6, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(8, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/workers/user/user_worker.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/workers/user/user_worker_test.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/services/user_service.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/app/workers/general_worker.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/workers/general_worker_test.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/db/migrations/20220923181300_add_email_to_user.rb")
		assert.is_true(checkForStringAtPos(1, "test/migrations/20220923181300_add_email_to_user_test.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/lib/core_ext/string.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/lib/core_ext/string_test.rb"))

		runOther("/lua/spec/fixtures/rails-minitest/lib/user_helper.rb")
		assert.is_true(checkForStringAtPos(1, "test/unit/lib/user_helper_test.rb"))
	end)

	it("rspec", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				"rails",
			},
		})

		runOther("/lua/spec/fixtures/rails-rspec/app/channels/user_channel.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/channels/user_channel_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/channels/api/v1/feature_channel.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/channels/api/v1/feature_channel_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/api/v1/feature_controller.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/channels/user_channel.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/channels/user_channel_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/controllers/api/v1/feature_controller.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/controllers/api/v1/feature_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "spec/functional/api/v1/feature_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(3, "spec/functional/api/v2/feature_controller_spec.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(4, "spec/integration/api/v1/feature_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(5, "spec/integration/api/v2/feature_controller_spec.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(6, "app/channels/api/v1/feature_channel.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/controllers/api/v2/feature_controller.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/controllers/api/v2/feature_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "spec/functional/api/v1/feature_controller_spec.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(3, "spec/functional/api/v2/feature_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(4, "spec/integration/api/v1/feature_controller_spec.rb")) -- WRONG !!!
		assert.is_true(checkForStringAtPos(5, "spec/integration/api/v2/feature_controller_spec.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/controllers/user_controller.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/controllers/user_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "spec/functional/user_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(3, "spec/integration/user_controller_spec.rb"))
		assert.is_true(checkForStringAtPos(4, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(6, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(7, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(8, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(10, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(11, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/mailers/user_mailer.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/mailers/user_mailer_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/models/submodule/subfeature.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/models/submodule/subfeature_spec.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/models/feature.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/models/feature_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/api/v1/feature_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/api/v2/feature_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/channels/api/v1/feature_channel.rb"))
		assert.is_true(checkForStringAtPos(5, "spec/factories/features.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/models/user.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/models/user_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(5, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(6, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/models/spec.rb")
		assert.is_true(checkForStringAtPos(1, "spec/factories/specs.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/serializers/user_serializer.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/serializers/user_serializer_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/services/user_service.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/services/user_service_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/views/user/create.html")
		assert.is_true(checkForStringAtPos(1, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(4, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(5, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(6, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(8, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/views/user/index.html")
		assert.is_true(checkForStringAtPos(1, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(2, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(3, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(4, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(5, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(6, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(7, "app/services/user_service.rb"))
		assert.is_true(checkForStringAtPos(8, "app/workers/user/user_worker.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/workers/user/user_worker.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/workers/user/user_worker_spec.rb"))
		assert.is_true(checkForStringAtPos(2, "app/models/user.rb"))
		assert.is_true(checkForStringAtPos(3, "app/controllers/user_controller.rb"))
		assert.is_true(checkForStringAtPos(4, "app/views/user/create.html"))
		assert.is_true(checkForStringAtPos(5, "app/views/user/index.html"))
		assert.is_true(checkForStringAtPos(6, "app/channels/user_channel.rb"))
		assert.is_true(checkForStringAtPos(7, "app/mailers/user_mailer.rb"))
		assert.is_true(checkForStringAtPos(8, "app/serializers/user_serializer.rb"))
		assert.is_true(checkForStringAtPos(9, "app/services/user_service.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/app/workers/general_worker.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/workers/general_worker_spec.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/db/migrations/20220923181300_add_email_to_user.rb")
		assert.is_true(checkForStringAtPos(1, "spec/migrations/20220923181300_add_email_to_user_spec.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/lib/core_ext/string.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/lib/core_ext/string_spec.rb"))

		runOther("/lua/spec/fixtures/rails-rspec/lib/user_helper.rb")
		assert.is_true(checkForStringAtPos(1, "spec/unit/lib/user_helper_spec.rb"))
	end)
end)

describe("angular", function()
	it("mappings", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				"angular",
			},
		})

		runOther("/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.html")
		assert.is_true(checkForStringAtPos(1, "components/my%-component/my%-component.component.ts"))
		assert.is_true(checkForStringAtPos(2, "components/my%-component/my%-component.component.scss"))
		assert.is_true(checkForStringAtPos(3, "components/my%-component/my%-component.component.spec.ts"))

		runOther("/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.ts")
		assert.is_true(checkForStringAtPos(1, "components/my%-component/my%-component.component.html"))
		assert.is_true(checkForStringAtPos(2, "components/my%-component/my%-component.component.scss"))
		assert.is_true(checkForStringAtPos(3, "components/my%-component/my%-component.component.spec.ts"))

		runOther("/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.scss")
		assert.is_true(checkForStringAtPos(1, "components/my%-component/my%-component.component.html"))
		assert.is_true(checkForStringAtPos(2, "components/my%-component/my%-component.component.ts"))
		assert.is_true(checkForStringAtPos(3, "components/my%-component/my%-component.component.spec.ts"))

		runOther("/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.spec.ts")
		assert.is_true(checkForStringAtPos(1, "components/my%-component/my%-component.component.html"))
		assert.is_true(checkForStringAtPos(2, "components/my%-component/my%-component.component.scss"))
		assert.is_true(checkForStringAtPos(3, "components/my%-component/my%-component.component.ts"))

		runOther("/lua/spec/fixtures/angular/src/my-module/my-component/my-component.component.html")
		assert.is_true(checkForStringAtPos(1, "my%-module/my%-component/my%-component.component.ts"))
		assert.is_true(checkForStringAtPos(2, "my%-module/my%-component/my%-component.component.spec.ts"))

		runOther("/lua/spec/fixtures/angular/src/my-module/my-component/my-component.component.ts")
		assert.is_true(checkForStringAtPos(1, "my%-module/my%-component/my%-component.component.html"))
		assert.is_true(checkForStringAtPos(2, "my%-module/my%-component/my%-component.component.spec.ts"))

		runOther("/lua/spec/fixtures/angular/src/my-module/my-component/my-component.component.spec.ts")
		assert.is_true(checkForStringAtPos(1, "my%-module/my%-component/my%-component.component.html"))
		assert.is_true(checkForStringAtPos(2, "my%-module/my%-component/my%-component.component.ts"))
	end)
end)

describe("laravel", function()
	it("mappings", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				"laravel",
			},
		})

		runOther("/lua/spec/fixtures/laravel/app/Http/Controllers/BarController.php")
		assert.is_true(checkForStringAtPos(1, "views/bar/edit.blade.php"))
		assert.is_true(checkForStringAtPos(2, "views/bar/index.blade.php"))

		runOther("/lua/spec/fixtures/laravel/app/Http/Controllers/FooController.php")
		assert.is_true(checkForStringAtPos(1, "views/foo/index.blade.php"))
	end)
end)

-- describe("livewire", function()
-- 	it("mappings", function()
-- 		require("other-nvim").setup({
-- 			showMissingFiles = false,
-- 			mappings = {
-- 				"livewire",
-- 			},
-- 		})
--
-- 		runOther("/lua/spec/fixtures/livewire/app/Http/livewire/MyThing/Edit/MyComponent.php")
-- 		assert.is_true(checkForStringAtPos(1, "views/livewire/my%-thing/edit/view1.blade.php"))
-- 		assert.is_true(checkForStringAtPos(2, "views/livewire/my%-thing/edit/view2.blade.php"))
-- 	end)
-- end)

describe("python", function()
	it("mappings", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				"python",
			},
		})

		runOther("/lua/spec/fixtures/python/module1.py")
		assert.is_true(checkForStringAtPos(1, "test_module1.py"))
		assert.is_true(checkForStringAtPos(2, "test_module1.py"))
		assert.is_true(checkForStringAtPos(3, "test_module1.py"))

		runOther("/lua/spec/fixtures/python/tests/test_module1.py")
		assert.is_true(checkForStringAtPos(1, "module1.py"))

		runOther("/lua/spec/fixtures/python/tests/unit/test_module1.py")
		assert.is_true(checkForStringAtPos(1, "module1.py"))
	end)
end)

describe("react", function()
	it("mappings", function()
		require("other-nvim").setup({
			mappings = {
				"react",
			},
		})

		runOther("lua/spec/fixtures/react/util.js")
		assert.is_true(checkForStringAtPos(1, "util.test.js"))

		runOther("lua/spec/fixtures/react/util.test.js")
		assert.is_true(checkForStringAtPos(2, "util.js"))

		runOther("lua/spec/fixtures/react/util.ts")
		assert.is_true(checkForStringAtPos(1, "util.test.ts"))

		runOther("lua/spec/fixtures/react/util.test.ts")
		assert.is_true(checkForStringAtPos(2, "util.ts"))

		runOther("lua/spec/fixtures/react/Component.jsx")
		assert.is_true(checkForStringAtPos(1, "Component.test.jsx"))

		runOther("lua/spec/fixtures/react/Component.test.jsx")
		assert.is_true(checkForStringAtPos(2, "Component.jsx"))

		runOther("lua/spec/fixtures/react/Component.tsx")
		assert.is_true(checkForStringAtPos(1, "Component.test.tsx"))

		runOther("lua/spec/fixtures/react/Component.test.tsx")
		assert.is_true(checkForStringAtPos(2, "Component.tsx"))
	end)
end)

describe("rust", function()
	it("mappings", function()
		require("other-nvim").setup({
			showMissingFiles = true,
			mappings = {
				"rust",
			},
		})

		-- tests

		-- top level
		runOther("/lua/spec/fixtures/rust/src/mod.rs")
		assert.is_true(checkForStringAtPos(1, "tests/test_mod.rs"))

		runOther("/lua/spec/fixtures/rust/tests/test_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/mod.rs"))
		-- nested
		runOther("/lua/spec/fixtures/rust/src/subdir/mod.rs")
		assert.is_true(checkForStringAtPos(1, "tests/subdir/test_mod.rs"))

		runOther("/lua/spec/fixtures/rust/tests/subdir/test_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/subdir/mod.rs"))

		-- benchmarks

		-- top level
		runOther("/lua/spec/fixtures/rust/src/mod.rs")
		assert.is_true(checkForStringAtPos(2, "/benches/bench_mod.rs"))

		runOther("/lua/spec/fixtures/rust/benches/bench_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/mod.rs"))
		-- nested
		runOther("/lua/spec/fixtures/rust/src/subdir/mod.rs")
		assert.is_true(checkForStringAtPos(3, "/benches/subdir/bench_mod.rs"))

		runOther("/lua/spec/fixtures/rust/benches/subdir/bench_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/subdir/mod.rs"))

		-- examples

		-- top level
		runOther("/lua/spec/fixtures/rust/src/mod.rs")
		assert.is_true(checkForStringAtPos(3, "/examples/ex_mod.rs"))

		runOther("/lua/spec/fixtures/rust/examples/ex_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/mod.rs"))
		-- nested
		runOther("/lua/spec/fixtures/rust/src/subdir/mod.rs")
		assert.is_true(checkForStringAtPos(2, "/examples/subdir/ex_mod.rs"))

		runOther("/lua/spec/fixtures/rust/examples/subdir/ex_mod.rs")
		assert.is_true(checkForStringAtPos(1, "/src/subdir/mod.rs"))
	end)
end)

describe("function-mappings", function()
	it("basic function pattern", function()
		require("other-nvim").setup({
			showMissingFiles = false,
			mappings = {
				{
					pattern = function(filename)
						local component = { filename:match("/(.*)/(.*)/([a-zA-Z-_]*).*.ts$") }
						if #component > 0 then
							return component
						end
						return nil
					end,
					target = "/%1/%2/%3.component.scss",
					context = "styles",
				},
			},
		})

		runOther("/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.ts")

		assert.is_true(checkForStringAtPos(1, "my%-component.component.scss"))
	end)
end)
