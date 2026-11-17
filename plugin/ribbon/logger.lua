---@module "ribbon.logger"

local wezterm = require "wezterm" --[[@as Wezterm]]

---@class Ribbon.Logger
---@field tag string
---@field enabled boolean
---@field threshold integer
local M = {}
M.__index = M

local levels = { DEBUG = 0, INFO = 1, WARN = 2, ERROR = 3 }

---@param value any
---@return string
local function stringify(value)
  if type(value) == "string" then
    return value
  end
  local ok, rendered = pcall(wezterm.to_string, value) ---@diagnostic disable-line: undefined-field
  return ok and type(rendered) == "string" and rendered or tostring(value)
end

---@param tag string
---@param cfg? Ribbon.LogConfig
---@return Ribbon.Logger
function M.new(tag, cfg)
  cfg = cfg or {}
  local threshold = cfg.threshold
  if type(threshold) ~= "number" then
    threshold = levels[tostring(threshold or "WARN"):upper()] or levels.WARN
  end
  return setmetatable({ tag = tag, enabled = cfg.enabled ~= false, threshold = threshold }, M)
end

---@param level integer
---@param message any
---@param ... any
function M:write(level, message, ...)
  if not self.enabled or level < self.threshold then
    return nil
  end
  local text = stringify(message)
  local n = select("#", ...)
  if n > 0 then
    local args = { ... }
    for i = 1, n do
      args[i] = stringify(args[i])
    end
    local ok, formatted = pcall(string.format, text, table.unpack(args, 1, n))
    text = ok and formatted or text
  end
  -- WezTerm has no debug log; debug goes to info.
  local sink =
    wezterm[level >= levels.ERROR and "log_error" or level >= levels.WARN and "log_warn" or "log_info"]
  if type(sink) == "function" then
    sink(("[%s] %s"):format(self.tag, text))
  end
  return nil
end

for name, level in pairs(levels) do
  M[name:lower()] = function(self, message, ...)
    return self:write(level, message, ...)
  end
end

return M
