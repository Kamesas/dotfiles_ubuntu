return {
	"barrett-ruth/import-cost.nvim",
	build = "sh install.sh npm",
	-- Only load for JavaScript/TypeScript files
	ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	config = function()
		require("import-cost").setup({
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
		})
	end,
}
