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

## To-do

* Better documentation
* More layouts
* ~~Allow globally enabling/disabling layouts~~
* Event-based tiling, although requires [sdegutis/mjolnir#72][72]

[mjolnir]: https://github.com/sdegutis/mjolnir
[72]: https://github.com/sdegutis/mjolnir/issues/72
