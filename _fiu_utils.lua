--
-- Addon       _fiu_utils.lua
-- Version     0.8
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   13/03/2017
--
-- History     0.2   ADDED:   pack all Junk items in one row
--

local addon, cD = ...
local LOOTFRAME         =  3
local POLECASTBUTTON    =  5

function cD.timedEventsManager()

   local now = Inspect.Time.Frame()
   --
   -- Section rolling Timers - Begin
   --
   --
   -- first run
   --
   if cD.timeRStart == nil then
      cD.timeRStart     = now
      cD.lastTotalTime  = now
   else
      local secs  =  now - cD.timeRStart
      local mins  =  0
      local hour  =  0

      if secs > 1 then
         secs = math.floor(secs)
         while secs  >  60 do
            secs  = secs - 60
            mins = mins + 1
         end
         while mins  >  60 do
            mins  = mins - 60
            hour = hour + 1
         end

         local tSecs = 0
         tSecs =  now - cD.lastTotalTime
         cD.lastTotalTime = now
         cD.time.secs = cD.time.secs + tSecs
         while cD.time.secs  >  60 do
            cD.time.secs  = cD.time.secs - 60
            cD.time.mins = cD.time.mins + 1
         end
         while cD.time.mins  >  60 do
            cD.time.mins  = cD.time.mins - 60
            cD.time.hour = cD.time.hour + 1
         end

         -- Cast Time
         cD.sLThdrs[5]:SetText(string.format("%02d:%02d", mins, secs))

         -- Session Time
         local txt = string.format("%02d:%02d", cD.time.mins, cD.time.secs)
         if cD.time.hour > 0 then txt = cD.time.hour .. ":" .. txt end
         cD.sLThdrs[6]:SetText(txt)

         -- Pole castTimer
         local s = string.format("%02d", secs)
         cD.poleTimer:SetText(s)
      end
   end
   --
   -- Section rolling Timers - End
   --

   if cD.waitingForTheSunRunning == true then
      --
      -- Section WaitingForTheSun - Begin
      --
      -- first run
      if cD.timeStart == nil then
         cD.timeStart = now
      else
         if (now - cD.timeStart) >= cD.time2Wait then

            -- remove handlers
            cD.detachLootWatchers()
            cD.detachOtherWatchers()

            -- we are done, stop timer/flags
            cD.timeStart               =  nil
            cD.waitingForTheSunRunning =  false

            -- hide timer on pole cast Button
            cD.poleTimer:SetVisible(false)
            cD.sLTFrames[POLECASTBUTTON]:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "use" .. " " .. cD.poleTBL.name)

            -- let's update lootTable
            cD.processEventBuffer()

         end
      end
      --
      -- Section WaitingForTheSun - End
      --
   end

   return
end

function cD.processEventBuffer()

   local idx, frame = nil, nil
   for idx, frame in pairs(cD.sLTcntsObjs) do

      -- reset textOBJ background color
      -- from highlighted
      frame:SetBackgroundColor(.2, .2, .2, .5)
   end

   local LASTTIME, LASTOBJ
   local idx, tbl, t, o

   for idx, tbl in pairs(cD.eventBuffer) do

      for t, o in pairs(tbl) do

--          print(string.format("Buffer: t[%s] o[%s]", t, o))

         cD.updateLootTable( o, 1, false )

      end
   end

   cD.eventBuffer = {}

   return
end

function cD.getZoneInfos()
   local zoneText       =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).name
   local zoneID         =  Inspect.Unit.Detail("player").id
   local regionText     =  Inspect.Unit.Detail("player").locationName

   return zoneText, regionText, zoneID
end

function cD.get_totals()
   local totals   =  0
   local val      =  nil

   for _,val in pairs(cD.sLTcnts) do
      totals = totals + val
   end

   return(totals)
end

function cD.updatePercents(totals)
   local key, val =  nil, nil

   for key,val in pairs(cD.sLTcnts) do
      cD.sLTprcnts[key] = val * 100 / totals
      cD.sLTprcntObjs[key]:SetText(string.format("(%d", cD.sLTprcnts[key]).."%)")
   end

   return(totals)
end



function cD.detachLootWatchers()
   Command.Event.Detach(Event.Item.Update,         cD.gotLoot,          "gotLoot")
   Command.Event.Detach(Event.Item.Slot,           cD.gotLoot,          "gotLoot")
   Command.Event.Detach(Event.System.Update.Begin, cD.timedEventsManager, "Event.System.Update.Begin")

   return
end

function cD.detachOtherWatchers()
   Command.Event.Detach(Event.Unit.Detail.Combat,  cD.stopFishingEvent, "Player in Combat")
   Command.Event.Detach(Event.Unit.Castbar,        cD.gotCastBar,       "Player is Casting")

   return
end

function cD.stopFishingEvent(h, event)

   local k, v = nil, nil
   for k, v in pairs(event) do print(string.format("Stop EVENT: k[%s] v[%s]", k, v)) end

   cD.detachLootWatchers()
   cD.detachOtherWatchers()

   -- hide timer on pole casting Button
   cD.poleTimer:SetVisible(false)

   return
end

function cD.gotCastBar(_, info)

   local playerID, eventTBL = nil, nil

   for playerID, eventTBL in pairs(info) do

      if playerID ~= nil then

         local castDetails = Inspect.Unit.Castbar(playerID)

         if castDetails ~= nil then

--             print(string.format("cast details [%s]", castDetails))

--             if castDetails.abilityNew ~= nil then
            if castDetails.ability ~= nil then
               local ability = Inspect.Ability.New.Detail(castDetails.ability)

               print "Castbar data ----- ABILITY begin"
               for kk, vv in pairs(ability) do
                  print(string.format("ability kk[%s] vv[%s]", kk, vv))
               end
               --                print "Castbar data ----- ABILITY end"
            else
               --                print "Castbar data ----- EVENT begin"
--                for kk, vv in pairs(castDetails) do
--                   print(string.format("ability kk[%s] vv[%s]", kk, vv))
--                end
--                --                print "Castbar data ----- EVENT end"
            end
         else
--             print("CASTBAR EVENT: castDetails is nil, we wait for the sun.")

            Command.Event.Attach(Event.Item.Update,               cD.gotLoot,          "gotLoot")
            Command.Event.Attach(Event.Item.Slot,                 cD.gotLoot,          "gotLoot")

            if not cD.waitingForTheSunRunning then
               cD.waitingForTheSunRunning =  true
            end
         end
      end
   end
   --    print "Castbar data ----- end"

   return

end

function cD.updateLootTable(lootOBJ, lootCount, fromHistory)

   if lootCount   == nil   then  lootCount   = 1      end
   if fromHistory == nil   then  fromHistory = false  end

   local retval      =  false
   local idx         =  false
   local isJunk      =  false
   local itemID      =  nil
   local itemName    =  nil
   local itemRarity  =  nil
   local itemDesc    =  nil
   local itemCategory=  nil
   local itemiCon    =  nil

   --
   -- Manage History and Update itemsCache
   --
   if fromHistory == true then
      itemID      =  cD.itemCache[lootOBJ].id
      itemName    =  cD.itemCache[lootOBJ].name
      itemRarity  =  cD.itemCache[lootOBJ].rarity
      itemDesc    =  cD.itemCache[lootOBJ].description
      itemCategory=  cD.itemCache[lootOBJ].category
      itemiCon    =  cD.itemCache[lootOBJ].icon
   else
      itemID      =  Inspect.Item.Detail(lootOBJ).id
      itemName    =  Inspect.Item.Detail(lootOBJ).name
      itemRarity  =  Inspect.Item.Detail(lootOBJ).rarity
      itemDesc    =  Inspect.Item.Detail(lootOBJ).description
      itemCategory=  Inspect.Item.Detail(lootOBJ).category
      itemIcon    =  Inspect.Item.Detail(lootOBJ).icon

      if cD.itemCache[lootOBJ]   == nil then
         cD.itemCache[lootOBJ]   =  { id=itemID, name=itemName, rarity=itemRarity, description=itemDesc, category=itemCategory, icon=itemIcon }
      end
   end


   if itemID ~= nil and itemID ~= false then
      local key = nil
      local val = nil
      local idx = nil
      --
      -- is it Junk ("sellable)? if so we pack it
      --
      if itemRarity  == "sellable" then
         if cD.junkOBJ == nil then
            cD.junkOBJ  =  lootOBJ
         else
            lootOBJ     =  cD.junkOBJ
            itemID      =  cD.itemCache[lootOBJ].id
            itemName    =  cD.itemCache[lootOBJ].name
            itemRarity  =  cD.itemCache[lootOBJ].rarity
            itemDesc    =  cD.itemCache[lootOBJ].description
            itemCategory=  cD.itemCache[lootOBJ].category
            itemiCon    =  cD.itemCache[lootOBJ].icon
         end
      end

      -- is it already in lootTable?
      -- search by itemID
      for key, val in pairs(cD.sLTids) do
         if val == itemID then
            idx = key
         end
      end

      if not idx then
         -- search by itemName
         for key, val in pairs(cD.sLTnames) do
            if val == itemName then
               idx = key
               print(string.format("ITEM MATCH by NAME: _ITEM [%s][%s]", itemID,itemName))
               print(string.format("ITEM MATCH by NAME: MATCH [%s][%s]", cD.sLTids[idx], cD.sLTnames[idx]))
            end
         end
      end


      if idx then
         --
         -- OLD - we update
         --
         cD.sLTcnts[idx]   =  cD.sLTcnts[idx] + lootCount
         cD.sLTcntsObjs[idx]:SetText(string.format("%3d", cD.sLTcnts[idx]))
         cD.updatePercents(cD.get_totals())

         if not fromHistory then cD.sLTcntsObjs[idx]:SetBackgroundColor(.6, .6, .6, .5) end

      else
         --
         -- NEW - we create
         --
         local lineOBJ, lootFrame, lootCnt, prcntCnt =  cD.createLootLine(cD.sLTFrames[LOOTFRAME], lootCount, lootOBJ, fromHistory)

         -- highlight last created row
         if not fromHistory then lootCnt:SetBackgroundColor(.6, .6, .6, .5) end

         table.insert(cD.sLTids,       itemID)
         table.insert(cD.sLTnames,     itemName)
         table.insert(cD.sLTcnts,      lootCount)
         table.insert(cD.sLTtextObjs,  lineOBJ )
         table.insert(cD.sLTfullObjs,  lootFrame )
         table.insert(cD.sLTcntsObjs,  lootCnt )
         table.insert(cD.sLTprcntObjs, prcntCnt )
         table.insert(cD.sLTrarity,    cD.getItemNumericRarity(itemRarity))

         cD.updatePercents(cD.get_totals())

         cD.sortLootTable(cD.sLTFrames[LOOTFRAME])

         retval	=	true
      end

      --
      -- Adjust Totals Header
      --
      local totN  =  cD.get_totals()
--       local totS  =  string.format("Totals : %5d", totN)
      local totS  =  string.format("%5d", totN)
      cD.sLThdrs[4]:SetText(totS)
      cD.timeRStart  =  nil
      --
      -- Adjust Waterlog Totals
      --
      if fromHistory == false then
         local zoneOBJ  =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
         cD.updateHistory(zoneOBJ, lootOBJ, lootCount)
      end
      --
      --
      --
   else
      print("ERROR in updateLootTable, lootOBJ.id is nil")
   end

   if not cD.window.lootObj:GetVisible() then cD.window.lootObj:SetVisible(true) end

   return retval
end


function cD.gotLoot(h, eventTable)
   local itemName = "n/a"
   local itemOBJ  =  nil
   local slot     =  nil

   if eventTable ~= nil then
      for slot, itemOBJ in pairs(eventTable) do
         if itemOBJ ~= nil and itemOBJ ~= false then
            itemName = Inspect.Item.Detail(itemOBJ).name
            --
            -- When a Lure expires the Pole itself triggers an
            -- event that we need to ignore
            --
            if itemName ~= cD.poleTBL.name then
               local now = Inspect.Time.Frame()
               table.insert( cD.eventBuffer, { [now] = itemOBJ } )

               --
               -- we will wait 1 more second (cD.time2Wait=1) Event.Item.Update and
               -- Event.Item.Slot to trigger for multiple fishing catches to be detected.
               --
               if not cD.waitingForTheSunRunning then
                  cD.waitingForTheSunRunning =  true
               end
            end
         else
            --             print("Skipping event, for slot ["..slot.."]")
            -- [sqst.006]
         end
      end
   else
      print("ERROR in gotLoot, eventable is empty")
   end
end

function cD.updateGuiCoordinates(win, newX, newY)
   if win ~= nil then
      if win:GetName() == "Button" then
         cD.window.buttonX =  newX
         cD.window.buttonY =  newY
      end
      if win:GetName() == "Info" then
         cD.window.infoX   =  newX
         cD.window.infoY   =  newY
      end
      if win:GetName() == "Loot" then
         cD.window.lootX   =  newX
         cD.window.lootY   =  newY
      end
      if win:GetName() == "Totals" then
         cD.window.totalsX =  newX
         cD.window.totalsY =  newY
      end
   end

   return
end

function cD.round(num, digits)
   local floor = math.floor
   local mult = 10^(digits or 0)
   return floor(num * mult + .5) / mult
end

function cD.rarityColor(rarityName)
   ret = {}
   if        rarityName == "sellable"  then ret.r = .34375; ret.g = .34375; ret.b = .34375;
      elseif rarityName == "common"    then ret.r = .98;    ret.g = .98     ret.b = .98;
      elseif rarityName == "uncommon"  then ret.r = 0;      ret.g = .797;   ret.b = 0;
      elseif rarityName == "rare"      then ret.r = .148;   ret.g = .496;   ret.b = .977;
      elseif rarityName == "epic"      then ret.r = .676;   ret.g = .281;   ret.b = .98;
      elseif rarityName == "quest"     then ret.r = 1;      ret.g = 1;      ret.b = 0;
      elseif rarityName == "relic"     then ret.r = 1;      ret.g = .5;     ret.b = 0;
      else                                  ret.r = .98;    ret.g = .98     ret.b = .98;
   end
   return ret
end

function cD.categoryIcon(categoryName, objID, desc)
   local retval   =  nil
--    if desc ~= nil then print(string.format("DESC [%s]", desc)) end
   if       string.find( categoryName, "artifact" ) ~= nil then   retval = "Minion_I3C.dds"                          -- artifact icon
   elseif   string.find( categoryName, "quest")     ~= nil then   retval = "icon_menu_quest.png.dds"                 -- exclamation point
   elseif   string.find( categoryName, "dimension") ~= nil then   retval = "Minion_I153.dds"                         -- little key
   elseif   desc and string.find(desc, "exchange")  ~= nil then   retval = "NPCDialogIcon_questrepeatable.png.dds"   -- quest repeatable
   end
  return retval
end
