# mjolnir.tiling

Add tiling window management powers to your [mjolnir][mjolnir].

## Features

* Spaces and display support
* Different layouts per space

## Quickstart

```lua
local tiling = require "mjolnir.tiling"
local mash = {"ctrl", "cmd"}

hotkey.bind(mash, "c", function() tiling.cyclelayout() end)
hotkey.bind(mash, "j", function() tiling.cycle(1) end)
hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
hotkey.bind(mash, "space", function() tiling.promote() end)
```

## Layouts

Currently there are only 2 different layouts, but it's easy to add new ones (PR's welcome!)

* Fullscreen
* Main-vertical

## Todo

* Better documentation
* More layouts
* Allow globally enabling/disabling layouts
* Event-based tiling, although requires mjolnir#72

[mjolnir]: https://github.com/sdegutis/mjolnir
