local M = {}

M.is_supported = function()
  return vim.fn.exists("*fzf#run") ~= 0
end

local function clear_callback()
  _G.dressing_fzf_choice = function() end
  _G.dressing_fzf_cancel = function() end
end

clear_callback()

M.select = function(config, items, opts, on_choice)
  local labels = {}
  for i, item in ipairs(items) do
    table.insert(labels, string.format("%d: %s", i, opts.format_item(item)))
  end
  _G.dressing_fzf_cancel = function()
    clear_callback()
    on_choice(nil, nil)
  end
  _G.dressing_fzf_choice = function(label)
    clear_callback()
    local colon = string.find(label, ":")
    local lnum = tonumber(string.sub(label, 1, colon - 1))
    local item = items[lnum]
    on_choice(item, lnum)
  end
  vim.fn["dressing#fzf_run"](labels, string.format('--prompt="%s"', opts.prompt), config.window)
  -- fzf doesn't have a cancel callback, so we have to make one.
  -- the defer_fn is so that we can process the confirm event first
  vim.cmd([[autocmd BufLeave <buffer> lua vim.defer_fn(function() dressing_fzf_cancel() end, 5)]])
end

return M
