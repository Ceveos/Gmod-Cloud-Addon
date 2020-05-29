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
  include("gmodcloud/sh_base.lua")                  -- Shared base functions used by client and server
  include("gmodcloud/cl_network.lua")               -- Client file to receive network strings (i.e. web chats)
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

include("sv_config.lua")                    -- Main configuration file containing version, steam id, and api key
include("gmodcloud/sh_base.lua")            -- Shared base functions used by client and server
include("gmodcloud/sv_base.lua")            -- Server base functions that is used predominately by the helper
include("gmodcloud/sv_helpers.lua")         -- Helper functions that other files will use
include("gmodcloud/sv_requests.lua")        -- Deals with requests that GmodCloud is requesting
include("gmodcloud/sv_queue.lua")           -- Deals with queueing information that will be uploaded
include("gmodcloud/sv_websocket.lua")       -- Initializes the websocket connection to GmodCloud
include("gmodcloud/sv_events.lua")          -- Capture events that occur in game, and upload/stream them
include("gmodcloud/sv_playerlog.lua")       -- Capture player info as they connect/disconnect from server
include("gmodcloud/sv_init.lua")            -- Initialize the plugin / connects to GmodCloud

loadLuaFilesInDirectory("gmodcloud/gamemodes/")
loadLuaFilesInDirectory("gmodcloud/modules/")


GmodCloud:PrintInfo("Plugin Loaded")