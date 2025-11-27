return {
	"Exafunction/codeium.nvim",
	event = "InsertEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		enable_cmp_source = false,
		virtual_text = {
			enabled = true,
		key_bindings = {
			accept = "<M-CR>",
			next = "<M-]>",
			prev = "<M-[>",
			clear = "<C-]>",
		},
		},
	},
}
