------------------------------------------
--           GMOD Cloud (c) 2020        --
------------------------------------------

-- Server-sided script, so don't load anything for clients
if (CLIENT) then return end


GmodCloud = GmodCloud or {}

include("sv_config.lua")
include("gmodcloud/sv_base.lua")
include("gmodcloud/sv_helpers.lua")
include("gmodcloud/sv_init.lua")

GmodCloud:PrintInfo("Plugin Loaded")