
-- Default vars 
GmodCloud.DebugLevel = GmodCloud.DebugLevel or 1

-- Colors
local red = Color(255,0,0)
local green = Color(0,255,0)
local lightblue = Color(137,222,255)
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
