local tiling = {}

local application = require "mjolnir.application"
local window = require "mjolnir.window"
local screen = require "mjolnir.screen"
local fnutils = require "mjolnir.fnutils"
local geometry = require "mjolnir.geometry"
local alert = require "mjolnir.alert"
local layouts = require "mjolnir.tiling.layouts"
local spaces = {}
local settings = {
  layouts = {}
}

local n = 0
for k, v in pairs(layouts) do
  n = n + 1
  settings.layouts[n] = k
end

function tiling.set(name, value)
  settings[name] = value
end

function tiling.cycle(direction)
  local space = getspace()
  local windows = space.windows
  local win = window:focusedwindow() or windows[1]
  local direction = direction or 1
  local currentindex = fnutils.indexof(windows, win)
  local layout = space.layout
  if not currentindex then return end
  local nextindex = currentindex + direction

  while nextindex > #windows do
    nextindex = nextindex - #windows
  end

  while nextindex < 1 do
    nextindex = #windows + nextindex
  end

  windows[nextindex]:focus()
  apply(windows, layout)
end

function tiling.cyclelayout()
  local space = getspace()
  space.layout = space.layoutcycle()
  alert.show(space.layout, 1)
  apply(space.windows, space.layout)
end

function tiling.promote()
  local space = getspace()
  local windows = space.windows
  local win = window:focusedwindow() or windows[1]
  local i = fnutils.indexof(windows, win)
  local current = table.remove(windows, i)
  table.insert(windows, 1, current)
  win:focus()
  apply(windows, space.layout)
end

function apply(windows, layout)
  layouts[layout](windows)
end

-- Infer a 'space' from our existing spaces
function getspace()
  local mainscreen = screen.mainscreen()
  local windows = fnutils.filter(window.visiblewindows(), function(win)
    return win:screen() == mainscreen and win:isstandard() and #win:title() > 0
  end)

  fnutils.each(spaces, function(space)
    local matches = 0
    fnutils.each(space.windows, function(win)
      if fnutils.contains(windows, win) then matches = matches + 1 end
    end)
    space.matches = matches
  end)

  table.sort(spaces, function(a, b)
    return a.matches > b.matches
  end)

  local space = {}

  if #spaces == 0 or spaces[1].matches == 0 then
    space.windows = windows
    space.layoutcycle = fnutils.cycle(settings.layouts)
    space.layout = settings.layouts[1]
    table.insert(spaces, space)
  else
    space = spaces[1]
  end

  space.windows = syncwindows(space.windows, windows)
  return space
end

function syncwindows(windows, newwindows)
  -- Remove any windows no longer around
  windows = fnutils.filter(windows, function(win)
    return fnutils.contains(newwindows, win)
  end)

  -- Add any new windows since
  fnutils.each(newwindows, function(win)
    if fnutils.contains(windows, win) == false then
      table.insert(windows, win)
    end
  end)

  -- Remove any bad windows
  windows = fnutils.filter(windows, function(win)
    return win:isstandard()
  end)

  return windows
end

return tiling
