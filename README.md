# hs.tiling

Add tiling window management powers to your [hammerspoon][hammerspoon]. (Fork of nathankot's [mjolnir.tiling](https://github.com/nathankot/mjolnir.tiling).)

## Features

* Different layouts per space ([with this magic][magic])
* Multi-monitor supported
* Custom layouts

## Quick start

First up, install [Hammerspoon][hammerspoon] if you haven't already.

Then install `hs.tiling` by cloning into your hammerspoon configuration directory:

```
mkdir -p $HOME/.hammerspoon/hs
git clone https://github.com/dsanson/hs.tiling $HOME/.hammerspoon/hs/tiling
```

In your `~/.hammerspoon/init.lua`:

```lua
local tiling = require "hs.tiling"
local hotkey = require "hs.hotkey"
local mash = {"ctrl", "cmd"}

hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
hotkey.bind(mash, "j", function() tiling.cycle(1) end)
hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
hotkey.bind(mash, "space", function() tiling.promote() end)
hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)

-- If you want to set the layouts that are enabled
tiling.set('layouts', {
  'fullscreen', 'main-vertical'
})
```

## Updating

To update to the latest `hs.tiling`, pull the latest from git:

```
cd $HOME/.hammerspoon/hs/tiling
git pull
```

## Using custom layouts

You can define your own layouts like so (please see [layouts.lua](/layouts.lua) for definition examples:)

```lua
tiling.addLayout('custom', function(windows)
  fnutils.each(windows, function(window)
    window:maximize()
  end)
end)
```

## Floating Windows

Using `tiling.toggleFloat` you can toggle whether or not a window that is on your desktop will be
included in your tiling calculations. You can optionally pass in a function as a callback to process
the window if it was tiled.

```lua
-- Push the window into the exact center of the screen
local function center(window)
  frame = window:screen():frame()
  frame.x = (frame.w / 2) - (frame.w / 4)
  frame.y = (frame.h / 2) - (frame.h / 4)
  frame.w = frame.w / 2
  frame.h = frame.h / 2
  window:setFrame(frame)
end

hotkey.bind(mash, "f", function() tiling.toggleFloat(center) end)
```

## Layouts

These are the layouts that come with `hs.tiling`:

Name						                            | Screenshot
------------------------------------------- | ------------------------------------
`fullscreen`		                            | ![fullscreen](https://raw.github.com/dsanson/hs.tiling/master/screenshots/fullscreen.png)
`main-vertical`                             | ![main-vertical](https://raw.github.com/dsanson/hs.tiling/master/screenshots/main-vertical.png)
`main-horizontal`                           | ![main-horizontal](https://raw.github.com/dsanson/hs.tiling/master/screenshots/main-horizontal.png)
`rows`                                      | ![rows](https://raw.github.com/dsanson/hs.tiling/master/screenshots/rows.png)
`columns`                                   | ![columns](https://raw.github.com/dsanson/hs.tiling/master/screenshots/columns.png)
`gp-vertical`                               | ![gp-vertical](https://raw.github.com/dsanson/hs.tiling/master/screenshots/gp-vertical.png)
`gp-horizontal`                             | ![gp-horizontal](https://raw.github.com/dsanson/hs.tiling/master/screenshots/gp-horizontal.png)

## Variable Layouts

I am experimenting with adding support for variable width layouts.

For now, I have added a variable width variant of `main-vertical`, called
`main-vertical-variable`. It it just like `main-vertical`, except the
proportion of the screen filled by the main window is determined by the value
of the global variable, `mainVertical`, which defaults to `0.5`. I've also
added two functions, `tiling.setMainVertical(val)`, which takes a value
between `0` and `1` (`0.25` means that the main window takes a quarter of the
screen, while the other windows take the remaining three quarters; `0.75`
means that the main window takes 3/4 of the screen, while the remaining
windows take 1/4, and so on) and `tiling.adjustMainVertical(factor)`, which
takes a negative or positive factor by which to adjust the value of
`mainVertical` (e.g., if `mainVertical` is `0.5`, then
`tiling.adjustMainVertical(-0.1)` sets it to `0.4`).

Here is how I use them in my `init.lua` (as
part of a "windows" mode using `hotkeys.modal`:

```
w:bind({},"left",  function() tiling.adjustMainVertical(-0.05) end)
w:bind({},"right",  function() tiling.adjustMainVertical(0.05) end)
w:bind({},"=", function() tiling.setMainVertical(0.5) end)
```

Once I have all the kinks worked out, I plan to enable this feature for
`main-vertical` and `gp-vertical`, as well as a corresponding feature for
`main-horizontal` and `gp-horizontal`.

## Contributing

Yes! Please :)

```sh
git clone https://github.com/dsanson/hs.tiling.git
cd hs.tiling
```

## Contributors

This is a port of [nathankot's](https://github.com/nathankot) [mjolnir.tiling][mjolnir.tiling].

I replaced
references to mjolnir extensions (e.g., `mjolnir.window`) with references to
the corresponding hammerspoon extensions (e.g., `hs.window`). I rewrote
function calls in camelCase where necessary. I renamed `tiling.lua` to
`init.lua`. It seems to work.

Nathan lists, as contributors to mjolnir.tiling,

* [csaunders](https://github.com/csaunders)
* [acmcelwee](https://github.com/acmcelwee)
* [iveney](https://github.com/iveney)
* [mavant](https://github.com/mavant)
* [OrBaruk](https://github.com/OrBaruk)
* [peterjcaulfield](https://github.com/peterjcaulfield)

Thanks to Nathan and all these contributors for making mjolnir.tiling, and making it so easy to port over to hammerspoon!

## To-do

* [x] Better documentation
* [x] More layouts
* [x] Allow globally enabling/disabling layouts
* [ ] Functions to move windows across spaces
* [ ] Event-based tiling, although requires [sdegutis/mjolnir#72][72]

[72]: https://github.com/sdegutis/mjolnir/issues/72
[magic]: https://github.com/dsanson/hs.tiling/blob/master/init.lua#L95-L124
[hammerspoon]: https://github.com/Hammerspoon/hammerspoon
[mjolnir.tiling]: https://github.com/nathankot/mjolnir.tiling

## License

> The MIT License (MIT)
>
> Copyright (c) 2015 Nathan Kot
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
