------------------------------------------
--           GMOD Cloud (c) 2020        --
------------------------------------------
GmodCloud = GmodCloud or {}

-- Clients only need to load net messages
if SERVER then 
  AddCSLuaFile("gmodcloud/sh_base.lua")
  AddCSLuaFile("gmodcloud/cl_network.lua")
end
if (CLIENT) then
  include("gmodcloud/sh_base.lua")
  include("gmodcloud/cl_network.lua")
  GmodCloud:PrintInfo("Client Plugin Loaded")
  return
end

local function loadLuaFilesInDirectory(path)
  local files, folders = file.Find(path .. "*", "LUA")

  for k,v in pairs(files) do
    if (SERVER) then
      include(path .. v)
    end
  end
end

function GmodCloud.ModuleLoader()
  loadLuaFilesInDirectory("gmodcloud/modules/")
end

include("sv_config.lua")
include("gmodcloud/sh_base.lua")
include("gmodcloud/sv_base.lua")
include("gmodcloud/sv_helpers.lua")
include("gmodcloud/sv_requests.lua")
include("gmodcloud/sv_queue.lua")
include("gmodcloud/sv_websocket.lua")
include("gmodcloud/sv_events.lua")
include("gmodcloud/sv_init.lua")

loadLuaFilesInDirectory("gmodcloud/gamemodes/")
loadLuaFilesInDirectory("gmodcloud/modules/")


GmodCloud:PrintInfo("Plugin Loaded")