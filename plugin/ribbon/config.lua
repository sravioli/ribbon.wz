---@module "ribbon.config"

---@class Ribbon.Config
---@field log Ribbon.LogConfig
---@field defaults Ribbon.Defaults
---@field attribute_aliases table<string, string|string[]>
---@field validate_attributes boolean
---@field strict_mode boolean
---@field text Ribbon.TextConfig
---@field atomic boolean

---@class Ribbon.LogConfig
---@field enabled boolean
---@field threshold "DEBUG"|"INFO"|"WARN"|"ERROR"|integer
---@field sinks? table Accepted for compatibility with the old layout opts.

---@class Ribbon.Defaults
---@field foreground? string
---@field background? string
---@field attributes table<string, table|string>
---@field colors table<string, boolean>

---@class Ribbon.TextConfig
---@field strip boolean
---@field max_length? integer
---@field transform? fun(text: string): string

local M = {}

---@type Ribbon.Config
local defaults = {
  log = {
    enabled = true,
    threshold = "WARN",
    sinks = { default_enabled = true },
  },

  defaults = {
    foreground = nil,
    background = nil,

    attributes = {
      None = "ResetAttributes",
      NoUnderline = { Underline = "None" },
      Single = { Underline = "Single" },
      Double = { Underline = "Double" },
      Curly = { Underline = "Curly" },
      Dotted = { Underline = "Dotted" },
      Dashed = { Underline = "Dashed" },
      Normal = { Intensity = "Normal" },
      Bold = { Intensity = "Bold" },
      Half = { Intensity = "Half" },
      Italic = { Italic = true },
      NoItalic = { Italic = false },
    },

    -- stylua: ignore
    colors = {
      Black = true, Maroon  = true, Green = true, Olive = true, Navy = true, Purple = true,
      Teal  = true, Silver  = true, Grey  = true, Red   = true, Lime = true, Yellow = true,
      Blue  = true, Fuchsia = true, Aqua  = true, White = true,
    },
  },

  attribute_aliases = {
    b = "Bold",
    i = "Italic",
    u = "Single",
    dim = "Half",
    reset = "None",
    highlight = { "Bold", "Single" },
    emph = { "Bold", "Italic" },
    subtle = { "Half", "Italic" },
  },

  validate_attributes = false,
  strict_mode = false,

  text = {
    strip = false,
    max_length = nil,
    transform = nil,
  },

  atomic = false,
}

local current

---@param value any
---@return boolean
local function is_array(value)
  return type(value) == "table" and (#value > 0 or next(value) == nil)
end

---@param value any
---@return any
local function deepcopy(value)
  if type(value) ~= "table" then
    return value
  end

  local copy = {}
  for key, child in pairs(value) do
    copy[key] = deepcopy(child)
  end
  return copy
end

---@param dst table
---@param src table|nil
---@return table
local function merge(dst, src)
  if type(src) ~= "table" then
    return dst
  end

  for key, value in pairs(src) do
    if type(value) == "table" and type(dst[key]) == "table" and not is_array(value) then
      merge(dst[key], value)
    else
      dst[key] = deepcopy(value)
    end
  end

  return dst
end

---Configure Ribbon.
---@param opts? table
---@return Ribbon.Config
function M.setup(opts)
  current = merge(deepcopy(defaults), opts)
  return current
end

---Return the active Ribbon configuration.
---@return Ribbon.Config
function M.get()
  if not current then
    current = deepcopy(defaults)
  end
  return current
end

---Return a copy of the default configuration.
---@return Ribbon.Config
function M.defaults()
  return deepcopy(defaults)
end

return M
