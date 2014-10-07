package = "mjolnir.tiling"
version = "0.1-1"

local url = "github.com/nathankot/mjolnir.tiling"

source = {
  url = "git://" .. url
}

description = {
  summary = "Tiling window management for mjolnir",
  homepage = "https://" .. url,
  license = "MIT",
  detailed = [[
    Tiling window management for mjolnir. Inspired by tmux's window management
    and built-in layouts. Supports multiple spaces and displays.
  ]]
}

supported_platforms = {
  "macosx"
}

dependencies = {
   "lua >= 5.2",
   "mjolnir.alert",
   "mjolnir.application"
}

build = {
  type = "builtin",
  modules = {
    ["mjolnir.tiling"] = "tiling.lua",
    ["mjolnir.tiling.layouts"] = "layouts.lua"
  }
}
