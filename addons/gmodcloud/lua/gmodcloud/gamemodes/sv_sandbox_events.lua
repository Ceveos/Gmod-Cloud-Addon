--------------------------------------------------
--             GMOD Cloud (c) 2020              --
--------------------------------------------------
--                                              --
-- This file contains the logic to record and   --
-- Upload events that occur in the game. For e- --
-- xample, damage events or killed evnts. Will  --
-- help server owners determine RDM             --
--                                              --
---------------------------------------------------


------------------------------------------
--               CONSTANTS              --
------------------------------------------
local GMODCLOUD_EVENT_RECORDER = "GMODCLOUD_EVENT_RECORDER"

------------------------------------------
--                 Hooks                --
------------------------------------------
hook.Add("PlayerSpawnProp", GMODCLOUD_EVENT_RECORDER, 
function(ply, model)
  GmodCloud:CaptureEvent("PlayerSpawnProp", {
    steamId = ply:SteamID(),
    model = model,
  })
end)