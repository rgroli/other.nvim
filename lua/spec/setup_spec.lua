describe("different mappings", function()
	it("Check mapping combinations", function()
		require("other-nvim").setup({
			mappings = {
				"laravel",
			},
		})
		assert.are.same(require("other-nvim").getOptions().mappings, require("other-nvim.builtin.mappings").laravel)
	end)

	it("Check mapping combinations multiple targets", function()
		require("other-nvim").setup({
			mappings = {
				{
					pattern = "(.*).ts$",
					target = {
						"%1.spec.ts",
						"%1.scss",
						{
							target = "%1.html",
							transformer = "camelToKebap",
							context = "html"
						},
					},
				},
			},
		})

		local expected = {
			{
				pattern = "(.*).ts$",
				target = "%1.spec.ts",
			},
			{
				pattern = "(.*).ts$",
				target = "%1.scss",
			},
			{
				pattern = "(.*).ts$",
				target = "%1.html",
				transformer = "camelToKebap",
				context = "html"
			},
		}
		assert.are.same(require("other-nvim").getOptions().mappings, expected)
	end)
end)
