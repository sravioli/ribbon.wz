---Minimal wezterm mock for testing outside WezTerm.

if package.loaded["wezterm"] then
  return package.loaded["wezterm"]
end

-- warden is a real sibling checkout, so specs exercise actual validation.
-- selene: allow(incorrect_standard_library_use)
local base = "../warden.wz/plugin/"
package.path = base .. "?.lua;" .. base .. "?/init.lua;" .. package.path

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

function M.column_width(text)
  return utf8.len(text) or #text
end

function M.to_string(value)
  return tostring(value)
end

M.plugin = {
  list = function()
    return {}
  end,
  require = function(url)
    if tostring(url):find("warp.wz", 1, true) then
      local function is_list(value)
        if type(value) ~= "table" then
          return false
        end
        local n = #value
        local count = 0
        for _ in pairs(value) do
          count = count + 1
        end
        return count == n
      end

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

      local function merge(_, dst, ...)
        for i = 1, select("#", ...) do
          local src = select(i, ...)
          if type(src) == "table" then
            for key, value in pairs(src) do
              if
                type(value) == "table"
                and type(dst[key]) == "table"
                and not is_list(value)
                and not is_list(dst[key])
              then
                merge("force", dst[key], value)
              else
                dst[key] = value
              end
            end
          end
        end
        return dst
      end

      -- One column per codepoint: enough to test cuts by character.
      local function truncate_right(text, budget)
        if utf8.len(text) <= budget then
          return text
        end
        if budget <= 1 then
          return "…"
        end
        return text:sub(1, utf8.offset(text, budget) - 1) .. "…"
      end

      return {
        string = { truncate_right = truncate_right },
        table = {
          deepcopy = deepcopy,
          merge = merge,
        },
      }
    end
    error("unknown plugin: " .. tostring(url))
  end,
}

M.GLOBAL = {}

function M._reset()
  M._calls = {}
  M.GLOBAL = {}
end

package.loaded["wezterm"] = M

return M
