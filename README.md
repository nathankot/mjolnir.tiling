# mjolnir.tiling

Add tiling window management powers to your [mjolnir][mjolnir].

## Features

* Spaces and display support
* Different layouts per space

## Quick start

First up, install [Mjolnir](https://github.com/sdegutis/mjolnir) if you haven't already.

Then install `mjolnir.tiling` using luarocks: `luarocks install mjolnir.tiling`

In your `~/.mjolnir/init.lua`:

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

## Updating

To update to the latest `mjolnir.tiling`, just run: `luarocks install mjolnir.tiling`

## Using custom layouts

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

## Layouts

These are the layouts that come with `mjolnir.tiling`:

Name						                            | Screenshot
------------------------------------------- | ------------------------------------
`fullscreen`		                            | ![fullscreen](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/fullscreen.png)
`main-vertical`                             | ![main-vertical](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/main-vertical.png)
`main-horizontal`                           | ![main-horizontal](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/main-horizontal.png)
`rows`                                      | ![rows](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/rows.png)
`columns`                                   | ![columns](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/columns.png)
`gp-vertical`                               | ![gp-vertical](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/gp-vertical.png)
`gp-horizontal`                             | ![gp-horizontal](https://raw.github.com/nathankot/mjolnir.tiling/master/screenshots/gp-horizontal.png)


## Contributing

Yes! Please :)

```sh
git clone https://github.com/nathankot/mjolnir.tiling.git
cd mjolnir.tiling
luarocks make <latest .rockspec name>
```

## Contributors

* [csaunders](https://github.com/csaunders)
* [acmcelwee](https://github.com/acmcelwee)
* [iveney](https://github.com/iveney)
* [mavant](https://github.com/mavant)
* [OrBaruk](https://github.com/OrBaruk)

Thanks <3

## To-do

* [x] Better documentation
* [x] More layouts
* [x] Allow globally enabling/disabling layouts
* [ ] Event-based tiling, although requires [sdegutis/mjolnir#72][72]

[mjolnir]: https://github.com/sdegutis/mjolnir
[72]: https://github.com/sdegutis/mjolnir/issues/72
