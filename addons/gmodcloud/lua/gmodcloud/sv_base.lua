---------------------------------------------------
--             GMOD Cloud (c) 2020               --
---------------------------------------------------
--                                               --
-- This file contains the base functions used    -- 
-- throughout the program. sv_helpers.lua will   --
-- contain functions that build on top of these  --
--                                               --
---------------------------------------------------

------------------------------------------
--               CONSTANTS              --
------------------------------------------

-- Data directory
local BASEDIRECTORY = "gmodcloud/"
local QUEUEDIRECTORY = "queue/"

local dataDirectories = {
  BASEDIRECTORY,
  BASEDIRECTORY .. QUEUEDIRECTORY
}

-- Server info
local baseApiUrl = "https://gmodcloud.com/api/"

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

function GmodCloud:BaseDirectory() 
  return BASEDIRECTORY
end

function GmodCloud:QueueDirectory() 
  return BASEDIRECTORY .. QUEUEDIRECTORY
end

function GmodCloud:FilesInDirectory(path) 
  return file.Find(path .. "*", "DATA", "nameasc")
end

function GmodCloud:FileExists(filename, path) 
  return file.Exists(path .. filename, "DATA")
end

function GmodCloud:DeleteFile(filename, path)
  return file.Delete(path .. filename)
end

function GmodCloud:ReadFile(filename, path) 
  return file.Read(path .. filename, "DATA")
end

function GmodCloud:WriteFile(filename, content, path)
  -- Create all required directories
  for i, directory in ipairs(dataDirectories) do
    if !file.Exists(directory, "DATA") then
      file.CreateDir(directory)
    end
  end

  -- Write file
  file.Write(path .. filename, content) 
end

------------------------------------------
--             HTTP FUNCTIONS           --
------------------------------------------

------------------------
--  Perform Callback  --
------------------------
-- After a HTTP Fetch or Post, a callback is performed
-- Params:
-- Message:  Used for TRACE printing in console. Helps identify errors if one should arise.
--           Try to come up with symbolic names. i.e. "[FETCH] [FAIL]". You can immediately 
--           tell that the callback is from a failed FETCH request.             
--
-- Callback: Can be a function or a hook
-- 
-- Result:   Result of the HTTP FETCH/POST. It should be a table with at least the following properties: 
--           - error: bool - Was there an error performing the fetch/post
--           - errorMsg: String - If there was an error, why? (Req. only if error is true)
--
function GmodCloud:PerformCallback(message, callback, result) 
  local decodedResult = {}
  if result and type(result) == "string" then
    GmodCloud:Print("[HTTP RESPONSE] Callback Result: " .. result)
    decodedResult = util.JSONToTable(result)
  else
    GmodCloud:PrintWarning("[HTTP RESPONSE] JSON String expected, got " .. type(result))
    decodedResult = result
  end

  if callback and type(callback) == "string" then 
    GmodCloud:Print(message .. " Calling hook: " .. callback)
    hook.Run(callback, decodedResult)
  elseif callback and type(callback) == "function" then
    GmodCloud:Print(message .. " Calling function")
    callback(decodedResult)
  else
    GmodCloud:PrintError(message .. " Unknown type: " .. type(callback))
  end
end


------------------
--  Fetch Data  --
------------------
-- send a fetch request to Gmod Cloud's API server
-- Will run a hook or function as a callback
--
-- Params:
--
-- path:    API path that you're trying to target. The base url is already defined
--          so the path should be something like "server/update"
--
-- success: Success Callback. Refer to GmodCloud:PerformCallback for more information
--
-- fail:    Fail callback. Refer to GmodCloud:PerformCallback for more information
function GmodCloud:FetchData(path, success, fail) 
  -- Get complete url
  local completeUrl = baseApiUrl .. path
  GmodCloud:Print("[FETCH] Querying " .. completeUrl)
  
  -- Perform fetch
  http.Fetch(completeUrl, function(result)
    GmodCloud:PerformCallback("[FETCH] [SUCCESS]", success, result) 
  end, function(result)
    GmodCloud:PerformCallback("[FETCH] [FAIL]", fail, result) 
  end)
end

-----------------
--  Post Data  --
-----------------
-- send a POST request to Gmod Cloud's API server.
-- Will run a hook or function as a callback.
--
-- Params:
--
-- path:    API path that you're trying to target. The base url is already defined
--          so the path should be something like "server/update"
--
-- params:  Params is the data you want to include with the post request. Expected to 
--          be a 1-level deep table (no tables within tables). The only exception is
--          the optional "Attributes" field, which is expected to be a table.
--
-- success: Success Callback. Refer to GmodCloud:PerformCallback for more information
--
-- fail:    Fail callback. Refer to GmodCloud:PerformCallback for more information
function GmodCloud:PostData(path, params, success, fail) 
  -- Get complete url
  local completeUrl = baseApiUrl .. path
  
  GmodCloud:Print("[POST] Querying " .. completeUrl)

  -- Perform post request
  http.Post(completeUrl, params, function(result)
    GmodCloud:PerformCallback("[POST] [SUCCESS]", success, result) 
  end, function(result)
    GmodCloud:PerformCallback("[POST] [FAIL]", fail, result) 
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
