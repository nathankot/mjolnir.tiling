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
-- navigate to layout by name
function tiling.goToLayout(name)
  local space = getSpace()
  local i = 0
  while space.layout ~= name and i < #settings.layouts do
    space.layout = space.layoutCycle()
    i = i + 1
  end
  if i < #settings.layouts then 
    alert.show(space.layout, 1)
    apply(space.windows, space.layout)
  else
    alert.show('Layout ' .. name .. ' does not exist', 1)
  end
end

function tiling.toggleFloat(floatfn)
  local win = window:focusedWindow()
  local id = win:id()
  excluded[id] = not excluded[id]

  if excluded[id] then
    if floatfn then floatfn(win) end
    alert.show("Excluding " .. win:title() .. " from tiles")
  else
    alert.show("Adding " .. win:title() .. " to tiles")
  end

  local space = getSpace()
  apply(space.windows, space.layout)
end

function tiling.addLayout(name, layout)
  layouts[name] = layout
  setLayouts(layouts)
end

function tiling.set(name, value)
  settings[name] = value
end

function tiling.retile()
  local space = getSpace()
  apply(space.windows, space.layout)
end

function tiling.cycle(direction)
  local space = getSpace()
  local windows = space.windows
  local win = window:focusedWindow() or windows[1]
  local direction = direction or 1
  local currentIndex = fnutils.indexOf(windows, win)
  local layout = space.layout
  if not currentIndex then return end
  nextIndex = currentIndex + direction
  if nextIndex > #windows then
    nextIndex = 1
  elseif nextIndex < 1 then
    nextIndex = #windows
  end

  windows[nextIndex]:focus()
  apply(windows, layout)
end

function tiling.cycleLayout()
  local space = getSpace()
  space.layout = space.layoutCycle()
  alert.show(space.layout, 1)
  apply(space.windows, space.layout)
end

function tiling.promote()
  local space = getSpace()
  local windows = space.windows
  local win = window:focusedWindow() or windows[1]
  local i = fnutils.indexOf(windows, win)
  if not i then return end

  local current = table.remove(windows, i)
  table.insert(windows, 1, current)
  win:focus()
  apply(windows, space.layout)
end

function tiling.setMainVertical(val)
    if val > 0 and val < 1 then
        local space = getSpace()
        if space.layout == 'main-vertical-variable' then
            space.mainVertical = val
            tiling.retile()
        end
    end
end

function tiling.adjustMainVertical(factor)
    local space = getSpace()
    if space.layout == 'main-vertical-variable' then
        local mainVertical = space.mainVertical
        if mainVertical == nil then
            mainVertical = 0.5
        end
        tiling.setMainVertical(mainVertical + factor)
    end
end

function apply(windows, layout)
  layouts[layout](windows)
end

function isWindowIncluded(win)
  onScreen = win:screen() == screen.mainScreen()
  standard = win:isStandard()
  hasTitle = #win:title() > 0
  isTiling = not excluded[win:id()]
  return onScreen and standard and hasTitle and isTiling
end

-- Infer a 'space' from our existing spaces
function getSpace()
  local windows = fnutils.filter(window.visibleWindows(), isWindowIncluded)

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
    space.layoutCycle = fnutils.cycle(settings.layouts)
    space.layout = settings.layouts[1]
    table.insert(spaces, space)
  else
    space = spaces[1]
  end

  space.windows = syncWindows(space.windows, windows)
  return space
end

function syncWindows(windows, newWindows)
  -- Remove any windows no longer around
  windows = fnutils.filter(windows, function(win)
    return fnutils.contains(newWindows, win)
  end)

  -- Add any new windows since
  fnutils.each(newWindows, function(win)
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

function setLayouts(layouts)
  local n = 0
  for k, v in pairs(layouts) do
    n = n + 1
    settings.layouts[n] = k
  end
end


setLayouts(layouts)

return tiling
