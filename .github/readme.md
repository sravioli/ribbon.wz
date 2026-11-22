# ribbon.wz [![Release](https://img.shields.io/github/v/release/sravioli/ribbon.wz?style=flat&label=Release&logo=github)](https://github.com/sravioli/ribbon.wz/releases/latest)

**ribbon.wz moved into [warp.wz](https://github.com/sravioli/warp.wz) as `warp.ribbon`.**

This URL keeps working: it loads warp.wz and returns `warp.ribbon`, the same table
every plugin uses. Switch to warp.wz when convenient:

```lua
local ribbon = wezterm.plugin.require("https://github.com/sravioli/warp.wz").ribbon
```

See the [warp.ribbon guide](https://github.com/sravioli/warp.wz/blob/main/docs/ribbon.md).
Report problems in [warp.wz issues](https://github.com/sravioli/warp.wz/issues).

## License

The [code license file](../LICENSE) contains GNU GPL v2. Documentation uses
[CC BY-NC 4.0](../LICENSE-DOCS). Earlier README prose said GPL v3, which
conflicted with the license file. This documentation update does not change
the license terms or existing attribution.
