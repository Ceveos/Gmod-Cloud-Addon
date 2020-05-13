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
local GMODCLOUD_DARKRP_LOADER = "GMODCLOUD_DARKRP_LOADER"

------------------------------------------
--                 Hooks                --
------------------------------------------
local function loadDarkRPEvents()
  GmodCloud:PrintInfo("Loading DarkRP Events");

  hook.Add("playerArrested", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, time, actor)
    GmodCloud:CaptureEvent("playerArrested", {
      criminal = criminal:SteamID(),
      time = time,
      actor = actor:SteamID()
    })
  end)

  hook.Add("lockpickStarted", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, trace)
    GmodCloud:CaptureEvent("lockpickStarted", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:ClassName()
    })
  end)

  hook.Add("lotteryStarted", GMODCLOUD_EVENT_RECORDER, 
  function(ply, price)
    GmodCloud:CaptureEvent("lotteryStarted", {
      steamId = ply:SteamID(),
      price = price
    })
  end)

  hook.Add("lotteryEnded", GMODCLOUD_EVENT_RECORDER, 
  function(participants, ply, amt)
    GmodCloud:CaptureEvent("lotteryEnded", {
      steamId = ply:SteamID(),
      amount = amt
    })
  end)

  hook.Add("onDarkRPWeaponDropped", GMODCLOUD_EVENT_RECORDER, 
  function(ply, spawned_weapon, original_weapon)
    GmodCloud:CaptureEvent("onDarkRPWeaponDropped", {
      steamId = ply:SteamID(),
      weapon = original_weapon:GetClass() 
    })
  end)

  hook.Add("onDoorRamUsed", GMODCLOUD_EVENT_RECORDER, 
  function(success, ply, trace)
    GmodCloud:CaptureEvent("onDoorRamUsed", {
      steamId = ply:SteamID(),
      success = success 
    })
  end)

  hook.Add("onHitAccepted", GMODCLOUD_EVENT_RECORDER, 
  function(hitman, target, customer)
    GmodCloud:CaptureEvent("onHitAccepted", {
      hitman = hitman:SteamID(),
      target = target:SteamID(),
      customer = customer:SteamID()
    })
  end)

  hook.Add("onHitCompleted", GMODCLOUD_EVENT_RECORDER, 
  function(hitman, target, customer)
    GmodCloud:CaptureEvent("onHitCompleted", {
      hitman = hitman:SteamID(),
      target = target:SteamID(),
      customer = customer:SteamID()
    })
  end)

  hook.Add("onHitFailed", GMODCLOUD_EVENT_RECORDER, 
  function(hitman, target, reason)
    GmodCloud:CaptureEvent("onHitFailed", {
      hitman = hitman:SteamID(),
      target = target:SteamID(),
      reason = reason
    })
  end)

  hook.Add("onNotify", GMODCLOUD_EVENT_RECORDER, 
  function(ply, msgType, msgLen, message)
    GmodCloud:CaptureEvent("onNotify", {
      steamId = ply:SteamID(),
      message = message
    })
  end)

  hook.Add("onPaidTax", GMODCLOUD_EVENT_RECORDER, 
  function(ply, tax, wallet)
    GmodCloud:CaptureEvent("onPaidTax", {
      steamId = ply:SteamID(),
      tax = tax,
      wallet = wallet
    })
  end)

  hook.Add("onPlayerChangedName", GMODCLOUD_EVENT_RECORDER, 
  function(ply, oldName, newName)
    GmodCloud:CaptureEvent("onPlayerChangedName", {
      steamId = ply:SteamID(),
      oldName = oldName,
      newName = newName
    })
  end)

  hook.Add("OnPlayerChangedTeam", GMODCLOUD_EVENT_RECORDER, 
  function(ply, oldTeam, newTeam)
    GmodCloud:CaptureEvent("OnPlayerChangedTeam", {
      steamId = ply:SteamID(),
      oldTeam = oldTeam,
      newTeam = newTeam
    })
  end)

  hook.Add("onPlayerDemoted", GMODCLOUD_EVENT_RECORDER, 
  function(source, target, reason)
    GmodCloud:CaptureEvent("onPlayerDemoted", {
      source = source:SteamID(),
      target = target:SteamID(),
      reason = reason
    })
  end)

  hook.Add("onPlayerFirstJoined", GMODCLOUD_EVENT_RECORDER, 
  function(ply, data)
    GmodCloud:CaptureEvent("onPlayerFirstJoined", {
      steamId = ply:SteamID()
    })
  end)

  hook.Add("onPocketItemAdded", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, serialized)
    GmodCloud:CaptureEvent("onPocketItemAdded", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass()
    })
  end)

  hook.Add("onPocketItemDropped", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, item, id)
    GmodCloud:CaptureEvent("onPocketItemDropped", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass()
    })
  end)

  hook.Add("onPropertyTax", GMODCLOUD_EVENT_RECORDER, 
  function(ply, tax, couldAfford)
    GmodCloud:CaptureEvent("onPropertyTax", {
      steamId = ply:SteamID(),
      tax = tax,
      couldAfford = couldAfford
    })
  end)

  hook.Add("playerAdverted", GMODCLOUD_EVENT_RECORDER, 
  function(ply, advert, ent)
    GmodCloud:CaptureEvent("playerAdverted", {
      steamId = ply:SteamID(),
      advert = advert
    })
  end)

  hook.Add("playerBoughtCustomEntity", GMODCLOUD_EVENT_RECORDER, 
  function(ply, entTable, ent, price)
    GmodCloud:CaptureEvent("playerBoughtCustomEntity", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass(),
      price = price
    })
  end)

  hook.Add("playerBoughtCustomVehicle", GMODCLOUD_EVENT_RECORDER, 
  function(ply, vehTable, ent, price)
    GmodCloud:CaptureEvent("playerBoughtCustomVehicle", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass(),
      price = price
    })
  end)

  hook.Add("playerBoughtDoor", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, cost)
    GmodCloud:CaptureEvent("playerBoughtDoor", {
      steamId = ply:SteamID(),
      cost = cost
    })
  end)

  hook.Add("playerBoughtFood", GMODCLOUD_EVENT_RECORDER, 
  function(ply, food, spawnedFood, cost)
    GmodCloud:CaptureEvent("playerBoughtFood", {
      steamId = ply:SteamID(),
      cost = cost,
      food = spawnedFood and spawnedFood:IsValid() and spawnedFood:GetClass()
    })
  end)

  hook.Add("playerBoughtPistol", GMODCLOUD_EVENT_RECORDER, 
  function(ply, wepTable, weapon, price)
    GmodCloud:CaptureEvent("playerBoughtPistol", {
      steamId = ply:SteamID(),
      weapon = weapon and weapon:IsValid() and weapon:GetClass(),
      price = price
    })
  end)

  hook.Add("playerBoughtShipment", GMODCLOUD_EVENT_RECORDER, 
  function(ply, shipTable, ent, price)
    GmodCloud:CaptureEvent("playerBoughtShipment", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass(),
      price = price
    })
  end)

  hook.Add("playerBoughtVehicle", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, price)
    GmodCloud:CaptureEvent("playerBoughtVehicle", {
      steamId = ply:SteamID(),
      entity = ent and ent:IsValid() and ent:GetClass(),
      price = price
    })
  end)

  hook.Add("playerDroppedCheque", GMODCLOUD_EVENT_RECORDER, 
  function(ply, plyTo, amt, ent)
    GmodCloud:CaptureEvent("playerDroppedCheque", {
      source = ply:SteamID(),
      target = plyTo:SteamID(),
      amount = amt
    })
  end)

  hook.Add("playerDroppedMoney", GMODCLOUD_EVENT_RECORDER, 
  function(ply, amt, ent)
    GmodCloud:CaptureEvent("playerDroppedMoney", {
      steamId = ply:SteamID(),
      amount = amt
    })
  end)

  hook.Add("playerEnteredLottery", GMODCLOUD_EVENT_RECORDER, 
  function(ply, amt, ent)
    GmodCloud:CaptureEvent("playerEnteredLottery", {
      steamId = ply:SteamID()
    })
  end)

  hook.Add("playerGaveMoney", GMODCLOUD_EVENT_RECORDER, 
  function(source, target, amt)
    GmodCloud:CaptureEvent("playerGaveMoney", {
      source = source:SteamID(),
      target = target:SteamID(),
      amount = amt
    })
  end)

  hook.Add("playerGetSalary", GMODCLOUD_EVENT_RECORDER, 
  function(ply, amt)
    GmodCloud:CaptureEvent("playerGetSalary", {
      ply = ply:SteamID(),
      amount = amt
    })
  end)

  hook.Add("playerKeysSold", GMODCLOUD_EVENT_RECORDER, 
  function(ply, ent, refund)
    GmodCloud:CaptureEvent("playerKeysSold", {
      ply = ply:SteamID(),
      refund = refund
    })
  end)

  hook.Add("playerPickedUpCheque", GMODCLOUD_EVENT_RECORDER, 
  function(source, target, amt, success, ent)
    GmodCloud:CaptureEvent("playerPickedUpCheque", {
      source = source:SteamID(),
      target = target:SteamID(),
      amount = amt,
      success = success
    })
  end)

  hook.Add("playerPickedUpMoney", GMODCLOUD_EVENT_RECORDER, 
  function(ply, amt, ent)
    GmodCloud:CaptureEvent("playerPickedUpMoney", {
      ply = ply:SteamID(),
      amount = amt
    })
  end)

  hook.Add("PlayerPickupDarkRPWeapon", GMODCLOUD_EVENT_RECORDER, 
  function(ply, spawned_weapon, real_weapon)
    GmodCloud:CaptureEvent("PlayerPickupDarkRPWeapon", {
      ply = ply:SteamID(),
      weapon = real_weapon:GetClass()
    })
  end)

  hook.Add("playerSetAFK", GMODCLOUD_EVENT_RECORDER, 
  function(ply, afk)
    GmodCloud:CaptureEvent("playerSetAFK", {
      ply = ply:SteamID(),
      afk = afk
    })
  end)

  hook.Add("playerStarved", GMODCLOUD_EVENT_RECORDER, 
  function(ply)
    GmodCloud:CaptureEvent("playerStarved", {
      ply = ply:SteamID()
    })
  end)

  hook.Add("playerToreUpCheque", GMODCLOUD_EVENT_RECORDER, 
  function(source, target, amt)
    GmodCloud:CaptureEvent("playerToreUpCheque", {
      source = source:SteamID(),
      target = target:SteamID(),
      amount = amt
    })
  end)

  hook.Add("playerUnArrested", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, actor)
    GmodCloud:CaptureEvent("playerUnArrested", {
      criminal = criminal:SteamID(),
      actor = actor:SteamID()
    })
  end)

  hook.Add("playerUnWanted", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, actor)
    GmodCloud:CaptureEvent("playerUnWanted", {
      criminal = criminal:SteamID(),
      actor = actor:SteamID()
    })
  end)

  hook.Add("playerUnWarranted", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, actor)
    GmodCloud:CaptureEvent("playerUnWarranted", {
      criminal = criminal:SteamID(),
      actor = actor:SteamID()
    })
  end)

  hook.Add("playerWalletChanged", GMODCLOUD_EVENT_RECORDER, 
  function(ply, amt, wallet)
    GmodCloud:CaptureEvent("playerWalletChanged", {
      steamId = ply:SteamID(),
      amount = amt,
      wallet = wallet
    })
  end)

  hook.Add("playerWanted", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, actor, reason)
    GmodCloud:CaptureEvent("playerWanted", {
      criminal = criminal:SteamID(),
      actor = actor:SteamID(),
      reason = reason
    })
  end)

  hook.Add("playerWarranted", GMODCLOUD_EVENT_RECORDER, 
  function(criminal, actor, reason)
    GmodCloud:CaptureEvent("playerWarranted", {
      criminal = criminal:SteamID(),
      actor = actor:SteamID(),
      reason = reason
    })
  end)

  hook.Add("playerWeaponsChecked", GMODCLOUD_EVENT_RECORDER, 
  function(checker, target, weapons)
    GmodCloud:CaptureEvent("playerWeaponsChecked", {
      checker = checker:SteamID(),
      target = target:SteamID()
    })
  end)

  hook.Add("playerWeaponsConfiscated", GMODCLOUD_EVENT_RECORDER, 
  function(checker, target, weapons)
    GmodCloud:CaptureEvent("playerWeaponsConfiscated", {
      checker = checker:SteamID(),
      target = target:SteamID()
    })
  end)

  hook.Add("playerWeaponsReturned", GMODCLOUD_EVENT_RECORDER, 
  function(checker, target, weapons)
    GmodCloud:CaptureEvent("playerWeaponsReturned", {
      checker = checker:SteamID(),
      target = target:SteamID()
    })
  end)
end

hook.Add("DarkRPStartedLoading", GMODCLOUD_DARKRP_LOADER, loadDarkRPEvents)
