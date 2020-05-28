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
local GMODCLOUD_EVENT_MANAGER = "GMODCLOUD_EVENT_MANAGER"
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED"
local GMODCLOUD_WEBSOCKET_START_LIVE_STREAM = "GMODCLOUD_WS_START_LIVE_STREAM"
local GMODCLOUD_WEBSOCKET_STOP_LIVE_STREAM = "GMODCLOUD_WS_STOP_LIVE_STREAM"

------------------------------------------
--               LOCAL VAR              --
------------------------------------------

-- Events to be uploaded is an array containing
-- a ready-to-send list of events up to the server
-- It will be uploaded periodically.
local eventsToBeUploaded = {}
local lastUploadTime = os.time()

local function shouldUploadEvents()
  -- If nothing to upload, don't
  if #eventsToBeUploaded == 0 then
    return false
  end

  -- If streaming events, upload
  if GmodCloud:Should_Stream_Events() then
    return true
  end
  
  -- If we have 100 new events, upload
  if #eventsToBeUploaded >= 100 then
    return true
  end

  -- If it's been 5 minutes since our last upload, upload
  if os.difftime( os.time(), lastUploadTime ) > 300 then
    return true
  end

  return false
end

-- Will be ran periodically via the GmodCloud:CaptureEvent function.
-- If it is determined that we should upload our current list
-- of events, it will do so.
local function eventUploadManager()
  if shouldUploadEvents() == false then
    return
  end

  local events = util.TableToJSON(eventsToBeUploaded)
 
  -- Reset our events array
  eventsToBeUploaded = {}
  lastUploadTime = os.time()

  if GmodCloud:Should_Stream_Events() then
    GmodCloud:Print("Streaming events")
    GmodCloud:StreamEvent(events)
  else
    GmodCloud:Print("Uploading captured events")

    -- Set our root fields that we'll be sending to server
    local rootFields = {
      events =  events
    }

    rootFields.attributes = {}

    -- Send it off to GmodCloud
    GmodCloud:PostServerLog("Events", rootFields)
  end
end

local function onStartWebsocketStreaming()
  GmodCloud:PrintInfo("Livestreaming events")
  timer.Destroy(GMODCLOUD_EVENT_MANAGER)
  -- With timer destroyed, events may be queued up
  -- Stream them now
  eventUploadManager()
end

local function onStopWebsocketStreaming()
  GmodCloud:PrintInfo("Polling events")
  timer.Create(GMODCLOUD_EVENT_MANAGER, 30, 0, function() eventUploadManager() end)
end

-- Once init is completed, run our event manager
local function onInitCompleted()
  -- Run eventUploadManager every 30 seconds
  -- Only run if we're not streaming events via websockets
  if GmodCloud:Should_Stream_Events() == false then
    -- To reduce code duplication, run function that creates timer
    onStopWebsocketStreaming()
  end
end

hook.Add(GMODCLOUD_INIT_COMPLETED, GMODCLOUD_EVENT_MANAGER, onInitCompleted)
hook.Add(GMODCLOUD_WEBSOCKET_START_LIVE_STREAM, GMODCLOUD_EVENT_MANAGER, onStartWebsocketStreaming)
hook.Add(GMODCLOUD_WEBSOCKET_STOP_LIVE_STREAM, GMODCLOUD_EVENT_MANAGER, onStopWebsocketStreaming)

---------------------------------------------
-- This function will capture all relevant --
-- events happening in the game and store  --
-- it for upload.                          --
---------------------------------------------
function GmodCloud:CaptureEvent(eventName, attributes)
  GmodCloud:Print("Captured event - " .. eventName)
  eventsToBeUploaded[#eventsToBeUploaded + 1] = {
    eventName = eventName,
    attributes = util.TableToJSON(attributes),
    timestamp = os.time()
  }
  eventUploadManager()
end

hook.Add("OnPlayerChat", GMODCLOUD_EVENT_RECORDER, 
function(ply, strText, bTeamOnly, bPlayerIsDead)
  GmodCloud:CaptureEvent("OnPlayerChat", {
    steamId = ply:SteamID(),
    text = strText,
    isTeams = bTeamOnly,
    isDead = bPlayerIsDead,
  })
end)

hook.Add("PlayerAuthed", GMODCLOUD_EVENT_RECORDER, 
function (ply, steamid, uniqueid)
  GmodCloud:CaptureEvent("PlayerAuthed", {
    steamId = steamid
  })
end)

hook.Add("PlayerDeath", GMODCLOUD_EVENT_RECORDER, 
function (victim, inflictor, attacker)
  GmodCloud:CaptureEvent("PlayerDeath", {
    victim = victim:SteamID(),
    attacker = (attacker:IsPlayer() and attacker:SteamID()) or attacker:GetClass(),
    inflictor = inflictor and inflictor:IsValid() and inflictor:GetClass(),
    suicide = victim == attacker
  })
end)


hook.Add("PlayerDisconnected", GMODCLOUD_EVENT_RECORDER, 
function (ply)
  GmodCloud:CaptureEvent("PlayerDisconnected", {
    steamId = ply:SteamID()
  })
end)


hook.Add("PlayerLeaveVehicle", GMODCLOUD_EVENT_RECORDER, 
function (ply, veh)
  GmodCloud:CaptureEvent("PlayerLeaveVehicle", {
    steamId = ply:SteamID(),
    vehicle = veh and veh:IsValid() and veh:GetClass()
  })
end)

hook.Add("PlayerSilentDeath", GMODCLOUD_EVENT_RECORDER, 
function (ply)
  GmodCloud:CaptureEvent("PlayerSilentDeath", {
    steamId = ply:SteamID()
  })
end)

hook.Add("PlayerSpawn", GMODCLOUD_EVENT_RECORDER, 
function (ply)
  GmodCloud:CaptureEvent("PlayerSpawn", {
    steamId = ply:SteamID()
  })
end)

hook.Add("PropBreak", GMODCLOUD_EVENT_RECORDER, 
function (ply, prop)
  GmodCloud:CaptureEvent("PropBreak", {
    steamId = ply:SteamID(),
    prop = prop and prop:IsValid() and prop:GetClass()
  })
end)

hook.Add("ShutDown", GMODCLOUD_EVENT_RECORDER, 
function ()
  GmodCloud:CaptureEvent("ShutDown", {})
end)
-------------------------------------------------------------------------------------------------------------

---------------------------------------------------------
--                    player_connect                   --
---------------------------------------------------------
-- - bot: number (0 = player, 1 = bot)
-- - networkid: string (STEAM id)
-- - name: string
-- - userid: number
-- - index: The entity index of the player, minus one
-- - address: string (IP Address)
---------------------------------------------------------
gameevent.Listen( "player_connect" )
hook.Add("player_connect", GMODCLOUD_EVENT_RECORDER, function( data )
  GmodCloud:CaptureEvent("player_connect", {
    bot = (data.bot == 1),
    steamId = data.networkid,
    name = data.name,
    ip = data.address
  })
end)

---------------------------------------------------------
--                   player_disconnect                 --
---------------------------------------------------------
-- - bot: number (0 = player, 1 = bot)
-- - networkid: string (STEAM id)
-- - name: string
-- - userid: number
-- - reason: Reason for disconnect
---------------------------------------------------------
gameevent.Listen( "player_disconnect" )
hook.Add("player_disconnect", GMODCLOUD_EVENT_RECORDER, function( data )
  GmodCloud:CaptureEvent("player_disconnect", {
    bot = (data.bot == 1),
    steamId = data.networkid,
    name = data.name,
    reason = data.reason
  })
end)


---------------------------------------------------------
--                        PlayerSay                    --
---------------------------------------------------------
-- - ply: Player
-- - text: string
---------------------------------------------------------
hook.Add("PlayerSay", GMODCLOUD_EVENT_RECORDER, function( ply, text )
  GmodCloud:CaptureEvent("PlayerSay", {
    steamId = (ply == nil && nil) or (ply:IsPlayer() and ply:SteamID()) or ply:GetClass(),
    text = text,
    web = false
  })
end)

---------------------------------------------------------
--                   player_changename                 --
---------------------------------------------------------
-- - userid: number
-- - oldname: string
-- - newname: string
---------------------------------------------------------
gameevent.Listen( "player_changename" )
hook.Add("player_changename", GMODCLOUD_EVENT_RECORDER, function( data )
  local ply = player.GetByID(data.userid)
  GmodCloud:CaptureEvent("player_changename", {
    steamId = (ply == nil && nil) or (ply:IsPlayer() and ply:SteamID()) or ply:GetClass(),
    oldName = data.oldname,
    newName = data.newname
  })
end)

---------------------------------------------------------
--                      server_cvar                    --
---------------------------------------------------------
-- - cvarname: string
-- - cvarvalue: string
---------------------------------------------------------
gameevent.Listen( "server_cvar" )
hook.Add("server_cvar", GMODCLOUD_EVENT_RECORDER, function( data )
  GmodCloud:CaptureEvent("server_cvar", {
    cvarname = data.cvarname,
    cvarvalue = data.cvarvalue
  })
end)
