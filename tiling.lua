local application = require "mjolnir.application"
local window = require "mjolnir.window"
local screen = require "mjolnir.screen"
local fnutils = require "mjolnir.fnutils"
local geometry = require "mjolnir.geometry"
local alert = require "mjolnir.alert"

local settings = {
  layouts = { 'main-vertical', 'fullscreen' }
}

local tiling = {}
local spaces = {}

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
  if layout == 'fullscreen' then
    fnutils.each(windows, function(window)
      window:maximize()
    end)
  end

  if layout == 'main-vertical' then
    local wincount = #windows

    if wincount == 1 then
      return apply(windows, 'fullscreen')
    end

    for index, win in pairs(windows) do
      local frame = win:screen():frame()

      if index == 1 then
        frame.x, frame.y = 0, 0
        frame.w = frame.w / 2
      else
        frame.x = frame.w / 2
        frame.w = frame.w / 2
        frame.h = frame.h / (wincount - 1)
        frame.y = frame.h * (index - 2)
      end

      win:setframe(frame)
    end
  end
end

-- Infer a 'space' from our existing spaces
function getspace()
  local windows = fnutils.filter(window.visiblewindows(), function(win)
    return win:screen():id() == screen.mainscreen():id()
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
