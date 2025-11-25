-- Debug helper to check LSP clients
vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_active_clients()
  print("Active LSP clients:")
  for _, client in ipairs(clients) do
    print(string.format("  - %s (id: %d, buffers: %s)", 
      client.name, 
      client.id,
      vim.inspect(vim.lsp.get_buffers_by_client_id(client.id))
    ))
  end
end, {})

-- Debug command to check keymaps
vim.api.nvim_create_user_command("CheckKeymaps", function()
  local buf = vim.api.nvim_get_current_buf()
  local keymaps = vim.api.nvim_buf_get_keymap(buf, "n")
  print("Buffer keymaps for 'gd':")
  for _, map in ipairs(keymaps) do
    if map.lhs == "gd" then
      print(vim.inspect(map))
    end
  end
  
  print("\nGlobal keymaps for 'gd':")
  local global_maps = vim.api.nvim_get_keymap("n")
  for _, map in ipairs(global_maps) do
    if map.lhs == "gd" then
      print(vim.inspect(map))
    end
  end
end, {})
