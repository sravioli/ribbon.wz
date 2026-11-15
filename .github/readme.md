# ribbon.wz

[![Awesome](https://awesome.re/mentioned-badge.svg)](https://github.com/michaelbrusegard/awesome-wezterm)
[![Tests](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/tests.yaml?style=flat-square&label=tests)](https://github.com/sravioli/ribbon.wz/actions/workflows/tests.yaml)
[![Lint](https://img.shields.io/github/actions/workflow/status/sravioli/ribbon.wz/lint.yaml?style=flat-square&label=lint)](https://github.com/sravioli/ribbon.wz/actions/workflows/lint.yaml)
[![Coverage](https://img.shields.io/coverallsCoverage/github/sravioli/ribbon.wz?label=Coverage&logo=coveralls)](https://coveralls.io/github/sravioli/ribbon.wz)
[![Code license](https://img.shields.io/badge/code-GPL--2.0-blue?style=flat-square)](../LICENSE)
[![Docs license](https://img.shields.io/badge/docs-CC_BY--NC_4.0-blue?style=flat-square)](../LICENSE-DOCS)

Build formatted text for [WezTerm](https://wezterm.org/) with chainable segments.

Compose status bars and tab titles from colored text, named attributes, and
raw `wezterm.format` items. You can still inspect and edit the underlying
format-item list.

[Quick start](#quick-start) · [Usage](#usage) · [Configuration](#configuration) · [API reference](#api-reference) · [Troubleshooting](#troubleshooting) · [Development](#development) · [License](#license)

## Quick start

### Requirements

Requires **WezTerm [`20230320-124340-559cb7b0`](https://wezterm.org/config/lua/wezterm.plugin/require.html)
or newer** and Git. No special font is required for plain text.

Automatically loads [warp.wz](https://github.com/sravioli/warp.wz) and
[warden.wz](https://github.com/sravioli/warden.wz), preferring local API modules
on `package.path`; dependency failure raises. Invalid options are logged and ignored.
### Install and run

Put this in `wezterm.lua`:

```lua
local wezterm = require "wezterm"
local ribbon = wezterm.plugin.require "https://github.com/sravioli/ribbon.wz"
local config = wezterm.config_builder()

wezterm.on("update-status", function(window)
  local status = ribbon.new "Status"
  status:append("Blue", "White", " ready ", "Bold")
  window:set_right_status(status:format())
end)

return config
```

Reload with the tab/status bar visible. Its right side shows a blue `ready`
segment. Reuse your existing config builder. If you already render the right
status, combine the callbacks so one does not overwrite the other.

## Usage

### Compose several segments

Inside a renderer:

```lua
local status = ribbon.new("Status", true)
status
  :append("Blue", "White", " workspace ", "b")
  :append("Black", "Silver", " shell ", "i")
local rendered = status:format()
```

The second constructor argument enables atomic mode for this instance:
appended segments end with `ResetAttributes`, so bold or italic does not
leak into the next segment. Pass `rendered` to a WezTerm status setter.

### Mix raw items with processed text

```lua
local title = ribbon.new "Title"
title:append_items {
  { Foreground = { Color = "#57A143" } },
  { Text = "nvim " },
  "ResetAttributes",
}
title:append("Black", "White", "init.lua")
```

Raw items bypass text processing, attribute validation, color conversion,
and atomic resets. You can also pass arrays returned by
[sigil.items](https://github.com/sravioli/sigil.wz).
Use `prepend_items` when an ordered styled block must appear before existing
content; see the [prepend limitation](#prepended-text-has-unexpected-styling).

## Configuration

### Example

Setup is optional. Call it after importing Ribbon and before building
segments. This example adds a named attribute and changes text handling:

```lua
ribbon.setup {
  atomic = true,
  attribute_aliases = { strong = { "Bold", "Single" } },
  text = { strip = true, max_length = 24 },
}
```

The example overrides the defaults. Use `ribbon.config.defaults()` to inspect
the built-in attribute and color maps.

### Options

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `log.enabled` | `boolean` | `true` | Enable Ribbon's internal logger. |
| `log.threshold` | `"DEBUG"\|"INFO"\|"WARN"\|"ERROR"\|integer` | `"WARN"` | Minimum log level; names are case-insensitive. |
| `log.sinks.default_enabled` | `boolean` | `true` | Legacy compatibility setting; the internal logger does not use it. |
| `defaults.foreground` | `string?` | `nil` | Fallback foreground for segments; absent values ultimately use `"none"`. |
| `defaults.background` | `string?` | `nil` | Fallback background for segments; absent values ultimately use `"none"`. |
| `defaults.attributes.None` | `string` | `"ResetAttributes"` | Reset marker, not an attribute table. |
| `defaults.attributes.NoUnderline` | `table` | `{ Underline = "None" }` | Clear underline. |
| `defaults.attributes.Single` | `table` | `{ Underline = "Single" }` | Single underline. |
| `defaults.attributes.Double` | `table` | `{ Underline = "Double" }` | Double underline. |
| `defaults.attributes.Curly` | `table` | `{ Underline = "Curly" }` | Curly underline. |
| `defaults.attributes.Dotted` | `table` | `{ Underline = "Dotted" }` | Dotted underline. |
| `defaults.attributes.Dashed` | `table` | `{ Underline = "Dashed" }` | Dashed underline. |
| `defaults.attributes.Normal` | `table` | `{ Intensity = "Normal" }` | Normal intensity. |
| `defaults.attributes.Bold` | `table` | `{ Intensity = "Bold" }` | Bold intensity. |
| `defaults.attributes.Half` | `table` | `{ Intensity = "Half" }` | Half intensity. |
| `defaults.attributes.Italic` | `table` | `{ Italic = true }` | Enable italic. |
| `defaults.attributes.NoItalic` | `table` | `{ Italic = false }` | Clear italic. |
| `defaults.colors.Black` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Maroon` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Green` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Olive` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Navy` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Purple` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Teal` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Silver` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Grey` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Red` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Lime` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Yellow` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Blue` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Fuchsia` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.Aqua` | `boolean` | `true` | Recognize as an ANSI color name. |
| `defaults.colors.White` | `boolean` | `true` | Recognize as an ANSI color name. |
| `validate` | `boolean` | `true` | Check options with [warden.wz](https://github.com/sravioli/warden.wz). Set `false` to skip checks and never load warden. |
| `attribute_aliases.b` | `string` | `"Bold"` | Short attribute alias. |
| `attribute_aliases.i` | `string` | `"Italic"` | Short attribute alias. |
| `attribute_aliases.u` | `string` | `"Single"` | Single underline. |
| `attribute_aliases.dim` | `string` | `"Half"` | Half intensity. |
| `attribute_aliases.reset` | `string` | `"None"` | Reset all attributes. |
| `attribute_aliases.highlight` | `string[]` | `{ "Bold", "Single" }` | Ordered attribute group. |
| `attribute_aliases.emph` | `string[]` | `{ "Bold", "Italic" }` | Ordered attribute group. |
| `attribute_aliases.subtle` | `string[]` | `{ "Half", "Italic" }` | Ordered attribute group. |
| `validate_attributes` | `boolean` | `true` | Warn for unknown attribute names. |
| `strict_mode` | `boolean` | `false` | Raise for unknown names when validation is enabled. |
| `text.strip` | `boolean` | `false` | Trim surrounding Lua whitespace first. |
| `text.transform` | `fun(text: string): string` | `nil` | Optional callback transforming the trimmed string; must return a string. |
| `text.max_length` | `integer?` | `nil` | Byte limit before appending `"..."`; not a display-column or Unicode-character limit. |
| `atomic` | `boolean` | `false` | Reset attributes after each appended text segment; a constructor argument overrides it. |

The attribute map is a registry, not a set applied to every segment.
Truthy entries in the color-name map emit `AnsiColor`; other strings emit
literal `Color`. Extend these maps through setup as needed.

#### Option validation

Options are checked against a schema when you call setup. Invalid fields are logged and ignored, and the rest still apply; unknown keys in fixed sections log a warning.
Set `validate = false` once your configuration is stable: warden is then never
downloaded or loaded, and the options are used exactly as written, so typos and
wrong types go unnoticed.

```lua
ribbon.setup { validate = false }
```

### Behavior and precedence

Each setup call merges your options with fresh defaults using Warp's `"force"`
merge. Nested maps merge and lists replace. Omitted options reset to their
defaults; previous setup values do not carry over. Ribbon does not reject
unknown keys. Settings live in Lua state and do not survive config reloads.

Segment creation reads current color, attribute, and text settings. Existing
items do not change when setup changes. An instance captures its atomic
setting and logger settings when constructed.

Ribbon runs `tostring` on text (so `nil` becomes `"nil"`), then applies trimming,
transformation, and truncation in that order. The ellipsis adds three bytes beyond
`max_length`. Transforms run synchronously and their errors propagate.
Avoid cyclic attribute aliases.

Disabling validation suppresses the initial unknown-name warning, not the
later undefined-attribute error log. WezTerm checks colors and raw format
items when formatting.

## API reference

`?` marks optional arguments or nullable results. `Ribbon` is an instance;
the imported module is `Ribbon.Api`. Methods returning the instance can chain.

| Signature → Return type | Description |
| --- | --- |
| `ribbon.setup(options?) → Ribbon.Config` | Reset configuration to defaults plus overrides. |
| `ribbon.config.setup(options?) → Ribbon.Config` | Same configuration operation. |
| `ribbon.config.get() → Ribbon.Config` | Return the live configuration reference. |
| `ribbon.config.defaults() → Ribbon.Config` | Return a deep copy of defaults. |
| `ribbon.new(name?, atomic?) → Ribbon` | Construct an empty ribbon; alias `ribbon:new(name?, atomic?)`. Name is for diagnostics. |
| `r:add(action, background?, foreground?, text?, attributes?) → Ribbon?` | Lower-level segment insertion; use `"append"` or `"prepend"`. Empty action logs and returns `nil`. |
| `r:append(background?, foreground?, text?, attributes?) → Ribbon?` | Append processed text; attributes are one name/alias or an ordered string list. |
| `r:prepend(background?, foreground?, text?, attributes?) → Ribbon?` | Prepend processed text; generated format-item order differs from append. |
| `r:append_items(items) → Ribbon` | Append one raw item or an item list, without processing; `nil` does nothing. |
| `r:prepend_items(items) → Ribbon` | Prepend raw items in the supplied order. |
| `r:clear() → Ribbon` | Replace the internal list with an empty list. |
| `r:reset_attributes() → nil` | Append a reset marker; this method does not chain. |
| `r:format() → string` | Call `wezterm.format` with the current list. |
| `r:debug(formatted) → nil` | Log rendered text when true, otherwise the raw list; requires an `INFO` threshold or lower. |
| `r:items() → table` | Return the live item list, not a copy; mutations affect later renders. |

`background` comes before `foreground`. Known ANSI names use the current
terminal palette; hex strings use literal colors. Attributes use names in
the registry or aliases, not raw WezTerm attribute tables. Use `append_items`
for raw tables.

## Troubleshooting

### A segment changes the next segment

Use atomic mode or add an explicit reset. Raw item insertion never adds a
reset, even when the instance is atomic.

### Prepended text has unexpected styling

`prepend` inserts each generated item at index 1. The resulting text precedes
its generated style items, and an atomic reset also moves to the front.
For a styled prefix, use `prepend_items` with an ordered format-item array.
Do not assume prepending uses the same item order as appending.

### A Unicode label is cut in the middle

`text.max_length` counts bytes and can split a UTF-8 sequence. Pre-truncate
Unicode text using a suitable helper, or leave this option unset.

Update with `wezterm.plugin.update_all()` from the debug overlay and reload.
For [issues](https://github.com/sravioli/ribbon.wz/issues), include the raw
`r:items()` output, plugin revision, and WezTerm version.

## Development

### Local checkout

Load the working tree directly, so edits take effect on the next config
reload without a commit or a plugin update. Adjust the path to your clone:

```lua
local wezterm = require "wezterm"
local root = wezterm.home_dir .. "/path/to/ribbon.wz/plugin/"
package.path = root .. "?.lua;" .. root .. "?/init.lua;" .. package.path
local ribbon = require "ribbon.api"
```

Warp and Warden must also be available through the normal loader or `package.path`.

### Editor support

Follow the [wezterm-types setup](https://github.com/DrKJeff16/wezterm-types)
and use its [Ribbon definitions](https://github.com/DrKJeff16/wezterm-types/blob/main/lua/wezterm/types/plugins/ribbon.lua):

```lua
---@type Ribbon.Api
local ribbon = wezterm.plugin.require "https://github.com/sravioli/ribbon.wz"
```

Use the [local annotations](../plugin/ribbon/core.lua) for revision-specific
contracts and the [configuration source](../plugin/ribbon/config.lua) for maps.

### Checks and contributions

From the repository root, with Lua 5.4 and the named tools installed:

```sh
busted --verbose
luacheck plugin spec
selene --display-style=quiet plugin
stylua --check plugin spec
```

Specs mock WezTerm and Warp and load a sibling `../warden.wz` checkout. See the
[contribution guide](contributing.md) and use Conventional Commits.

## License

The [code license file](../LICENSE) contains GNU GPL v2; documentation uses
[CC BY-NC 4.0](../LICENSE-DOCS). Earlier README prose said GPL v3, which
conflicted with the license file. This documentation update does not change
the license terms or existing attribution.
