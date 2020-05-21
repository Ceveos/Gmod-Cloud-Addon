
---------------------------------------------------
--              GMOD Cloud (c) 2020              --
---------------------------------------------------
--                                               --
-- This file manages the socket communication to --
-- GmodCloud. Web sockets are not used until a   --
-- staff member is on the server page on GmodCl- --
-- oud.                                          -- 
--                                               --
---------------------------------------------------

require("gwsockets")

---------------------------------------
--             Constants             --
---------------------------------------
--          WEBSOCKET TYPES          --
---------------------------------------
local Heartbeat = "Heartbeat"
local ServerInit = "ServerInit"
local ServerRoomStatus = "ServerRoomStatus"
local ServerRoomEmpty = "ServerRoomEmpty"
local InitSuccess = "InitSuccess"
local InitFail = "InitFail"
local Error = "Error"

---------------------------------------
--             Constants             --
---------------------------------------
--               HOOKS               --
---------------------------------------
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED"
local GMODCLOUD_WEBSOCKET = "GMODCLOUD_WEBSOCKET"
local GMODCLOUD_WEBSOCKET_PREFIX = "GMODCLOUD_WS_"
local GMODCLOUD_WEBSOCKET_HEARTBEAT = GMODCLOUD_WEBSOCKET_PREFIX .. Heartbeat
local GMODCLOUD_WEBSOCKET_SERVER_INIT_SUCCESS = GMODCLOUD_WEBSOCKET_PREFIX .. InitSuccess
local GMODCLOUD_WEBSOCKET_SERVER_INIT_FAIL = GMODCLOUD_WEBSOCKET_PREFIX .. InitFail
local GMODCLOUD_WEBSOCKET_SERVER_ROOM_STATUS = GMODCLOUD_WEBSOCKET_PREFIX .. ServerRoomEmpty
local GMODCLOUD_WEBSOCKET_SERVER_ERROR = GMODCLOUD_WEBSOCKET_PREFIX .. Error

---------------------------------------
--            SHARED HOOKS           --
---------------------------------------
local GMODCLOUD_WEBSOCKET_START_LIVE_STREAM = GMODCLOUD_WEBSOCKET_PREFIX .. "START_LIVE_STREAM"
local GMODCLOUD_WEBSOCKET_STOP_LIVE_STREAM = GMODCLOUD_WEBSOCKET_PREFIX .. "STOP_LIVE_STREAM"


---------------------------------------
--             Local vars            --
---------------------------------------
local serverId = nil
local socket = GWSockets.createWebSocket("wss://ws.gmodcloud.com/")
local serverRoomEmpty = true


---------------------------------------
--          Public Functions         --
---------------------------------------
-- Should we stream gmod events live?
function GmodCloud:Should_Stream_Events() 
  return !serverRoomEmpty
end

function GmodCloud:StreamEvent(events)
  socket:write(util.TableToJSON({
    type = "ServerEvent",
    events = events
  },false))
end

---------------------------------------
--           Local Functions         --
---------------------------------------
function socket:onMessage(txt)
  local resp = util.JSONToTable(txt);
  if resp == nill || resp.type == nil then 
    GmodCloud:PrintError("[WebSocket] Unknown websocket response")
    return
  end
  hook.Run(GMODCLOUD_WEBSOCKET_PREFIX .. resp.type, socket, resp.data)
end

function socket:onError(txt)
  GmodCloud:PrintError("Error: " .. txt)
end

function socket:onConnected()
  timer.Destroy(GMODCLOUD_WEBSOCKET)
  GmodCloud:PrintSuccess("[WebSocket] Connected to GmodCloud Websocket")
  
  socket:write(util.TableToJSON({
    type = "ServerInit",
    serverId = serverId
  },false))
end

local function attemptConnection()
  if !socket:isConnected() then
    GmodCloud:Print("[WebSocket] Attempting connection") 
    socket:open()
  end 
end

function socket:onDisconnected()
  GmodCloud:PrintInfo("WebSocket disconnected")
  timer.Create(GMODCLOUD_WEBSOCKET, 5, 0, function() attemptConnection() end)
end

local function onInitCompleted()
  local serverInfo = GmodCloud:GetServerInfo()
  if serverInfo == nil then
    GmodCloud:PrintError("[WebSocket] Error initializing - Server Info does not exist!")
    return
  end

  serverId = serverInfo.serverId

  -- Run every 5 seconds
  timer.Create(GMODCLOUD_WEBSOCKET, 5, 0, function() attemptConnection() end)
  -- But try to connect immediately
  attemptConnection()
end

-- We need to send a heartbeat to keep the connection alive.
-- Runs every 5-10 seconds
local function onHeartbeat(socket, data)
  socket:write(util.TableToJSON({
    type = "Heartbeat"
  },false))
end

local function onServerInitSuccess(socket, data)
  GmodCloud:Print("[WebSocket] Server successfully initialized")
  socket:write(util.TableToJSON({
    type = "ServerRoomStatus"
  },false))
end

local function onServerInitFail(socket, data)
  GmodCloud:PrintError("[WebSocket] Issue initializing server")
end

local function onServerRoomEmpty(socket, isEmpty)
  if isEmpty then
    GmodCloud:Print(string.format("[WebSocket] Server room is empty"))
    serverRoomEmpty = true
    hook.Run(GMODCLOUD_WEBSOCKET_STOP_LIVE_STREAM)
  else
    GmodCloud:Print(string.format("[WebSocket] Server room is not empty"))
    serverRoomEmpty = false
    hook.Run(GMODCLOUD_WEBSOCKET_START_LIVE_STREAM)
  end
end


local function onServerError(socket, data)
  GmodCloud:PrintError("[WebSocket] Error: " .. data)
end

hook.Add(GMODCLOUD_INIT_COMPLETED, GMODCLOUD_WEBSOCKET, onInitCompleted)
hook.Add(GMODCLOUD_WEBSOCKET_HEARTBEAT, GMODCLOUD_WEBSOCKET, onHeartbeat)
hook.Add(GMODCLOUD_WEBSOCKET_SERVER_INIT_SUCCESS, GMODCLOUD_WEBSOCKET, onServerInitSuccess)
hook.Add(GMODCLOUD_WEBSOCKET_SERVER_INIT_FAIL, GMODCLOUD_WEBSOCKET, onServerInitFail)
hook.Add(GMODCLOUD_WEBSOCKET_SERVER_ERROR, GMODCLOUD_WEBSOCKET, onServerError)
hook.Add(GMODCLOUD_WEBSOCKET_SERVER_ROOM_STATUS, GMODCLOUD_WEBSOCKET, onServerRoomEmpty)

