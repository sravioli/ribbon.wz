local ribbon = require "ribbon.api"
local wezterm = require "wezterm"

describe("ribbon.wz", function()
  before_each(function()
    wezterm._reset()
    ribbon.setup()
  end)

  it("constructs ribbons with colon and dot syntax", function()
    local colon = ribbon:new "Colon"
    local dot = ribbon.new "Dot"

    assert.are.equal("Ribbon > Colon", colon.name)
    assert.are.equal("Ribbon > Dot", dot.name)
  end)

  it("appends format items in wezterm format order", function()
    local r = ribbon.new "Append"

    r:append("Black", "#ffffff", " hello ", "Bold")

    assert.are.same({
      { Background = { AnsiColor = "Black" } },
      { Foreground = { Color = "#ffffff" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " hello " },
    }, r:items())
  end)

  it("prepends format items before existing content", function()
    local r = ribbon.new "Prepend"

    r:append("Blue", "White", "tail")
    r:prepend("Red", "Black", "head", "Italic")

    assert.are.same({
      { Text = "head" },
      { Attribute = { Italic = true } },
      { Foreground = { AnsiColor = "Black" } },
      { Background = { AnsiColor = "Red" } },
      { Background = { AnsiColor = "Blue" } },
      { Foreground = { AnsiColor = "White" } },
      { Text = "tail" },
    }, r:items())
  end)

  it("resolves single and grouped attribute aliases", function()
    local r = ribbon.new "Aliases"

    r:append(nil, nil, "x", { "b", "highlight", "reset" })

    assert.are.same({
      { Background = { Color = "none" } },
      { Foreground = { Color = "none" } },
      { Attribute = { Intensity = "Bold" } },
      { Attribute = { Intensity = "Bold" } },
      { Attribute = { Underline = "Single" } },
      "ResetAttributes",
      { Text = "x" },
    }, r:items())
  end)

  it("adds reset attributes after each segment in atomic mode", function()
    local r = ribbon.new("Atomic", true)

    r:append("Green", "White", "x")

    assert.are.same({
      { Background = { AnsiColor = "Green" } },
      { Foreground = { AnsiColor = "White" } },
      { Text = "x" },
      "ResetAttributes",
    }, r:items())
  end)

  it("processes text with strip, transform, and max length", function()
    ribbon.setup {
      text = {
        strip = true,
        max_length = 4,
        transform = function(text)
          return text:upper()
        end,
      },
    }

    local r = ribbon.new "Text"
    r:append(nil, nil, "  abcdef  ")

    assert.are.same({
      { Background = { Color = "none" } },
      { Foreground = { Color = "none" } },
      { Text = "ABCD..." },
    }, r:items())
  end)

  it("warns for unknown attributes by default", function()
    ribbon.setup {
      log = { enabled = true, threshold = "WARN" },
    }

    local r = ribbon.new "Validation"
    r:append(nil, nil, "x", "Missing")

    assert.are.equal("log_warn", wezterm._calls[1].fn)
    assert.matches("Unknown attribute 'Missing'", wezterm._calls[1].args[1], 1, true)
    assert.are.equal("log_error", wezterm._calls[2].fn)
    assert.matches("attribute 'Missing' is not defined!", wezterm._calls[2].args[1], 1, true)
  end)

  it("errors for unknown attributes in strict mode", function()
    ribbon.setup {
      validate_attributes = true,
      strict_mode = true,
    }

    local r = ribbon.new "Strict"

    assert.has_error(function()
      r:append(nil, nil, "x", "Missing")
    end, "Unknown attribute 'Missing'")
  end)

  it("delegates format rendering to wezterm.format", function()
    local r = ribbon.new "Format"
    r:append("Blue", "White", "x")

    assert.are.equal("<formatted>", r:format())
    assert.are.equal("format", wezterm._calls[1].fn)
    assert.are.same(r:items(), wezterm._calls[1].args[1])
  end)

  it("loads without log.wz", function()
    package.loaded["log"] = nil
    package.loaded["plugs.log"] = nil

    local ok, mod = pcall(require, "ribbon.api")

    assert.is_true(ok)
    assert.is_table(mod)
  end)
end)
