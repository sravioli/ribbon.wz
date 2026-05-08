# ribbon.wz

[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/ribbon.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/ribbon.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/ribbon.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/ribbon.wz)

Formatted text ribbons for [WezTerm](https://wezfurlong.org/wezterm/).

Ribbon builds `wezterm.format()` item lists with a small chainable API. It is
intended for status bars, tab titles, command hints, separators, and other places
where a terminal UI needs short colored text segments.

- Append or prepend colored text segments
- Use WezTerm ANSI color names or arbitrary color strings
- Apply attributes by name, alias, or grouped alias
- Reset attributes after each segment with atomic mode
- Process text with stripping, transforms, and max-length truncation
- Configure validation and lightweight internal logging

## Installation

```lua
local wezterm = require "wezterm"

-- from git
local ribbon = wezterm.plugin.require "https://github.com/sravioli/ribbon.wz"

-- from a local checkout
local ribbon = wezterm.plugin.require("file:///" .. wezterm.config_dir .. "/plugins/ribbon.wz")
```

### Type annotations

The modules include LuaCATS annotations. After installing
[wezterm-types](https://github.com/DrKJeff16/wezterm-types), annotate the import
to get autocompletion and type checking:

```lua
---@type Ribbon.Api
local ribbon = wezterm.plugin.require "https://github.com/sravioli/ribbon.wz"
```

## Usage

```lua
ribbon.setup {
  atomic = true,
  attribute_aliases = {
    strong = { "Bold", "Single" },
  },
}

local title = ribbon:new "TabTitle"
title
  :append("Blue", "White", " 1 ", "Bold")
  :append("Black", "Silver", " shell ", "strong")

return title:format()
```

Both constructor styles are supported:

```lua
local a = ribbon:new "StatusBar"
local b = ribbon.new "StatusBar"
```

## Configuration

`setup()` deep-merges your options with Ribbon defaults.

```lua
ribbon.setup {
  log = {
    enabled = true,
    threshold = "WARN",
  },

  defaults = {
    foreground = nil,
    background = nil,
    attributes = {
      Bold = { Intensity = "Bold" },
      Italic = { Italic = true },
      None = "ResetAttributes",
    },
    colors = {
      Black = true,
      White = true,
      Blue = true,
    },
  },

  attribute_aliases = {
    b = "Bold",
    i = "Italic",
    highlight = { "Bold", "Single" },
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
```

## API

### `ribbon.setup(opts)`

Configures Ribbon and returns the active config table.

### `ribbon:new(name, atomic)` / `ribbon.new(name, atomic)`

Creates a Ribbon instance. `name` is used in log messages. `atomic` overrides the
global atomic setting for that instance.

### `Ribbon:append(background, foreground, text, attributes)`

Adds a segment to the end of the ribbon.

### `Ribbon:prepend(background, foreground, text, attributes)`

Adds a segment to the beginning of the ribbon.

### `Ribbon:format()`

Returns the rendered string from `wezterm.format()`.

## License

Code is licensed under the GNU GPLv3. Documentation is licensed separately under
the terms in `LICENSE-DOCS`.
