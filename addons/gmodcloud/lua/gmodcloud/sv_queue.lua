-----------------------------------------------------
--              GMOD Cloud (c) 2020                --
-----------------------------------------------------
--                                                 --
-- This file contains the queue module that is     --
-- responsible for uploading data to GmodCloud.    --
-- It will ensure that multiple requests aren't    --
-- fired at once, keeping the network and server   --
-- stable.                                         --
--                                                 --
-----------------------------------------------------

---------------------------------------
--             Constants             --
---------------------------------------
local GMODCLOUD_INIT_COMPLETED = "GMODCLOUD_INIT_COMPLETED"
local GMODCLOUD_QUEUE_SUCCESS = "GMODCLOUD_QUEUE_SUCCESS"
local GMODCLOUD_QUEUE_FAIL = "GMODCLOUD_QUEUE_FAIL"
local GMODCLOUD_QUEUE = "GMODCLOUD_QUEUE"
local GMODCLOUD_RUN_QUEUE = "GMODCLOUD_RUN_QUEUE"

---------------------------------------
--             local var             --
---------------------------------------
local midQueue = false
local lastFile = nil

---------------------------------------
--            Queue Logic            --
---------------------------------------

local function onQueuePostSuccess (result)
  GmodCloud:Print("Successfully performed queued action")
  GmodCloud:DeleteFile(lastFile, GmodCloud:QueueDirectory())
  midQueue = false
  lastFile = nil

  -- If there are no players on, keep chugging through requests
  if player.GetCount() == 0 and !GmodCloud:IsQueueEmpty() then
    QueueTimerElapsed()
  end
end

local function onQueuePostFail (result)
  GmodCloud:Print("Failed to performed queued action")
  midQueue = false

  -- If there are no players on, keep chugging through requests
  if player.GetCount() == 0 and !GmodCloud:IsQueueEmpty() then
    QueueTimerElapsed()
  end
end

local function QueueTimerElapsed()
  if GmodCloud:IsQueueEmpty() or midQueue == true then
    return
  end

  local fileToSend = GmodCloud:GrabQueuedFile()
  local content = util.JSONToTable(GmodCloud:ReadFile(fileToSend, GmodCloud:QueueDirectory()))
  
  midQueue = true
  lastFile = fileToSend

  -- Attempt to POST data
  GmodCloud:PostData(content.url, util.JSONToTable(content.params), GMODCLOUD_QUEUE_SUCCESS, GMODCLOUD_QUEUE_FAIL) 
end

local function onInitCompleted()
  GmodCloud:Print("Creating Queue timer")
  -- Once we're initialized, start running our queue

  -- Run every 5 seconds
  timer.Create(GMODCLOUD_QUEUE, 5, 0, function() QueueTimerElapsed() end)
end

hook.Add(GMODCLOUD_INIT_COMPLETED, GMODCLOUD_QUEUE, onInitCompleted)
hook.Add(GMODCLOUD_RUN_QUEUE, GMODCLOUD_QUEUE, QueueTimerElapsed)

hook.Add(GMODCLOUD_QUEUE_SUCCESS, GMODCLOUD_QUEUE, onQueuePostSuccess)
hook.Add(GMODCLOUD_QUEUE_FAIL, GMODCLOUD_QUEUE, onQueuePostSuccess)