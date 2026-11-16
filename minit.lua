---Minimal config for bug reports. Run it in isolation from your own config:
---
---    wezterm --config-file minit.lua
---
---Put your reproduction below the marker. Keep it as small as possible and
---paste the edited file into the bug report.
local wezterm = require "wezterm"
local ribbon = wezterm.plugin.require "https://github.com/sravioli/ribbon.wz"
local config = wezterm.config_builder()

-- Edit below this line --------------------------------------------------------

wezterm.on("update-status", function(window)
  local status = ribbon.new "Status"
  status:append("Blue", "White", " ready ", "Bold")
  window:set_right_status(status:format())
end)

return config
