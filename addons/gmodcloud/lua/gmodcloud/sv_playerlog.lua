-----------------------------------------------------
--              GMOD Cloud (c) 2020                --
-----------------------------------------------------
--                                                 --
-- This file contains the logic to keep track of   --
-- connected players. Then upload stats of the pl- --
-- ayer online.                                    --
--                                                 --
-----------------------------------------------------


------------------------------------------
--               CONSTANTS              --
------------------------------------------
local GMODCLOUD_PLAYERLOG = "GMODCLOUD_EVENT_MANAGER"
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED"

------------------------------------------
--               LOCAL VAR              --
------------------------------------------

------------------------------------------
--            LOCAL FUNCTIONS           --
------------------------------------------
local function reportPlayerData(data)
  if GmodCloud:IsInitialized() then
    GmodCloud:Print("Uploading player data")
    GmodCloud:PostServerLog("Player", data) 
  end
end

-- To account for map changes, etc.. 
-- we're using a adjusted player time variable 
-- to see how much longer the player was on the server
local function getAdjustedPlayerTime(ply)
  local timeConnected = ply:TimeConnected()
  if ply.GMODCLOUD_TimeConnectedDelta != nil then
    timeConnected = timeConnected - ply.GMODCLOUD_TimeConnectedDelta
  end

  if timeConnected < 0 then timeConnected = 0 end
  return timeConnected
end

hook.Add("ShutDown", GMODCLOUD_PLAYERLOG, function()
  for k, v in pairs( player.GetAll() ) do
    if v:IsValid() and !v:IsBot() then
      reportPlayerData({
        steamId = v:SteamID(),
        usergroup = v:GetUserGroup(),
        nick = v:Nick(),
        action = "Disconnect",
        timeConnected = tostring(math.floor(getAdjustedPlayerTime(v)))
      })
    end
  end
end)

hook.Add("PlayerAuthed", GMODCLOUD_PLAYERLOG, function( ply, steamid, uniqueid )
  if ply:IsValid() and !ply:IsBot() then
    ply.GMODCLOUD_TimeConnectedDelta = ply:TimeConnected()          -- When server changes maps, time connected is not reset. Account for it here
    reportPlayerData({
      steamId = steamid,
      usergroup = ply:GetUserGroup(),
      nick = ply:Nick(),
      action = "Connect",
      timeConnected = "0"                                           -- We do not want to increment player time when authing
    })
  end
end)

hook.Add("PlayerDisconnected", GMODCLOUD_PLAYERLOG, function( ply )
  if ply:IsValid() and !ply:IsBot() then
    reportPlayerData({
      steamId = ply:SteamID(),
      usergroup = ply:GetUserGroup(),
      nick = ply:Nick(),
      action = "Disconnect",
      timeConnected = tostring(math.floor(getAdjustedPlayerTime(ply))) -- Server is expecting player time to be a string representing a whole number
    })
  end
end)