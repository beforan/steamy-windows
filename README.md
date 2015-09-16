# Steamy Windows
A keyboard / joypad driven Message Window / Windowed UI library for LÖVE. Suitable for JRPGs.

## What is it good for?
Right now not much. you could use it for some Text-in-a-box UI,
without having to handle sizing / wrapping / centering etc. yourself

It does have some basic customisability:
- Fonts
- Text Colour
- Background styles
  - Transparent
  - Solid Fill
  - Four Corner gradients (Per-Vertex colours, interpolated across the window)

Note that currently there is no input handling (no dismissing a focused window, for example) so you need to do that yourself.

As it grows, it should be usable for:
- Simple UI windows
- JRPG-style Speech windows (with buttons to proceed / dismiss)
- Windows containing buttons, navigable by keys or joypad
- Entire JRPG style Menus, with windows and buttons navigable by keys or joypad
- Complex layout containers for multiple types of content within windows
- Configurable defaults
- Configurable Styles

It is never planned to be mouse controllable.

## How do I use it?
You need to use it in a project targeting LÖVE  `0.9.0+`

```lua
-- require the Window "class"
local Window = require "path/to/window.lua"

-- create some windows
local windows = {}
function love.load()
	table.insert(windows, Window { content = "hello!" })
	table.insert(windows, Window {
		top = 200,
		left = 300,
		content = "goodbye!"
	})
end

-- draw the windows
function love.draw()
	for _, window in ipairs(windows) do
		window:draw()
	end
end
```

Windows have a number of default properties that can be overridden by specifying them in the table passed to `Window()`:

Property | Description
:-------:|:------------
`top` | Sets the window's **top edge** position on the y-axis of the screen
`left` | Sets the window's **left edge** position on the x-axis of the screen
`x` | Alternative to `left` (`left` overrides `x` if specified). Sets the window's **centre** position on the x-axis of the screen
`y` | Alternative to `top` (`top` overrides `y` if specified). Sets the window's **centre** position on the y-axis of the screen
`width` | the width of the window (default `150`)
`height` | the height of the window (default `50`)
`autosize` | Ask the window to set its `width` and `height` based on fitting its `content` (overrides `width`/`height` values if specified)
`maxwidth` | The maximum `width` of an `autosize` window: text wrapping is forced if the `content` requires a window wider than this
`content` | a `string` or `number` to display inside the window
`align` | Default `"left"`, `"center"` or `"right"` alignment for the window `content`
`padding` | The padding around the `content`, inside the window (i.e. distance from window edge to content container edge) (default `10`). This can also be specified granularly as a table with `top`, `left`, `bottom`, `right` properties (if not specified, `right` inherits from `left`; `bottom` inherits from `top`; `top` and `left` default to 0)
`font` | The default LÖVE `Font` object used to render the `content` in this window
`color` | The default color (as an RGBA table) set before rendering the `content` in this window
`background` | The background of the window (color as an RGBA table, or a `Background` object, or `false` for transparent
`shadow` | The default color (as an RGBA table) to use for shadow on the window itself, or `false` for none
`shadowoffset` | The default offset for the window shadow
`contentshadow` | The default color (as an RGBA table) to use for shadow on the `content`, or `false` for none
`border` | The border of the window (a `Border` object, or `false` for none)
`bordershadow` | Boolean. Apply the window shadow to the border (i.e. inside the window; on top of the background)

Backgrounds have a number of properties that can be set by specifying them in the table passed to `Background()`:

Property | Description
:-------:|:------------
`style` | Sets the background style to one from the enum array `Background.Styles`: `Transparent` `Solid` `FourCorner` `SimpleHorizontal` `SimpleVertical`
`color` | Sets the colour or colours to be used in the given style. `Solid` uses the first colour, `FourCorner` uses the first 4 colours (or White if any are missing), `SimpleHorizontal` and `SimpleVertical` use the first 2 colours (or White if any are missing)

That's it for now.