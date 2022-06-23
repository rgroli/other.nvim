local rootPath = vim.loop.cwd()

-- Getting the content of a buffer as lua table.
function getBufferContent(buffer)
	return vim.api.nvim_buf_get_lines(buffer, 0, vim.api.nvim_buf_line_count(buffer), false)
end

-- Closing all buffers.
function closeAllBuffers()
	local buffers = vim.api.nvim_list_bufs()
	for _, buffer in pairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buffer) and vim.api.nvim_buf_is_valid(buffer) then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end
	end
end

-- Actual Testcases
describe("angular-mapping", function()
	it("Show the correct other file", function()
		require("other-nvim").setup({
			mappings = {
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
			},
		})
		closeAllBuffers()
		local fnInput = rootPath
			.. "/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.html"
		local fnExpected = rootPath
			.. "/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.ts"

		vim.api.nvim_command(":e " .. fnInput)
		vim.api.nvim_command(":Other")

		assert.equals(fnExpected, vim.api.nvim_buf_get_name(0))

		vim.api.nvim_command(":Other")
		local lines = getBufferContent(0)

		assert.equals(lines[1], "html | my-component.component.html")
		assert.equals(lines[2], "scss | my-component.component.scss")

		vim.api.nvim_feedkeys("o", "x", true)
		assert.equals(fnInput, vim.api.nvim_buf_get_name(0))
	end)

	it("Show filepicker when there's more than one match", function()
		closeAllBuffers()
		local fnInput = rootPath
			.. "/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.ts"
		vim.api.nvim_command(":e " .. fnInput)
		vim.api.nvim_command(":Other")

		local lines = getBufferContent(0)

		assert.equals(lines[1], "html | my-component.component.html")
		assert.equals(lines[2], "scss | my-component.component.scss")
	end)

	it("Show filepicker when there's more than one match and open a file", function()
		closeAllBuffers()

		local fnInput = rootPath
			.. "/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.ts"
		local fnExpected = rootPath
			.. "/lua/spec/fixtures/angular/src/app/components/my-component/my-component.component.scss"
		vim.api.nvim_command(":e " .. fnInput)
		vim.api.nvim_command(":Other")

		local lines = getBufferContent(0)
		assert.equals(lines[1], "html | my-component.component.html")
		assert.equals(lines[2], "scss | my-component.component.scss")

		vim.api.nvim_feedkeys("j", "x", true)
		vim.api.nvim_feedkeys("o", "x", true)
		assert.equals(vim.api.nvim_buf_get_name(0), fnExpected)
	end)
end)
