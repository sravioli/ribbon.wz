---@module "ribbon.core"

local config = require "ribbon.config"
local logger = require "ribbon.logger"
local wezterm = require "wezterm" --[[@as Wezterm]]

local tinsert = table.insert

---@class Ribbon
---@field log Ribbon.Logger Logger instance.
---@field public atomic? boolean Whether to reset text attributes after each operation.
---@field private layout table Internal format items.
---@field private name string Ribbon identifier.
local M = {}
M.__index = M

---@param attribute string
---@param log Ribbon.Logger
---@return string|string[]
local function resolve_attribute(attribute, log)
  local cfg = config.get()
  if cfg.attribute_aliases and cfg.attribute_aliases[attribute] then
    local resolved = cfg.attribute_aliases[attribute]

    if type(resolved) == "table" then
      return resolved
    end

    attribute = resolved
  end

  if cfg.defaults.attributes[attribute] then
    return attribute
  end

  if cfg.validate_attributes then
    local msg = string.format("Unknown attribute '%s'", attribute)
    if cfg.strict_mode then
      error(msg)
    else
      log:warn(msg)
    end
  end

  return attribute
end

---@param text string|nil
---@return string
local function process_text(text)
  local cfg = config.get()
  text = text == nil and tostring(text) or tostring(text)

  if cfg.text.strip then
    text = text:match "^%s*(.-)%s*$"
  end

  if cfg.text.transform then
    text = cfg.text.transform(text)
  end

  if cfg.text.max_length and #text > cfg.text.max_length then
    text = text:sub(1, cfg.text.max_length) .. "..."
  end

  return text
end

---@param layout table
---@param bg? string
---@param fg? string
---@param idx fun(): integer
local function insert_colors(layout, bg, fg, idx)
  local cfg = config.get()
  bg = bg or cfg.defaults.background or "none"
  fg = fg or cfg.defaults.foreground or "none"

  local bg_entry = cfg.defaults.colors[bg] and { Background = { AnsiColor = bg } }
    or { Background = { Color = bg } }
  tinsert(layout, idx(), bg_entry)

  local fg_entry = cfg.defaults.colors[fg] and { Foreground = { AnsiColor = fg } }
    or { Foreground = { Color = fg } }
  tinsert(layout, idx(), fg_entry)
end

---@param layout table
---@param attributes? string|string[]
---@param idx fun(): integer
---@param log Ribbon.Logger
local function insert_attributes(layout, attributes, idx, log)
  local cfg = config.get()
  if not attributes or (type(attributes) == "table" and #attributes == 0) then
    attributes = cfg.defaults.attributes
  end

  if not attributes or (type(attributes) == "table" and #attributes == 0) then
    return
  end

  local attr_list = (type(attributes) == "string") and { attributes } or attributes

  local function process_attr(val)
    local resolved = resolve_attribute(val, log)

    if type(resolved) == "table" then
      for _, nested_val in ipairs(resolved) do
        process_attr(nested_val)
      end
    elseif type(resolved) == "string" then
      if cfg.defaults.attributes[resolved] then
        local attr = cfg.defaults.attributes[resolved]
        tinsert(layout, idx(), attr == "ResetAttributes" and attr or { Attribute = attr })
      else
        log:error("attribute '%s' is not defined!", resolved)
      end
    end
  end

  for _, attr in ipairs(attr_list) do
    process_attr(attr)
  end
end

---Create a new Ribbon instance.
---@param name? string
---@param atomic? boolean
---@return Ribbon ribbon
function M.new(name, atomic)
  local cfg = config.get()
  name = "Ribbon" .. (name and " > " .. name or "")
  local is_atomic = atomic
  if is_atomic == nil then
    is_atomic = cfg.atomic
  end

  return setmetatable({
    layout = {},
    log = logger.new(name, cfg.log),
    name = name,
    atomic = is_atomic,
  }, M)
end

---Add an element into the ribbon.
---@param action "append"|"prepend"
---@param background? string
---@param foreground? string
---@param text? string
---@param attributes? string|string[]
---@return Ribbon|nil self
function M:add(action, background, foreground, text, attributes)
  if not action or action == "" then
    return self.log:error "Cannot operate with empty action"
  end

  local idx = function()
    return action == "prepend" and 1 or #self.layout + 1
  end

  insert_colors(self.layout, background, foreground, idx)
  insert_attributes(self.layout, attributes, idx, self.log)

  tinsert(self.layout, idx(), { Text = process_text(text) })

  if self.atomic then
    tinsert(self.layout, idx(), config.get().defaults.attributes.None)
  end

  return self
end

---Append an element to the ribbon.
---@param background? string
---@param foreground? string
---@param text? string
---@param attributes? string|string[]
---@return Ribbon|nil self
function M:append(background, foreground, text, attributes)
  return M.add(self, "append", background, foreground, text, attributes)
end

---Prepend an element to the ribbon.
---@param background? string
---@param foreground? string
---@param text? string
---@param attributes? string|string[]
---@return Ribbon|nil self
function M:prepend(background, foreground, text, attributes)
  return M.add(self, "prepend", background, foreground, text, attributes)
end

---Clear all elements from the ribbon.
---@return Ribbon self
function M:clear()
  self.layout = {}
  return self
end

---Append a reset-attributes marker.
---@return nil
function M:reset_attributes()
  tinsert(self.layout, "ResetAttributes")
end

---Render the ribbon with `wezterm.format`.
---@return string
function M:format()
  return wezterm.format(self.layout)
end

---Log the ribbon to the debug console.
---@param formatted boolean Whether to log the formatted string or raw table.
---@return nil
function M:debug(formatted)
  self.log:info(self.name .. " formatted: %s", formatted and self:format() or self.layout)
end

---Return the raw format-item table. Useful for tests and advanced callers.
---@return table
function M:items()
  return self.layout
end

return M
