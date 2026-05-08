# ribbon.wz

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/tests.yaml?label=Tests&logo=Lua)](https://github.com/sravioli/ribbon.wz/actions?workflow=tests)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/lint.yaml?label=Lint&logo=Lua)](https://github.com/sravioli/ribbon.wz/actions?workflow=lint)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/ribbon.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/ribbon.wz)

Formatted text ribbons for [WezTerm](https://wezfurlong.org/wezterm/).

Ribbon builds `wezterm.format()` item lists with a small chainable API. Use it
for status bars, tab titles, command hints, separators, and other places where a
terminal UI needs short colored text segments.

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

Ribbon ships LuaCATS annotations. After installing
[wezterm-types](https://github.com/DrKJeff16/wezterm-types), annotate the import
to get completion and type checking:

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

`setup()` deep-merges your options with Ribbon defaults. Tables are merged by
key, while array-like tables replace the previous value. You usually only set
the fields you care about.

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

### `log`

Ribbon has its own small logger and does not require `log.wz`.

```lua
log = {
  enabled = true,
  threshold = "WARN",
}
```

`enabled = false` silences Ribbon. `threshold` accepts `"DEBUG"`, `"INFO"`,
`"WARN"`, `"ERROR"`, or a numeric level. The old layout option `log.sinks` is
accepted for compatibility, but Ribbon does not use it.

### `defaults.foreground` and `defaults.background`

These are fallback colors for segments that do not pass a foreground or
background to `append()` / `prepend()`.

```lua
ribbon.setup {
  defaults = {
    foreground = "White",
    background = "#1f2335",
  },
}

local cell = ribbon:new "Cell"
cell:append(nil, nil, " text ")
```

In that example, the segment uses `White` as the foreground and `#1f2335` as the
background. If no fallback is configured, Ribbon uses `"none"`.

### `defaults.colors`

`defaults.colors` tells Ribbon which color names should be emitted as WezTerm
ANSI colors.

```lua
defaults = {
  colors = {
    Black = true,
    White = true,
    Blue = true,
  },
}
```

When a color is present in this table, Ribbon emits:

```lua
{ Foreground = { AnsiColor = "Blue" } }
```

Other strings are emitted as literal colors:

```lua
{ Foreground = { Color = "#7aa2f7" } }
```

That means terminal palette colors and literal color strings can live in the
same ribbon.

### `defaults.attributes`

`defaults.attributes` is the registry of attributes Ribbon knows how to emit. It
is not a list of attributes applied to every segment.

```lua
defaults = {
  attributes = {
    None = "ResetAttributes",
    Bold = { Intensity = "Bold" },
    Italic = { Italic = true },
    Single = { Underline = "Single" },
  },
}
```

Passing `"Bold"` to `append()` looks up `defaults.attributes.Bold` and emits the
matching WezTerm format item. Passing `"None"` emits `ResetAttributes`.

You can add project-specific names:

```lua
ribbon.setup {
  defaults = {
    attributes = {
      Alert = { Intensity = "Bold" },
    },
  },
}

local cell = ribbon:new "Cell"
cell:append("Red", "White", " warning ", "Alert")
```

Because `setup()` deep-merges tables, adding `Alert` keeps the built-in
attributes unless you replace the whole table with an array-like value.

### `attribute_aliases`

Aliases are shortcuts for one attribute or a small group of attributes.

```lua
attribute_aliases = {
  b = "Bold",
  i = "Italic",
  highlight = { "Bold", "Single" },
}
```

These calls are equivalent:

```lua
cell:append("Blue", "White", " title ", "b")
cell:append("Blue", "White", " title ", "Bold")
```

Grouped aliases are expanded in order:

```lua
cell:append("Blue", "White", " title ", "highlight")
```

That applies `Bold`, then `Single`.

### `validate_attributes` and `strict_mode`

By default, Ribbon is permissive. If an attribute cannot be emitted, Ribbon logs
the problem but keeps loading the config.

Turn on validation when you want a clearer warning before the emitter reaches
that point:

```lua
ribbon.setup {
  validate_attributes = true,
  strict_mode = false,
}
```

With `validate_attributes = true`, Ribbon warns when you pass a name that is not
in `defaults.attributes` or `attribute_aliases`. With `strict_mode = true`, that
warning becomes an error.

### `text`

Text processing runs in this order:

1. Strip leading and trailing whitespace when `strip = true`.
2. Run `transform(text)` when a transform function is configured.
3. Truncate to `max_length` and append `...` when the processed text is too long.

```lua
ribbon.setup {
  text = {
    strip = true,
    max_length = 10,
    transform = function(text)
      return text:upper()
    end,
  },
}
```

With that config, `"  shell  "` becomes `"SHELL"`. A longer string such as
`"  powershell  "` becomes `"POWERSHEL..."`.

### `atomic`

Atomic mode inserts `ResetAttributes` after each text segment.

```lua
ribbon.setup {
  atomic = true,
}
```

Use it when a segment should not leak bold, italic, underline, or other
attributes into the next segment. You can override it per instance:

```lua
local global_default = ribbon:new "GlobalDefault"
local always_atomic = ribbon:new("AlwaysAtomic", true)
local never_atomic = ribbon:new("NeverAtomic", false)
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

### `Ribbon:clear()`

Removes all format items from the instance and returns it, so the same Ribbon can
be reused.

### `Ribbon:reset_attributes()`

Appends a `ResetAttributes` marker manually.

### `Ribbon:format()`

Returns the rendered string from `wezterm.format()`.

### `Ribbon:debug(formatted)`

Logs either the raw format-item table or the rendered string.

### `Ribbon:items()`

Returns the raw format-item table. This is mainly useful in tests or advanced
renderers.

## License

Code is licensed under the [GNU General Public License v3](../LICENSE).
Documentation is licensed under the terms in [LICENSE-DOCS](../LICENSE-DOCS).
