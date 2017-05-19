--
-- Addon       _fiu_utils.lua
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
--

local addon, cD = ...
local LOOTFRAME         =  3
local POLECASTBUTTON    =  5


local function updateCharScore(itemID, itemZone, lootCount)

   if cD.charScore[itemZone] then
      local zScore = cD.charScore[itemZone]
      if zScore[itemID] then
         zScore[itemID] = zScore[itemID] + lootCount
      else
         zScore[itemID] =  lootCount
      end
   else
      cD.charScore[itemZone] = { [itemID] = lootCount }
   end

   return
end

function cD.printJunkMoney(money, pad)
   local silver   =  '#c0c0c0'
   local gold     =  '#ffd700'
   local platinum =  '#e5e4e2'
   local white    =  '#ffffff'
   local s        =  money
   local g        =  0
   local p        =  0
   local t        =  ""
   local size     =  0

   if s  == nil   then  s = 0 end
--    print("["..s.."]s")

   if s > 0 then
      while s > 99 do
         s = s -100
         g = g + 1
--          print("  ["..g.."]g ["..s.."]s")
      end

      while g > 99 do
         g = g - 100
         p = p + 1
--          print("   ["..s.."]s["..g.."]g["..p.."]p")
      end
   end

   -- silver
   t = "<font color=\'"..white.."\'>"..tostring(s).."</font><font color=\'"..silver.."\'>s</font>"
   -- gold
   if g > 0 then
      t = "<font color=\'"..white.."\'>"..tostring(g).."</font><font color=\'"..gold.."\'>g</font>"..t
   end
   -- platinum
   if p > 0 then
      t = "<font color=\'"..white.."\'>"..tostring(p).."<font color=\'"..platinum.."\'>p</font>"..t
   end

   return(t)
end

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
--             cD.detachOtherWatchers()

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
   for idx, frame in pairs(cD.sLTcntsOBJs) do

      -- reset textOBJ background color
      -- from highlighted
      frame:SetBackgroundColor(.2, .2, .2, 0)
   end

   local LASTTIME, LASTOBJ
   local idx, tbl, t, o
   local newItemBase  =  cD.scanInventories()

   -- reset InfoWindow Loot IconList
   cD.resetIconsList()

   for idx, tbl in pairs(cD.eventBuffer) do

      for t, o in pairs(tbl) do
--          print(string.format("Buffer: t[%s] o[%s]", t, o))
         local i = Inspect.Item.Detail(o)
--          print(string.format("        [%s]/[%s]", i.stack, i.stackMax))

--          print(string.format("newItemBase[%s]=[%s] - cD.itemBase[%s]=[%s]", i.name, newItemBase[i.name], i.name, cD.itemBase[i.name]))
         local quantity =  (newItemBase[i.name] or 0) - (cD.itemBase[i.name] or 0)
--          print(string.format("newItemBase[%s]=[%s] - cD.itemBase[%s]=[%s]=>(%s)", i.name, newItemBase[i.name], i.name, cD.itemBase[i.name], quantity))

--          cD.updateLootTable( o, 1, false )
         cD.updateLootTable( o, quantity, false )
         cD.updateInfoIcons( o, quantity)

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
      cD.sLTprcntOBJs[key]:SetText(string.format("(%d", cD.sLTprcnts[key]).."%)")
   end

   return(totals)
end



function cD.detachLootWatchers()
   Command.Event.Detach(Event.Item.Update,         cD.gotLoot,             "gotLoot_item_update")
   Command.Event.Detach(Event.Item.Slot,           cD.gotLoot,             "gotLoot_item_slot")
   Command.Event.Detach(Event.System.Update.Begin, cD.timedEventsManager,  "Event.System.Update.Begin")
   Command.Event.Detach(Event.Unit.Castbar,        cD.gotCastBar,          "Player is Casting")

   return
end

function cD.stopFishingEvent(h, event)

   local k, v = nil, nil
   for k, v in pairs(event) do print(string.format("Stop EVENT: k[%s] v[%s]", k, v)) end

   cD.detachLootWatchers()
--    cD.detachOtherWatchers()

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

            Command.Event.Attach(Event.Item.Update,               cD.gotLoot,          "gotLoot_item_update")
            Command.Event.Attach(Event.Item.Slot,                 cD.gotLoot,          "gotLoot_item_slot")

            if not cD.waitingForTheSunRunning then cD.waitingForTheSunRunning =  true end
         end
      end
   end
   --    print "Castbar data ----- end"

   return

end

function cD.updateLootTable(lootOBJ, lootCount, fromHistory)

   -- debug
--    if not fromHistory then
--       local x, y = nil, nil
--       for x,y in pairs(Inspect.Item.Detail(lootOBJ)) do
--          print(string.format("ITEM DATA [%s]=[%s]", x,y))
--       end
--    end


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
   local itemValue   =  nil

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
      itemValue   =  cD.itemCache[lootOBJ].value
      itemZone    =  cD.itemCache[lootOBJ].zone
      itemFlavor  =  cD.itemCache[lootOBJ].flavor
      if itemValue   == nil   then itemValue = 0 end
   else
      itemID      =  Inspect.Item.Detail(lootOBJ).id
      itemName    =  Inspect.Item.Detail(lootOBJ).name
--       itemRarity  =  Inspect.Item.Detail(lootOBJ).rarity
      itemRarity  =  (Inspect.Item.Detail(lootOBJ).rarity  or "common") -- Some items don't have a rarity (ex.: Bundles), we default to common
      itemDesc    =  Inspect.Item.Detail(lootOBJ).description
      itemCategory=  Inspect.Item.Detail(lootOBJ).category
      itemIcon    =  Inspect.Item.Detail(lootOBJ).icon
      itemValue   =  Inspect.Item.Detail(lootOBJ).sell
--       print(string.format("[%s] value is [%s]", itemName, itemValue))
      itemFlavor  =  Inspect.Item.Detail(lootOBJ).flavor
      itemZone    =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
      if itemValue   == nil   then itemValue = 0 end

      -- debug
--       local x,y = nil, nil
--       for x, y in pairs(Inspect.Item.Detail(lootOBJ)) do
--          print(string.format("[%s]=>[%s]=[%s]", itemName, x, y))
--       end


      if cD.itemCache[lootOBJ]   == nil then
         cD.itemCache[lootOBJ]   =  { id=itemID, name=itemName, rarity=itemRarity, description=itemDesc, category=itemCategory, icon=itemIcon, value=itemValue, zone=itemZone, flavor=itemFlavor }
      end
      -- Update personal Char Score
      updateCharScore(itemID, itemZone, lootCount)
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
            -- we add the REAL value of this item
--             cD.totJunkMoney = cD.totJunkMoney + itemValue
            -- then we set up the fake/static Junk target
            lootOBJ     =  cD.junkOBJ
            itemID      =  cD.itemCache[lootOBJ].id
            itemName    =  cD.itemCache[lootOBJ].name
            itemRarity  =  cD.itemCache[lootOBJ].rarity
            itemDesc    =  cD.itemCache[lootOBJ].description
            itemCategory=  cD.itemCache[lootOBJ].category
            itemiCon    =  cD.itemCache[lootOBJ].icon
            itemValue   =  cD.itemCache[lootOBJ].value
            itemZone    =  cD.itemCache[lootOBJ].zone
            itemFlavor  =  cD.itemCache[lootOBJ].flavor
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
--                print(string.format("ITEM MATCH by NAME: _ITEM [%s][%s]", itemID,itemName))
--                print(string.format("ITEM MATCH by NAME: MATCH [%s][%s]", cD.sLTids[idx], cD.sLTnames[idx]))
            end
         end
      end


      if idx then
         --
         -- OLD - we update
         --
         cD.sLTcnts[idx]   =  cD.sLTcnts[idx] + lootCount                     -- loot counter
         cD.sLTcntsOBJs[idx]:SetText(string.format("%3d", cD.sLTcnts[idx]))   -- loot field

         if itemRarity == "sellable" then                                     -- loot text field
            cD.totJunkMoney = cD.totJunkMoney + itemValue                     -- if junk we adjust
            local lootText  =  "Junk "..cD.printJunkMoney(cD.totJunkMoney)    -- MfJ text value
            cD.sLTtextOBJs[idx]:SetText(lootText, true)
         end

         cD.updatePercents(cD.get_totals())

         if not fromHistory then cD.sLTcntsOBJs[idx]:SetBackgroundColor(.6, .6, .6, .5) end

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
         table.insert(cD.sLTtextOBJs,  lineOBJ )
         table.insert(cD.sLTfullOBJs,  lootFrame )
         table.insert(cD.sLTcntsOBJs,  lootCnt )
         table.insert(cD.sLTprcntOBJs, prcntCnt )
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
      -- Adjust History Totals
      --
      if fromHistory == false then
         local zoneOBJ  =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
--          local rarity   =  Inspect.Item.Detail(lootOBJ).rarity
         local zoneID   =  Inspect.Zone.Detail(zoneOBJ).id
--          cD.updateHistory(zoneOBJ, zoneID, lootOBJ, lootCount, rarity, itemValue)
         cD.updateHistory(zoneOBJ, zoneID, lootOBJ, lootCount, itemRarity, itemValue)
      end

      --
      --
      --
      cD.updateTotalsStatusBar(nil, nil, nil)
      --
      --
      --
   else
      print("ERROR in updateLootTable, lootOBJ.id is nil")
   end

   if not cD.window.lootOBJ:GetVisible() then cD.window.lootOBJ:SetVisible(true) end

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
               if not cD.waitingForTheSunRunning then cD.waitingForTheSunRunning =  true end
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

      local winName = win:GetName()
--       print("WIN ["..winName.."]")

      if winName == "Button" then
         cD.window.buttonX =  cD.round(newX)
         cD.window.buttonY =  cD.round(newY)
      end
      if winName == "Info" then
         cD.window.infoX   =  cD.round(newX)
         cD.window.infoY   =  cD.round(newY)
      end
      if winName == "Loot" then
         cD.window.lootX   =  cD.round(newX)
         cD.window.lootY   =  cD.round(newY)
      end
      if winName == "Totals" then
         cD.window.totalsX =  cD.round(newX)
         cD.window.totalsY =  cD.round(newY)
      end
      if winName == "ItemViewer" then
         cD.window.ivX =  cD.round(newX)
         cD.window.ivY =  cD.round(newY)
      end
      if winName == "mmBtnIcon" then
         cD.window.mmBtnX =  cD.round(newX)
         cD.window.mmBtnY =  cD.round(newY)
      end
      if winName == "ToolTip" then
         cD.window.ttX =  cD.round(newX)
         cD.window.ttY =  cD.round(newY)
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
--    if        rarityName == "sellable"  then ret.r = .34375; ret.g = .34375; ret.b = .34375;
   if        rarityName == "sellable"  then ret.r = .35375; ret.g = .35375; ret.b = .35375;
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

function cD.categoryIcon(categoryName, objID, description, itemName)
   local catName  =  categoryName   or ""
   local desc     =  description    or ""
   local iName    =  itemName       or ""
   local retval   =  nil

   catName  =  string.lower(categoryName)
   if description then desc     =  string.lower(description)   end
   iName    =  string.lower(itemName)

--    print(string.format("CategoryName [%s]", categoryName))
--    print(string.format("CatName      [%s]", catName))
--    print(string.format("  objID      [%s]", objID))
--    print(string.format("  description[%s]", description))
--    print(string.format("  desc       [%s]", desc))
--    print(string.format("  itemName   [%s]", itemName))
--    print(string.format("  iName      [%s]", iName))

--    pesci da dailies:
--    Emerald Flytcatcher e Duskeen Eel      (Dusken  - Tullio Retreat)
--    Kraken Hatchling e Coldflare Octopus   (Brevane - Tulan)

--    if desc ~= nil then print(string.format("DESC [%s]", desc)) end
   if       string.find(catName, "artifact" )         ~= nil                              then  retval = "Minion_I3C.dds"                             -- artifact icon
   elseif   string.find(catName, "quest")             ~= nil                              then  retval = "icon_menu_quest.png.dds"                    -- exclamation point
   elseif   string.find(catName, "dimension")         ~= nil                              then  retval = "Minion_I153.dds"                            -- little key
--    elseif   string.find(catName, "crafting material") ~= nil                              then  retval = "outfitter1.dds"                             -- little sprocket
   elseif   desc and string.find(desc, "exchange")    ~= nil                              then  retval = "LFP_BonusReward_iconRepeat.png.dds"         -- quest repeatable
--    elseif   string.find(iName, "chest") or string.find(iName, "treasure")                 then  retval = "reward_loot.png.dds"             	      -- little sack
   elseif   string.find(iName, "chest") or string.find(iName, "treasure")                 then  retval = "chest1a.dds"             	                  -- little sack
   elseif   string.find(iName, "emerald flytcatcher") ~= nil   or
            string.find(iName, "duskeen eel")         ~= nil   or
            string.find(iName, "kraken hatchling")    ~= nil   or
            string.find(iName, "coldflare octopus")   ~= nil                              then  retval = "LFP_BonusReward_iconRepeat.png.dds"         -- quest repeatable
   end

  return retval
end

function cD.multiLineString(s, size)

   local o  =  nil   -- output

   if s and size then
      local S  =  s     -- copy of source
      local i  =  1     -- position
      local t  =  nil   -- temp

      while i < string.len(S) do

         t  =  string.sub(S, i, size)
         if o == nil then

            o = t
         else
            o = o .. "\r" .. t
         end

         t  =  nil
         i  =  i + size
         S  =  string.sub(S, i)
         i  =  1
--          print("split ["..i.."]")
      end
   end

--       if o then print("o ["..o.."]") end

   return(o)
end

function cD.doThings(params)

   -- Create/Display/Hide minimMapButton Window
   if cD.window.mmBtnOBJ    == nil then
      cD.window.mmBtnOBJ    =  cD.createMiniMapButton()
      cD.window.mmBtnOBJ:SetVisible(true)
   end


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

   -- Create/Display ItemViewer Window
   if cD.window.ivOBJ  == nil then
      cD.window.ivOBJ  =  cD.createItemViewerWindow()
      cD.window.ivOBJ:SetVisible(false)
      --       print(string.format("NEW IV OBJ [%s]", cD.window.ivOBJ))
   else
      --       print(string.format("OLD IV OBJ [%s]", cD.window.ivOBJ))
   end

   if cD.window.infoOBJ:GetVisible() == false then cD.window.ivOBJ:SetVisible(false) end


   --    print("-------------------------------------------------------")
   cD.itemBase = cD.scanInventories()
   --    for x,y in pairs(cD.itemBase) do
      --       print(string.format("quantity: [%03d] [%s]", y, x))
      --    end
      --    print("-------------------------------------------------------")

      return
   end
