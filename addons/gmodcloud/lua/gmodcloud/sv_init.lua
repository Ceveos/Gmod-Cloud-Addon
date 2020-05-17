------------------------------------------
--        GMOD Cloud (c) 2020           --
------------------------------------------

---------------------------------------
--             Constants             --
---------------------------------------
-- Hook naming/calling constants
local GMODCLOUD = "GMODCLOUD"
local GMODCLOUD_INIT = "GMODCLOUD_INIT"
local GMODCLOUD_PING_TIMER = "GMODCLOUD_PING_TIMER"
local GMODCLOUD_SERVER_REGISTERED = "GMODCLOUD_SERVER_REGISTERED" -- fired whenever a server is registered on Gmod Cloud
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED" -- Hook name for when initializing completed
local GMODCLOUD_RESP_FAIL = "GMODCLOUD_RESP_FAIL" -- Hook name for when there's an API response failure
local GMODCLOUD_PING_RESP = "GMODCLOUD_PING_RESP" -- Hook name for when a ping response is acquired
local GMODCLOUD_REQUEST = "GMODCLOUD_REQUEST" -- Hook name for when a request for data arrives
local GMODCLOUD_RUN_QUEUE = "GMODCLOUD_RUN_QUEUE"

---------------------------------------
--            Local Vars             --
---------------------------------------

-- Have we pinged the gmod cloud server
local initialized = false

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


---------------------------------------
--          Local Functions          --
---------------------------------------

-- Get basic server information that will be used
-- to register the server on GmodCloud and keep
-- it up to date
local function getServerPingInformation() 
  
  -------------------------- INFO ------------------------------
  -- All these fields are marked as required by the API
  -- You are free to add custom fields which will be stored.
  --------------------------------------------------------------
  -- There is no current way to use the extra fields defined.
  --------------------------------------------------------------
  return {
    serverName = GetHostName(),                 -- REQUIRED
    ip = game.GetIPAddress(),                   -- REQUIRED
    maxPlayers = tostring(game.MaxPlayers()),   -- REQUIRED
    players = tostring(player.GetCount()),      -- REQUIRED
    gameMode = gmod.GetGamemode().Name,         -- REQUIRED
    map = game.GetMap()                         -- REQUIRED
  }
end


-- Called on startup and periodically to ping Gmod Cloud for updates
local function pingGmodCloud()
  GmodCloud:PrintInfo("Pinging Gmod Cloud")
  
  -- Ping server
  GmodCloud:PostServerUpdate(getServerPingInformation(), GMODCLOUD_PING_RESP, GMODCLOUD_RESP_FAIL)
end

-- Create  a timer to ping the server
-- Will run every 10 minutes
local function createPingTimer()
  timer.Create( GMODCLOUD_PING_TIMER, 600, 0, function() pingGmodCloud() end )
end


-- Ping response
local function onGmodCloudPingResponse(result)
  if result.error then
    GmodCloud:PrintError("[Ping] " .. result.errorMsg)
    return
  end

  GmodCloud:Print("[Ping] Successful ping")

  -- The server will come back with requests if it's looking for data
  -- We're going to broadcast the request so anyone can listen in and fulfill the request
  -- Examples of requests:
  -- - Player Log: Get a list of all currently online players, and other attributes (i.e. # of staff online)
  if result.request then
    GmodCloud:Print("[Request] Performing requests")
    for _, request in ipairs(result.request) do
      hook.Run(GMODCLOUD_REQUEST, request)
    end
    -- Run Queue to ensure we're not blocked (i.e. empty server)
    hook.Run(GMODCLOUD_RUN_QUEUE, nil)
  end
end

-- Whenever the server is first registered on GmodCloud
local function onGmodCloudServerRegistered(result)
  if result.error then
    GmodCloud:PrintError(result.errorMsg)
  else 
    GmodCloud:PrintSuccess("Registered! Server ID: " .. result.serverId)
    GmodCloud:SetServerInfo(result.serverId, result.secretKey)
    initialized = true
    createPingTimer()
    hook.Run(GMODCLOUD_INIT_COMPLETED)
  end
end

-- Test function to see if we fail to get data from Gmod Cloud
local function onGmodCloudRespFail(result)
  GmodCloud:PrintError("Failed to get response: " .. util.TableToJSON(result))
end

-- Initialization
-- Attempts to see if we have previously registered with GmodCloud
-- If not, register
local function initialize()
  GmodCloud:Print("Initialized fired")

  -- Ensure we don't run initialization more than once
  if initialized then 
    GmodCloud:PrintWarning("Attempted to re-initialize! This shouldn't be happening.")
    return
  end

  GmodCloud:Print("Attempting to initialize")

  if GmodCloud:ServerInfoExists() then
    GmodCloud:PrintInfo("Server registration information found")
    initialized = true
    hook.Run(GMODCLOUD_INIT_COMPLETED)
    createPingTimer()
  else 
    -- Need to register server on website
    GmodCloud:PrintInfo("Server not registered on GmodCloud")
    GmodCloud:PrintInfo("Attempting to register")

    -- Get a server ID
    GmodCloud:RegisterServer(getServerPingInformation(), GMODCLOUD_SERVER_REGISTERED, GMODCLOUD_RESP_FAIL) 
  end
end

-- There is a bug where game.GetIPAddress() returns 0.0.0.0:PORT
-- Wait until the IP is valid
local function canInitialize()
  local ip = game.GetIPAddress()
  if !string.StartWith(ip, "0.") then
    initialize()
  else
    timer.Simple(0, function() canInitialize() end )
  end
end

---------------------------------------
--               Hooks               --
---------------------------------------
hook.Add(GMODCLOUD_SERVER_REGISTERED, GMODCLOUD, onGmodCloudServerRegistered)
hook.Add(GMODCLOUD_RESP_FAIL, GMODCLOUD, onGmodCloudRespFail)

hook.Add(GMODCLOUD_INIT_COMPLETED, GMODCLOUD, pingGmodCloud)
hook.Add(GMODCLOUD_PING_RESP, GMODCLOUD, onGmodCloudPingResponse)

-- We have to initialize after this timer since Steam IHTTP is not available beforehand
timer.Simple(0, function() canInitialize() end )
