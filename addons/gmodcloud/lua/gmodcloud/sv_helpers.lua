------------------------------------------
--           GMOD Cloud (c) 2020        --
------------------------------------------

------------------------------------------
--               CONSTANTS              --
------------------------------------------
-- Data directory
local BASEDIRECTORY = "GmodCloud/"

-- Server info
local baseApiUrl = "https://gmodcloud.com/api/"
local serverInfo = nil
local serverInfoExists = nil

-- Colors
local red = Color(255,0,0)
local green = Color(0,255,0)
local blue = Color(0,0,255)
local yellow = Color(255,255,0)
local gray = Color(128,128,128)
local white = Color(255,255,255)

------------------------------------------
--           PUBLIC FUNCTIONS           --
------------------------------------------
--            PRINT FUNCTIONS           --
------------------------------------------
function GmodCloud:Print(message) 
  if (GmodCloud.DebugLevel == 0) then
    MsgC("[GmodCloud] ", gray, "[TRACE] ", message, "\n") -- Not sure why new lines aren't appended at the end of MsgC
  end
end

function GmodCloud:PrintInfo(message) 
  if (GmodCloud.DebugLevel <= 1) then
    MsgC("[GmodCloud] ", blue, "[INFO] ", white, message, "\n")
  end
end

function GmodCloud:PrintSuccess(message)
  if (GmodCloud.DebugLevel <= 1) then
    MsgC("[GmodCloud] ", green, "[SUCCESS] ", white, message, "\n")
  end
end

function GmodCloud:PrintWarning(message)
  if (GmodCloud.DebugLevel <= 2) then
    MsgC("[GmodCloud] ", yellow, "[WARNING] ", message, "\n")
  end
end


function GmodCloud:PrintError(message) 
  if (GmodCloud.DebugLevel <= 3) then
    MsgC("[GmodCloud] ", red, "[ERROR] ", message, "\n")
  end
end


------------------------------------------
--             FILE FUNCTIONS           --
------------------------------------------

function GmodCloud:FileExists(filename) 
  return file.Exists(BASEDIRECTORY .. filename, "DATA")
end

function GmodCloud:ReadFile(filename) 
  return file.Read(BASEDIRECTORY .. filename, "DATA")
end

function GmodCloud:WriteFile(filename, content)
  if !file.Exists(BASEDIRECTORY, "DATA") then
    file.CreateDir(BASEDIRECTORY)
  end

  file.Write(BASEDIRECTORY .. filename, content) 
end

------------------------------------------
--             DATA FUNCTIONS           --
------------------------------------------

function GmodCloud:ServerInfoExists() 
  return GmodCloud:FileExists("server.json")
end

function GmodCloud:GetServerInfo() 
  return util.JSONToTable(GmodCloud:ReadFile("server.json"))
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

-- send a fetch request to Gmod Cloud's API server
-- Will run a hook or function as a callback
function GmodCloud:FetchData(path, success, fail) 
  -- Get complete url
  local completeUrl = baseApiUrl .. path
  GmodCloud:Print("[FETCH] Querying " .. completeUrl)
  
  -- Perform fetch
  http.Fetch(completeUrl, function(result)

    if success and type(success) == "string" then 
      GmodCloud:Print("[FETCH] [SUCCESS] Calling hook: " .. success)
      hook.Run(success, result)
    elseif success and type(success) == "function" then
      GmodCloud:Print("[FETCH] [SUCCESS] Calling function")
      success(result)
    else 
      GmodCloud:Print("[FETCH] [SUCCESS] Unknown success type: " .. type(success))
    end

  end, function(result)

    if fail and type(fail) == "string" then 
      GmodCloud:Print("[FETCH] [FAIL] Calling hook: " .. fail)
      hook.Run(fail, result)
    elseif fail and type(fail) == "function" then
      GmodCloud:Print("[FETCH] [FAIL] Calling function")
      fail(result)
    else
      GmodCloud:Print("[FETCH] [FAIL] Unknown fail type: " .. type(fail))
    end

  end)
end


-- send a post request to Gmod Cloud's API server
-- On result, run a hook or function
function GmodCloud:PostData(path, args, success, fail) 
  -- Add required args
  local postArgs = {
    owner = GmodCloud.ServerInfo.owner or "INVALID",
    apiKey = GmodCloud.ServerInfo.apiKey or "INVALID",
    attributes = util.TableToJSON(args)
  }

  -- Get complete url
  local completeUrl = baseApiUrl .. path
  
  -- Use a var to save us from constantly reading a file
  if serverInfoExists == nil then
    serverInfoExists = GmodCloud:ServerInfoExists() 
  end

  if (serverInfo == nil and serverInfoExists) then
    serverInfo = GmodCloud:GetServerInfo()
  end

  if (serverInfo != nil and serverInfo.serverId != nil and serverInfo.secretKey != nil) then
    postArgs.secretKey = serverInfo.secretKey
    completeUrl = completeUrl .. "/" .. serverInfo.serverId
  end

  GmodCloud:Print("[POST] Querying " .. completeUrl)

  -- Perform post request
  http.Post(completeUrl, postArgs, function(result)
    if success and type(success) == "string" then 
      GmodCloud:Print("[POST] [SUCCESS] Calling hook: " .. success)
      hook.Run(success, result)
    elseif success and type(success) == "function" then
      GmodCloud:Print("[POST] [SUCCESS] Calling function")
      success(result)
    else 
      GmodCloud:Print("[POST] [SUCCESS] Unknown success type: " .. type(success))
    end

  end, function(result)

    if fail and type(fail) == "string" then 
      GmodCloud:Print("[POST] [FAIL] Calling hook: " .. fail)
      hook.Run(fail, result)
    elseif fail and type(fail) == "function" then
      GmodCloud:Print("[POST] [FAIL] Calling function")
      fail(result)
    else
      GmodCloud:Print("[POST] [FAIL] Unknown fail type: " .. type(fail))
    end

  end)
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
