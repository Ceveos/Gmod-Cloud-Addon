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
  
  -- If we have 100 new events, upload
  if #eventsToBeUploaded >= 100 then
    return true
  end

  -- If it's been 5 minutes since our last upload, upload
  if os.difftime( os.time(), lastUploadTime ) > 5 then --  300 then
    return true
  end

  return false
end

-- Will be ran periodically, and via the captureEvent function
-- If it is determined that we should upload our current list
-- of events, it will do so.
local function eventUploadManager()
  if shouldUploadEvents() == false then
    return
  end

  GmodCloud:Print("Uploading captured events")
  
  -- If GmodCloud is requesting player log

  -- Set our root fields that we'll be sending to server
  local rootFields = {
    events =  util.TableToJSON(eventsToBeUploaded)
  }
  -- Reset our events array
  eventsToBeUploaded = {}
  lastUploadTime = os.time()

  rootFields.attributes = {}

  -- Send it off to GmodCloud
  GmodCloud:PostServerLog("Events", rootFields)
end

-- Run eventUploadManager every 30 seconds
timer.Create(GMODCLOUD_EVENT_MANAGER, 30, 0, function() eventUploadManager() end)

---------------------------------------------
-- This function will capture all relevant --
-- events happening in the game and store  --
-- it for upload.                          --
---------------------------------------------
local function captureEvent(eventName, attributes)
  GmodCloud:Print("Captured event - " .. eventName)
  eventsToBeUploaded[#eventsToBeUploaded + 1] = {
    eventName = eventName,
    attributes = util.TableToJSON(attributes)
  }
  eventUploadManager()
end

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
hook.Add("player_connect", "AnnounceConnection", function( data )
  captureEvent("player_connect", {
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
  captureEvent("player_disconnect", {
    bot = (data.bot == 1),
    steamId = data.networkid,
    name = data.name,
    reason = data.reason
  })
end)

---------------------------------------------------------
--                     player_spawn                    --
---------------------------------------------------------
-- - userid: number
---------------------------------------------------------
gameevent.Listen( "player_spawn" )
hook.Add("player_spawn", GMODCLOUD_EVENT_RECORDER, function( data )
  captureEvent("player_spawn", {
    steamId = data.networkid,
  })
end)


---------------------------------------------------------
--                      player_hurt                    --
---------------------------------------------------------
-- - health: number
-- - priority: number
-- - userid: number -- User ID of the victim
-- - attacker: number -- User ID of the attacker
---------------------------------------------------------
gameevent.Listen( "player_hurt" )
hook.Add("player_hurt", GMODCLOUD_EVENT_RECORDER, function( data )
  captureEvent("player_hurt", {
    health = data.health,
    priority = data.priority,
    victim = data.userid,
    attacker = data.attacker
  })
end)

---------------------------------------------------------
--                       player_say                    --
---------------------------------------------------------
-- - priority: number
-- - userid: number
-- - text: string
---------------------------------------------------------
gameevent.Listen( "player_say" )
hook.Add("player_say", GMODCLOUD_EVENT_RECORDER, function( data )
  captureEvent("player_say", {
    priority = data.priority,
    userid = data.userid,
    text = data.text
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
  captureEvent("player_changename", {
    userid = data.userid,
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
  captureEvent("server_cvar", {
    cvarname = data.cvarname,
    cvarvalue = data.cvarvalue
  })
end)
