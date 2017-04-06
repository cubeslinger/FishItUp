--
-- Addon       FishItUp.lua
-- Version     0.24.27
-- Author      marcob@marcob.org
-- StartDate   04/02/2017
-- StartDate   09/03/2017
--
-- History     0.21d    bugfix:  using an artifact, while fishing, should not trigger an error anymore.
--             0.22     bugfix:  names longer then windows shoudn't drip out of it anymore.
--                      ADDED:   scrollbar in loot frame, should appear ONLY when more then 9
--                               (elementsToShow=9) items are listed.
--             0.23.1   bugfix:  mask wasn't working correctly.
--             0.23.2   bugfix:  when a lure expires should not add the Fishing Pole to the looted list anymore.
--             0.23.3   ADDED:   /fiu shows AND hides FishItUp! window.
--             0.23.4   bugfix:  it missed multiple catches.
--             0.23.7   bugfix:  again on the scrollbar
--             0.23.8   CHANGE:  Changed the way i detect *ALL* fishing loot without catching loot from other
--                               sources. Look for function waitingForTheSun() and the Utility.Dispatch() used to
--                               let this addon check for Event.Item.Update and Event.Item.Slot for 1 more second
--                               after the first loot has been detected.
--                               This avoids skipping multiple fish catches and permits to to stop loot detection
--                               as soon as possible.
--             0.23.9   bugfix:  changed waitingForTheSun() to avoid slowdowns
--             0.23.10  ADDED:   saves/restores window position.
--             0.23.9   ADDED:   Entering Combat Event detection: to stop watching for loot
--             0.24.2   CHANGE:  -  transparent frame instead RiftWindow
--                               -  modified LibDraggable no move frames and not windows, so i can move it again
--                               -  stopfishing -> castbar
--                               -  stopfishing -> change Zone
--                               -  stopfishing -> change Location
--             0.24.4   CHANGE   -  buttonFrame now is separated from loot window, and save its own coordinates on exit
--                               -  DISABLED:   stopfishing -> castbar
--                               -  DISABLED:   stopfishing -> change Zone
--                               -  DISABLED:   stopfishing -> change Location
--             0.24.5   ADDED    -  Detect Fishing pole Icon
--                               -  CastButton is now the Fishing Poel Icon, click on the "small" border to move it around
--             0.24.6   CHANGE   -  ditched the scroll bar, changed to an expanding loot frame.
--                               -  Header Infos and Loot infos now have different background colors.
--             0.24.14  CHANGE   -  Splitted output in 2 indipendent windows
--                               -  Added Item Icons in loot-Window list
--                               -  Separated Item quantity from Item Names in loot-Window list
--             0.24.16  CHANGE   -  Testing again Event.Castbar, when we get a "nil" event should mean we stop fishing, so
--                                  i trigger waitingForTheSun to catch the last loot and stop fishing.
--                               -  Added some spacing between left border and icon in Loot Window.
--             0.24.20  bugfix:  -  Fixed Time counters
--                               -  Fixed Casts counter
--             0.24.21  ADDED    -  Percent column in loot window
--                               -  Addend some spacing in loot window
--             0.24.25  ADDED    -  Loot Session per Zone saving and reloading
--                               -  Loot Totals by Zone saved
--

local addon, cD = ...

local function doThings(params)
   -- Create Display/Hide infoWindow
   if cD.window.infoOBJ    == nil then
      cD.window.infoOBJ    =  cD.createInfoWindow()
      cD.window.infoOBJ:SetVisible(true)
   else
      cD.window.infoOBJ:SetVisible(not cD.window.infoOBJ:GetVisible())
   end

   -- Create/Display lootWindow
   local filled = false
   if cD.window.lootOBJ    == nil then
      cD.window.lootOBJ    =  cD.createLootWindow()
      filled = cD.loadLastSession()
   end
   if filled then
      cD.window.lootOBJ:SetVisible(cD.window.infoOBJ:GetVisible())
   else
      cD.window.lootOBJ:SetVisible(false)
   end

   -- Create/Display buttonWindow
   if cD.window.buttonOBJ  == nil then
      cD.window.buttonOBJ  =  cD.createButtonWindow()
   end
   cD.window.buttonOBJ:SetVisible(cD.window.infoOBJ:GetVisible())

   -- Create/Display totalsWindow
   if cD.window.totalsOBJ  == nil then
      cD.window.totalsOBJ  =  cD.createTotalsWindow()
      cD.initTotalsWindow()
      cD.window.totalsOBJ:SetVisible(false)
   end
   if cD.window.infoOBJ:GetVisible() == false then cD.window.totalsOBJ:SetVisible(false) end

   -- Create/Display cacheWindow
   if cD.window.cacheOBJ  == nil then
      cD.window.cacheOBJ  =  cD.createCacheWindow()
--       cD.initCacheWindow()
      cD.window.cacheOBJ:SetVisible(false)
   end
   if cD.window.infoOBJ:GetVisible() == false then cD.window.cacheOBJ:SetVisible(false) end

   return
end

cD.addon       =  Inspect.Addon.Detail(Inspect.Addon.Current())["name"]
table.insert(Command.Slash.Register("fiu"), {function (params) doThings(params)   end, cD.addon, "getpole command"})


