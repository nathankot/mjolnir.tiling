# mjolnir.tiling

Add tiling window management powers to your [mjolnir][mjolnir].

## Features

* Different layouts per space ([with this magic][magic])
* Multi-monitor supported
* Custom layouts

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
hotkey.bind(mash, "f", function() tiling.gotolayout("fullscreen") end)

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
* [peterjcaulfield](https://github.com/peterjcaulfield)

Thanks <3

## To-do

* [x] Better documentation
* [x] More layouts
* [x] Allow globally enabling/disabling layouts
* [ ] Functions to move windows across spaces
* [ ] Event-based tiling, although requires [sdegutis/mjolnir#72][72]

[mjolnir]: https://github.com/sdegutis/mjolnir
[72]: https://github.com/sdegutis/mjolnir/issues/72
[magic]: https://github.com/nathankot/mjolnir.tiling/blob/953c22a43ba56362a635d83a4455f4bc92e6546a/tiling.lua#L95-L124

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
