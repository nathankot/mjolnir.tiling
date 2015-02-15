local tiling = {}

local application = require "mjolnir.application"
local window = require "mjolnir.window"
local screen = require "mjolnir.screen"
local fnutils = require "mjolnir.fnutils"
local geometry = require "mjolnir.geometry"
local alert = require "mjolnir.alert"
local layouts = require "mjolnir.tiling.layouts"
local socket = require "socket"
local spaces = {}
local settings = { layouts = {} }

local excluded = {}
function tiling.togglefloat(floatfn)
  local win = window:focusedwindow()
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
  local space = getspace()
  apply(space.windows, space.layout)
end

function tiling.cycle(direction)
  local space = getspace()
  local windows = space.windows
  local win = window:focusedwindow() or windows[1]
  local direction = direction or 1
  local currentindex = fnutils.indexof(windows, win)
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
  local x = socket.gettime()
  local space = getspace()
  local y = socket.gettime()
  print(string.format("getspace time: %.6f\n", y - x))

  local x = socket.gettime()
  space.layout = space.layoutcycle()
  local y = socket.gettime()
  print(string.format("layoutcycle time: %.6f\n", y - x))

  local x = socket.gettime()
  apply(space.windows, space.layout)
  local y = socket.gettime()
  print(string.format("apply time: %.6f\n", y - x))

  alert.show(space.layout, 1)
end

function tiling.promote()
  local space = getspace()
  local windows = space.windows
  local win = window:focusedwindow() or windows[1]
  local i = fnutils.indexof(windows, win)
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
  local x = socket.gettime()
  onscreen = win:screen() == screen.mainscreen()
  local y = socket.gettime()
  print(string.format("win:screen time: %.6f\n", y - x))

  local x = socket.gettime()
  standard = win:isstandard()
  local y = socket.gettime()
  print(string.format("win:isstandard time: %.6f\n", y - x))

  local x = socket.gettime()
  hastitle = #win:title() > 0
  local y = socket.gettime()
  print(string.format("#win:title time: %.6f\n", y - x))

  local x = socket.gettime()
  istiling = #excluded == 0 or not excluded[win:id()]
  local y = socket.gettime()
  print(string.format("excluded[win time: %.6f\n", y - x))

  return onscreen and standard and hastitle and istiling
end

-- Infer a 'space' from our existing spaces
function getspace()
  local x = socket.gettime()
  -- Call application.allwindows() ourselves to get timing information
  -- per application, instead of indirectly calling it through
  -- window.visiblewindows()
  print("Timing application.allwindows")
  local allwindows = fnutils.mapcat(
     application.runningapplications(),
     function(app)
        local x = socket.gettime()
        local allwindows = application.allwindows(app)
        local y = socket.gettime()
        print(string.format("application.allwindows time for %s: %.6f",
                            app:title(), y - x))
        return allwindows
  end)
  print("\n")
  local visiblewindows = fnutils.filter(allwindows, window.isvisible)
  local windows = fnutils.filter(visiblewindows, iswindowincluded)
  local y = socket.gettime()
  print(string.format("fnutils.filter time: %.6f\n", y - x))

  local x = socket.gettime()
  fnutils.each(spaces, function(space)
    local matches = 0
    fnutils.each(space.windows, function(win)
      if fnutils.contains(windows, win) then matches = matches + 1 end
    end)
    space.matches = matches
  end)
  local y = socket.gettime()
  print(string.format("fnutils.each time: %.6f\n", y - x))

  local x = socket.gettime()
  table.sort(spaces, function(a, b) return a.matches > b.matches end)
  local y = socket.gettime()
  print(string.format("table.sort time: %.6f\n", y - x))

  local space = {}

  if #spaces == 0 or spaces[1].matches == 0 then
    local x = socket.gettime()
    space.windows = windows
    space.layoutcycle = fnutils.cycle(settings.layouts)
    space.layout = settings.layouts[1]
    table.insert(spaces, space)
    local y = socket.gettime()
    print(string.format("space creation time: %.6f\n", y - x))
  else
    space = spaces[1]
  end

  local x = socket.gettime()
  space.windows = syncwindows(space.windows, windows)
  local y = socket.gettime()
  print(string.format("syncwindows time: %.6f\n", y - x))
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

function setlayouts(layouts)
  local n = 0
  for k, v in pairs(layouts) do
    n = n + 1
    settings.layouts[n] = k
  end
end

setlayouts(layouts)

return tiling
