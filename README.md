# mjolnir.tiling

Add tiling window management powers to your [mjolnir][mjolnir].

## Features

* Spaces and display support
* Different layouts per space

## Quick start

```lua
local tiling = require "mjolnir.tiling"
local mash = {"ctrl", "cmd"}

hotkey.bind(mash, "c", function() tiling.cyclelayout() end)
hotkey.bind(mash, "j", function() tiling.cycle(1) end)
hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
hotkey.bind(mash, "space", function() tiling.promote() end)

-- If you want to set the layouts that are enabled
tiling.set('layouts', {
  'fullscreen', 'main-vertical'
})
```

## Layouts

Currently there are only 3 different layouts, but it's easy to add new ones (PR's welcome!)

* fullscreen
* main-vertical
* main-horizontal

### Using custom layouts

You can define your own layouts like so (please see [layouts.lua](/layouts.lua) for definition examples:)

```lua
tiling.addlayout('custom', function(windows)
  fnutils.each(windows, function(window)
    window:maximize()
  end)
end)
```

## Floating Windows

Using `tiling.togglefloat` you can toggle whether or not a window that is on your desktop will be
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
  window:setframe(frame)
end

hotkey.bind(mash, "f", function() tiling.togglefloat(center) end)
```

## Contributing

Yes! Please :)

```sh
git clone https://github.com/nathankot/mjolnir.tiling.git
cd mjolnir.tiling
luarocks make <latest .rockspec name>
```

## To-do

* Better documentation
* More layouts
* ~~Allow globally enabling/disabling layouts~~
* Event-based tiling, although requires [sdegutis/mjolnir#72][72]

[mjolnir]: https://github.com/sdegutis/mjolnir
[72]: https://github.com/sdegutis/mjolnir/issues/72
