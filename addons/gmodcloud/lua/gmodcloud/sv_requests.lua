------------------------------------------
--        GMOD Cloud (c) 2020           --
------------------------------------------

---------------------------------------
--             Constants             --
---------------------------------------
-- Hook naming/calling constants
local GMODCLOUD = "GMODCLOUD"
local GMODCLOUD_REQUEST = "GMODCLOUD_REQUEST" -- Hook name for when a request for data arrives
local GMODCLOUD_LOG_PLAYER_RESP = "GMODCLOUD_LOG_PLAYER_RESP" -- Hook name for when a player log response is successfully completed
local GMODCLOUD_RESP_FAIL = "GMODCLOUD_RESP_FAIL" -- Hook name for when there's an API response failure

-- Fired when GmodCloud came back requesting information
local function onGmodCloudRequestResponse(request)
  GmodCloud:Print("[Request] Received request " .. request)
end

-- Deal with Player Log requests
local function onGmodCloudRequestPlayerLog(request)
  -- If GmodCloud is requesting player log
  if request == "PlayerLog" then
    local rootFields = {}
    local players = {}
    -- Get a list of all current players steam id
    for k, v in pairs( player.GetAll() ) do
      players[#players + 1] = v:SteamID()
    end
    rootFields.players = util.TableToJSON(players)
    rootFields.attributes = {}
    
    -- Send it off to GmodCloud
    GmodCloud:PostServerLog("Players", rootFields) 
  end
end

local function onGmodCloudPlayerLogResponse(response)
  if (response.error) then
    GmodCloud:PrintError("[Request] [Player Log] " .. response.errorMsg)
  else 
    GmodCloud:Print("[Request] [Player Log] Request successfully logged")
  end
end

hook.Add(GMODCLOUD_REQUEST, GMODCLOUD, onGmodCloudRequestResponse)
hook.Add(GMODCLOUD_REQUEST, GMODCLOUD, onGmodCloudRequestPlayerLog)
hook.Add(GMODCLOUD_LOG_PLAYER_RESP, GMODCLOUD, onGmodCloudPlayerLogResponse)