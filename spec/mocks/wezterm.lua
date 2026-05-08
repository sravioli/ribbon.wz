---Minimal wezterm mock for testing outside WezTerm.

if package.loaded["wezterm"] then
  return package.loaded["wezterm"]
end

local M = {}

M._calls = {}

local function record(name, returns)
  return function(...)
    table.insert(M._calls, { fn = name, args = { ... } })
    return returns
  end
end

M.log_info = record "log_info"
M.log_warn = record "log_warn"
M.log_error = record "log_error"
M.format = record("format", "<formatted>")

function M.to_string(value)
  return tostring(value)
end

M.plugin = {
  list = function()
    return {}
  end,
}

M.GLOBAL = {}

function M._reset()
  M._calls = {}
  M.GLOBAL = {}
end

package.loaded["wezterm"] = M

return M
