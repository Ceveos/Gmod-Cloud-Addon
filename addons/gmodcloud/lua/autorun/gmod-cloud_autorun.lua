------------------------------------------
--           GMOD Cloud (c) 2020        --
------------------------------------------

-- Server-sided script, so don't load anything for clients
if (CLIENT) then return end


GmodCloud = GmodCloud or {}

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
include("gmodcloud/sv_base.lua")
include("gmodcloud/sv_helpers.lua")
include("gmodcloud/sv_requests.lua")
include("gmodcloud/sv_queue.lua")
include("gmodcloud/sv_events.lua")
include("gmodcloud/sv_websocket.lua")
include("gmodcloud/sv_init.lua")

loadLuaFilesInDirectory("gmodcloud/gamemodes/")
loadLuaFilesInDirectory("gmodcloud/modules/")


GmodCloud:PrintInfo("Plugin Loaded")