local tiling = {}

local application = require "hs.application"
local window = require "hs.window"
local screen = require "hs.screen"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local alert = require "hs.alert"
local layouts = require "hs.tiling.layouts"
local spaces = {}
local settings = { layouts = {} }

local excluded = {}
function tiling.togglefloat(floatfn)
  local win = window:focusedWindow()
  local id = win:id()
  excluded[id] = not excluded[id]

  if excluded[id] then
    if floatfn then floatfn(win) end
    alert.show("Excluding " .. win:title() .. " from tiles")
  else
    alert.show("Adding " .. win:title() .. " to tiles")
  end

  local space = getspace()
  apply(space.windows, space.layout)
end

function tiling.addlayout(name, layout)
  layouts[name] = layout
  setlayouts(layouts)
end

function tiling.set(name, value)
  settings[name] = value
end

function tiling.retile()
  local space = getSpace()
  apply(space.windows, space.layout)
end

function tiling.cycle(direction)
  local space = getspace()
  local windows = space.windows
  local win = window:focusedWindow() or windows[1]
  local direction = direction or 1
  local currentindex = fnutils.indexOf(windows, win)
  local layout = space.layout
  if not currentindex then return end
  nextindex = currentindex + direction
  if nextindex > #windows then
    nextindex = 1
  elseif nextindex < 1 then
    nextindex = #windows
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
  local win = window:focusedWindow() or windows[1]
  local i = fnutils.indexOf(windows, win)
  if not i then return end

  local current = table.remove(windows, i)
  table.insert(windows, 1, current)
  win:focus()
  apply(windows, space.layout)
end

function apply(windows, layout)
  layouts[layout](windows)
end

function iswindowincluded(win)
  onscreen = win:screen() == screen.mainScreen()
  standard = win:isStandard()
  hastitle = #win:title() > 0
  istiling = not excluded[win:id()]
  return onscreen and standard and hastitle and istiling
end

-- Infer a 'space' from our existing spaces
function getspace()
  local windows = fnutils.filter(window.visibleWindows(), iswindowincluded)

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
    return win:isStandard()
  end)

  return windows
end

function setlayouts(layouts)
  local n = 0
  for k, v in pairs(layouts) do
    n = n + 1
    settings.layouts[n] = k
  end
end

setlayouts(layouts)

return tiling
