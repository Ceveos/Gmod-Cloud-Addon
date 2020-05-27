
local GMODCLOUD_WEB_CHAT_MESSAGE = "GMODCLOUD_WEB_CHAT_MESSAGE"

-- Colors
local red = Color(255,0,0)
local green = Color(0,255,0)
local lightblue = Color(137,222,255)
local blue = Color(0,0,255)
local yellow = Color(255,255,0)
local gray = Color(128,128,128)
local white = Color(255,255,255)

net.Receive( GMODCLOUD_WEB_CHAT_MESSAGE, function()
  local name = net.ReadString()
  local message = net.ReadString()
  chat.AddText(green, name, lightblue, " (Web)", white, ": ", message)
end)