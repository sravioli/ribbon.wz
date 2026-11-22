---@module "ribbon.api"

---ribbon.wz now lives in warp.wz as `warp.ribbon`. This keeps the old URL working,
---and returns the same instance, so `ribbon.setup` still reaches every plugin.

local wezterm = require "wezterm"

local ok, warp = pcall(require, "warp.api")
if not ok then
  warp = wezterm.plugin.require "https://github.com/sravioli/warp.wz"
end

---Same table as `warp.ribbon`; see the warp.wz API reference.
---@class RibbonWz
local M = warp.ribbon

return M
