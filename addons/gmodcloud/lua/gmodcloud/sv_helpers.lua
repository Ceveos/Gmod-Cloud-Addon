-----------------------------------------------------
--              GMOD Cloud (c) 2020                --
-----------------------------------------------------
--                                                 --
-- This file contains functions that is used to    --
-- help perform routine tasks. The functions build --
-- on top of what was defined in sv_base.lua       --
--                                                 --
-----------------------------------------------------

------------------------------------------
--               CONSTANTS              --
------------------------------------------

-- Server Info
local serverInfo = nil -- Contains Server ID and Secret Key for API communication
local serverInfoExists = nil -- Does server info exists? Variable exists for optimization (less file reads) 

------------------------------------------
--           PUBLIC FUNCTIONS           --
------------------------------------------
--             DATA FUNCTIONS           --
------------------------------------------

function GmodCloud:ServerInfoExists()
  return GmodCloud:FileExists("server.json", GmodCloud:BaseDirectory())
end

function GmodCloud:GetServerInfo() 
  -- Use a var to save us from constantly reading a file
  if serverInfoExists == nil then
    serverInfoExists = GmodCloud:ServerInfoExists() 
  end

  if (serverInfo == nil and serverInfoExists) then
    serverInfo = util.JSONToTable(GmodCloud:ReadFile("server.json", GmodCloud:BaseDirectory()))
    return serverInfo
  end
  if (serverInfo != nil and serverInfoExists) then
    return serverInfo
  else
    return nil
  end
end

function GmodCloud:SetServerInfo(serverId, secretKey) 
  return GmodCloud:WriteFile("server.json", 
    util.TableToJSON(
      {
        serverId =  serverId,
        secretKey = secretKey
      }
    ), GmodCloud:BaseDirectory())
end

------------------------------------------
--             HTTP FUNCTIONS           --
------------------------------------------

-- Queueing data for send will manage data that needs to be sent to GModCloud.
-- This will help solve a few potential problems:
-- - Spamming the network: By using a queue, we can ensure that data goes orderly to Gmod Cloud
--                         without spamming the network at one point in time (causing server lag/potential failures)
-- 
-- - Retryability: Other functions can queue data without having to worry if the request failed. Queue Data will
--                 manage the data it needs to send, and ensures that they're all successful. It will even write
--                 the request in a file to survive server restarts. 
function GmodCloud:QueueDataForSend(url, params)
  -- Use the timestamp to name files that need to be sent
  local curTime = os.time()
  
  -- In-case we have back-to-back requests, there is a chance two requests will have the
  -- same timestamp. Ensure we have a unique fle name.
  while GmodCloud:FileExists(curTime .. ".json", GmodCloud:QueueDirectory()) do
    curTime = curTime + 1
  end

  -- Write our request to a JSON file
  GmodCloud:WriteFile(curTime .. ".json", 
    util.TableToJSON(
      {
        url = url,
        params = util.TableToJSON(params)
      }
    ), GmodCloud:QueueDirectory())
end

function GmodCloud:IsQueueEmpty()
  return #GmodCloud:FilesInDirectory(GmodCloud:QueueDirectory()) == 0
end

function GmodCloud:GrabQueuedFile()
  local files = GmodCloud:FilesInDirectory(GmodCloud:QueueDirectory())
  if files != nil then
    return files[1]
  end
  return nil
end

-- Send an updated state of the server to GmodCloud
-- Pre-req: Server must have already been registered
-- Params:
-- - logName: There are multiple different types of logs that we can be recording (i.e. player count, events, etc..). 
--            logName is the "log path" we'll be writing to
--
-- - rootFields: The attributes you want to attach to the log, but on the root. Should be a table.
--
-- There is no callback since this should be a fire and forget
function GmodCloud:PostServerLog(logName, rootFields) 
  -- Verify that we have server info
  local serverInfo = GmodCloud:GetServerInfo()
  if serverInfo == nil -- Nil on new servers
     or serverInfo.serverId == nil
     or serverInfo.secretKey == nil then
      
      GmodCloud:PerformCallback("[UPDATE] [FAIL]", fail, {error = true, errorMsg = "Server Info does not exist, or is not complete"})
      return
  end
  rootFields.secretKey = serverInfo.secretKey

  if rootFields.attributes then
    rootFields.attributes = util.TableToJSON(rootFields.attributes)
  end

  GmodCloud:QueueDataForSend("server/" .. serverInfo.serverId .. "/log/" .. logName, rootFields)
end

-- Send an updated state of the server to GmodCloud
-- Pre-req: Server must have already been registered
function GmodCloud:PostServerUpdate(attributes, success, fail) 
  -- Verify that we have server info
  local serverInfo = GmodCloud:GetServerInfo()
  if serverInfo == nil -- Nil on new servers
     or serverInfo.serverId == nil
     or serverInfo.secretKey == nil then
      GmodCloud:PerformCallback("[UPDATE] [FAIL]", fail, {error = true, errorMsg = "Server Info does not exist, or is not complete"})
      return
  end

  local postArgs = {
    attributes = util.TableToJSON(attributes),
    secretKey = serverInfo.secretKey
  }

  GmodCloud:PostData("server/" .. serverInfo.serverId .. "/ping", postArgs, success, fail)
end


-- send a post request to Gmod Cloud's API server
-- On result, run a hook or function
function GmodCloud:RegisterServer(attributes, success, fail) 
  -- Add required attributes
  local postArgs = {
    owner = GmodCloud.ServerInfo.owner or "INVALID",
    apiKey = GmodCloud.ServerInfo.apiKey or "INVALID",
    attributes = util.TableToJSON(attributes)
  }
  
  if GmodCloud:ServerInfoExists() == false then -- Nil on new servers
    GmodCloud:PostData("server/register", postArgs, success, fail)
  else 
    GmodCloud:PerformCallback("[REGISTER] [FAIL]", fail, {error = true, errorMsg = "Server Info exists"})
  end
end


-------------------------------------------------------
-- Why using a hook for a callback on a API request? --
-------------------------------------------------------
-- Allows the addon to be more flexible.
-- If you're pinging the server for updates (i.e. actions to do)
-- Other addons can passively listen for a response 
-- 
-- Examples:
-- * Allows an admin logger to log all (relevant) API response coming from the server
-- * Allows a plugin to know when a certain action is complete and react accordingly
