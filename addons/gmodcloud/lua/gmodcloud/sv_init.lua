------------------------------------------
--        GMOD Cloud (c) 2020           --
------------------------------------------

---------------------------------------
--             Constants             --
---------------------------------------
-- Hook naming/calling constants
local GMODCLOUD = "GMODCLOUD" -- Used for hook naming
local GMODCLOUD_INIT = "GMODCLOUD_INIT" -- 
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED" -- Hook name for when initializing completed
local GMODCLOUD_RESP_FAIL = "GMODCLOUD_RESP_FAIL" -- Hook name for when there's an API response failure

---------------------------------------
--            Local Vars             --
---------------------------------------

-- Have we pinged the gmod cloud server
local initialized = false

-- Have we been set up yet
local isServerSetUp = false

-- Is this server banned from Gmod Cloud?
local serverBanned = false

---------------------------------------
--         Public Functions          --
---------------------------------------
function GmodCloud:IsBanned() 
  return serverBanned
end

function GmodCloud:IsInitialized()
  return initialized
end

function GmodCloud:IsSetup() 
  return isServerSetUp
end

---------------------------------------
--          Local Functions          --
---------------------------------------

local function initialize()
  GmodCloud:Print("Initialized fired")

  -- Ensure we don't run initialization more than once
  if initialized then 
    GmodCloud:PrintWarning("Attempted to re-initialize! This shouldn't be happening.")
    return
  end
  GmodCloud:Print("Attempting to initialize")

  local serverId = file.Read("gmodcloud/serverid.txt", "DATA")

  if serverId == nil then
    -- Need to register server on website
    GmodCloud:PrintInfo("Server not registered on GmodCloud")
    GmodCloud:PrintInfo("Attempting to register")

    -- Get a new server ID
    GmodCloud:PostData("server/register", {serverName = GetHostName(), ip = game.GetIPAddress()}, GMODCLOUD_INIT, GMODCLOUD_RESP_FAIL)
  else 
    GmodCloud:PrintInfo("Server registration information found")
    GmodCloud:PrintInfo("Pinging Gmod Cloud")
  end
end

-- Test function to see if we can get data from Gmod Cloud
local function onGmodCloudInitResp(result)
  GmodCloud:Print("[Init] Got from the server: " .. result)
  local resp = util.JSONToTable(result)
  if resp.error then
    GmodCloud:PrintError(resp.errorMsg)
  else 
    GmodCloud:PrintSuccess("Server ID: " .. resp.serverId)
  end
end

-- Test function to see if we fail to get data from Gmod Cloud
local function onGmodCloudRespFail(result)
  GmodCloud:PrintError("Failed to get response: " .. result)
end

local function onGmodCloudServerCreate(result)

end


---------------------------------------
--               Hooks               --
---------------------------------------
hook.Add(GMODCLOUD_INIT, GMODCLOUD, onGmodCloudInitResp)
hook.Add(GMODCLOUD_RESP_FAIL, GMODCLOUD, onGmodCloudRespFail)

-- We have to initialize after this timer since Steam IHTTP is not available beforehand
timer.Simple(0, function() initialize() end )
