-- File: ~/.config/nvim/lua/plugins/custom.lua
-- THIS IS NOW YOUR ONLY FILE FOR PERSONAL SETTINGS
return {
	-- 1. FORMATTING
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				lua = { "stylua" },
			},
		},
	},

	-- 2. LSP CONFIGURATION (Consolidated - Tailwind, TypeScript, Auto-imports, Keybindings)
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Disable LazyVim's default LSP keybindings to prevent duplicates
			opts.diagnostics = opts.diagnostics or {}
			opts.diagnostics.update_in_insert = false
			
			-- Configure servers
			opts.servers = opts.servers or {}
			opts.servers.tailwindcss = {
				settings = {
					tailwindCSS = {
						classAttributes = { "class", "className", "classList", "ngClass" },
						lint = {
							cssConflict = "warning",
							invalidApply = "error",
							invalidConfigPath = "error",
							invalidScreen = "error",
							invalidTailwindDirective = "error",
							invalidVariant = "error",
							recommendedVariantOrder = "warning",
						},
						validate = true,
					},
				},
			}
			
			return opts
		end,
		keys = function()
			-- Return empty table to disable ALL LazyVim's default LSP keybindings
			return {}
		end,
		init = function()
			-- Track which buffers already have keybindings set to prevent duplicates
			local keymaps_set = {}
			
			-- Set up keybindings when LSP attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					-- Skip if we've already set keybindings for this buffer
					if keymaps_set[event.buf] then
						return
					end
					keymaps_set[event.buf] = true
					
					-- Clean up tracking when buffer is deleted
					vim.api.nvim_create_autocmd("BufDelete", {
						buffer = event.buf,
						once = true,
						callback = function()
							keymaps_set[event.buf] = nil
						end,
					})
					
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- LSP Navigation with explicit buffer-only mappings
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "LSP: Go to Declaration" })
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "LSP: Go to Implementation" })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = event.buf, desc = "LSP: Hover Documentation" })
					
					-- Custom gd and gr with deduplication
					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition({
							on_list = function(options)
								-- Deduplicate items
								local items = options.items or {}
								local seen = {}
								local unique_items = {}
								
								for _, item in ipairs(items) do
									local key = string.format("%s:%d:%d", item.filename or "", item.lnum or 0, item.col or 0)
									if not seen[key] then
										seen[key] = true
										table.insert(unique_items, item)
									end
								end
								
								options.items = unique_items
								vim.fn.setqflist({}, ' ', options)
								vim.cmd('Telescope quickfix')
							end
						})
					end, { buffer = event.buf, desc = "LSP: Go to Definition" })
					
					vim.keymap.set("n", "gr", function()
						vim.lsp.buf.references(nil, {
							on_list = function(options)
								-- Deduplicate items
								local items = options.items or {}
								local seen = {}
								local unique_items = {}
								
								for _, item in ipairs(items) do
									local key = string.format("%s:%d:%d", item.filename or "", item.lnum or 0, item.col or 0)
									if not seen[key] then
										seen[key] = true
										table.insert(unique_items, item)
									end
								end
								
								options.items = unique_items
								vim.fn.setqflist({}, ' ', options)
								vim.cmd('Telescope quickfix')
							end
						})
					end, { buffer = event.buf, desc = "LSP: Go to References" })

					-- Code Actions and Auto-Import
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("<leader>ai", function()
						vim.lsp.buf.code_action({
							apply = true,
							context = {
								only = { "source.addMissingImports" },
								diagnostics = {},
							},
						})
					end, "Add Missing Imports")

					-- Note: TypeScript-specific keymaps (like <leader>cR for rename file)
					-- are now in typescript.lua using typescript-tools.nvim
				end,
			})
		end,
	},
}
