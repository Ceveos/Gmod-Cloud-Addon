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
  return GmodCloud:FileExists("server.json")
end

function GmodCloud:GetServerInfo() 
  -- Use a var to save us from constantly reading a file
  if serverInfoExists == nil then
    serverInfoExists = GmodCloud:ServerInfoExists() 
  end

  if (serverInfo == nil and serverInfoExists) then
    serverInfo = util.JSONToTable(GmodCloud:ReadFile("server.json"))
    return serverInfo
  end

  return nil
end

function GmodCloud:SetServerInfo(serverId, secretKey) 
  return GmodCloud:WriteFile("server.json", 
    util.TableToJSON(
      {
        serverId =  serverId,
        secretKey = secretKey
      }
    ))
end

------------------------------------------
--             HTTP FUNCTIONS           --
------------------------------------------

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

  GmodCloud:PostData("server/ping/" .. serverInfo.serverId, postArgs, success, fail)
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
