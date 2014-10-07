local fnutils = require "mjolnir.fnutils"
local layouts = {}

layouts['fullscreen'] = function(windows)
  fnutils.each(windows, function(window)
    window:maximize()
  end)
end

layouts['main-vertical'] = function(windows)
  local wincount = #windows

  if wincount == 1 then
    return layouts['fullscreen'](windows)
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

return layouts
