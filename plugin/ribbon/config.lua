---@module "ribbon.config"

local tbl = require("ribbon.deps").warp.table

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

  validate_attributes = true,
  strict_mode = false,

  text = {
    strip = false,
    max_length = nil,
    transform = nil,
  },

  atomic = false,
}

local current

---Configure Ribbon.
---@param opts? table
---@return Ribbon.Config
function M.setup(opts)
  current = tbl.merge("force", tbl.deepcopy(defaults), tbl.deepcopy(opts or {}))
  return current
end

---Return the active Ribbon configuration.
---@return Ribbon.Config
function M.get()
  if not current then
    current = tbl.deepcopy(defaults)
  end
  return current
end

---Return a copy of the default configuration.
---@return Ribbon.Config
function M.defaults()
  return tbl.deepcopy(defaults)
end

return M
