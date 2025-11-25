-- LSP result deduplication
-- This module wraps LSP textDocument/definition and textDocument/references
-- to remove duplicate results before they're displayed in Telescope

local M = {}

function M.setup()
  -- Defer setup until after LSP is fully loaded
  vim.api.nvim_create_autocmd("LspAttach", {
    once = false,
    callback = function()
      -- Only setup once
      if M._setup_done then
        return
      end
      M._setup_done = true
      
      -- Wait a bit to ensure all handlers are loaded
      vim.defer_fn(function()
        M._do_setup()
      end, 100)
    end,
  })
end

function M._do_setup()
  -- Store original handlers
  local orig_definition = vim.lsp.handlers["textDocument/definition"]
  local orig_references = vim.lsp.handlers["textDocument/references"]
  
  -- Helper function to deduplicate LSP location results
  local function dedupe_locations(locations)
    if not locations then
      return nil
    end
    
    -- Handle single location
    if locations.uri or locations.targetUri then
      return locations
    end
    
    -- Handle array of locations
    if type(locations) ~= "table" or #locations == 0 then
      return locations
    end
    
    local seen = {}
    local result = {}
    local removed_count = 0
    
    for _, loc in ipairs(locations) do
      -- Get the URI and range
      local uri = loc.uri or loc.targetUri
      local range = loc.range or loc.targetRange or loc.targetSelectionRange
      
      if uri and range and range.start then
        -- Create unique key
        local key = string.format("%s:%d:%d:%d:%d",
          uri,
          range.start.line or 0,
          range.start.character or 0,
          (range["end"] or {}).line or 0,
          (range["end"] or {}).character or 0
        )
        
        if not seen[key] then
          seen[key] = true
          table.insert(result, loc)
        else
          removed_count = removed_count + 1
        end
      else
        -- If we can't create a key, include it anyway
        table.insert(result, loc)
      end
    end
    
    if removed_count > 0 then
      vim.notify(string.format("Removed %d duplicate LSP result(s)", removed_count), vim.log.levels.INFO)
    end
    
    return result
  end
  
  -- Override textDocument/definition
  vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    local deduped = dedupe_locations(result)
    return orig_definition(err, deduped, ctx, config)
  end
  
  -- Override textDocument/references  
  vim.lsp.handlers["textDocument/references"] = function(err, result, ctx, config)
    local deduped = dedupe_locations(result)
    return orig_references(err, deduped, ctx, config)
  end
end

return M
