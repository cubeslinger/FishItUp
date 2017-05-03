--
-- Addon       _fiu_gui_Button.lua
-- Version     0.5
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   14/03/2017
--

local addon, cD = ...

local POLECASTBUTTON    =  5
local LOOTFRAME         =  3

local function getPole()

   for bagnumber=1,10 do
      for bagslot=1,40 do
         itemslot = "si"..string.format("%2.2d",bagnumber).."."..string.format("%3.3d",bagslot)
         d = Inspect.Item.Detail(itemslot)
         if d then
            if d.name then
               if string.suffix(d.name, "Fishing Pole") or string.suffix(d.name, "Fishin' Pole")then
--                   local key   =  nil
--                   local val   =  nil
--                   for key, val in pairs(d) do print(string.format("[%s] = [%s]", key, val)) end
                  return d
               end
            end
         end
      end
   end

   return
end

function cD.loadLastSession()
   local zoneID   =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
   local retval   =  false
   local zID, t = nil, nil

--    print("entering cD.loadLastSession")

   -- load lootIDs Array
   for zID, t in pairs(cD.lastZoneLootOBJs) do
      if zID == zoneID then

         cD.SLTids   =  {}
         cD.sLTcnts  =  {}

         local iID, cnt = nil, nil
         for iID, cnt in pairs(t) do

            if iID ~= nil and cnt ~= nil then
               --
               -- initialize cD.junkOBJ to avoid duplicating
               -- the junk line in loot window
               --
               if cD.junkOBJ == nil and itemCache[iID].rarity == "sellable" then cD.junkOBJ = iID end

--                print(string.format("cD.loadLastSession time[%s] item[%s]", Inspect.Time.Frame(), iID))
               cD.updateLootTable(iID, cnt, true)
               retval = true
            end

         end
      end
   end

   return retval
end



function cD.createButtonWindow()

   --Global context (parent frame-thing).
   local context = UI.CreateContext("button_context")
   context:SetSecureMode("restricted")

   local buttonFrame    =  UI.CreateFrame("Frame", "Button", context)
   buttonFrame:SetSecureMode("restricted")
   buttonFrame:SetLayer(-1)
   buttonFrame:SetBackgroundColor(0, 0, 0, .5)

   if cD.window.buttonX == nil or cD.window.buttonY == nil then
      -- first run, we position in the screen center
      buttonFrame:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      buttonFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.buttonX, cD.window.buttonY)
   end

   -- detect Fishing Pole
   if cD.poleTBL == nil or cD.poleTBL.name == nil then
      cD.poleTBL = getPole()
      --       print(string.format("pole [%s]", cD.poleTBL.name))
   end

   local poleCastButton = UI.CreateFrame("Texture", buttonFrame:GetName().."_poleCastIcon", buttonFrame)
   poleCastButton:SetTexture("Rift", cD.poleTBL.icon)
   poleCastButton:SetPoint("CENTER", buttonFrame, "CENTER")
   poleCastButton:SetSecureMode("restricted")
   poleCastButton:SetLayer(0)
   poleCastButton:SetWidth(buttonFrame:GetWidth() - 6)
   poleCastButton:SetHeight(buttonFrame:GetHeight() - 6)

   local tFONTSIZE        =   11
   local poleCastTimerOBJ =   UI.CreateFrame("Text", buttonFrame:GetName().."_poleCastTimer", buttonFrame)
   poleCastTimerOBJ:SetFont(cD.addon, cD.text.base_font_name)
   poleCastTimerOBJ:SetFontSize(tFONTSIZE+7)
   poleCastTimerOBJ:SetText("00")
   poleCastTimerOBJ:SetLayer(1)
   local objColor  =  cD.rarityColor("common")
   poleCastTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   poleCastTimerOBJ:SetPoint("CENTER", buttonFrame, "CENTER")
   poleCastTimerOBJ:SetVisible(false)
   cD.poleTimer   =  poleCastTimerOBJ

   -- assign "use" to Pole object to button action
   if (cD.poleTBL)   then
      if next(cD.poleTBL) ~= nil then
         poleCastButton:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "use" .. " " .. cD.poleTBL.name)

         function poleCastButton.Event:LeftClick()
            local currentMacro   =  poleCastButton:EventMacroGet(Event.UI.Input.Mouse.Left.Click)

            if currentMacro ~= "stopcasting" then

               -- change button Action to "/stopcasting"
               poleCastButton:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "stopcasting")

               --
               -- stop eventually still running loot event monitor
               --
               cD.detachLootWatchers()
--                cD.detachOtherWatchers()
               cD.waitingForTheSunRunning = false
               --
               -- Clear eventually pending events in
               --
               cD.eventBuffer =  {}
               --
               --
               -- hide timer on castButton
               --
               cD.poleTimer:SetVisible(false)
               --
               -- refresh Zone Headers
               --
               local zone, subzone, zoneID = cD.getZoneInfos()
               --
               -- if we changed zone, we try to reload the last
               -- stored session values or reset the loot window
               --
               if cD.sLThdrs[1]:GetText() ~= zone     then
--                   print(string.format("OLD ZONE[%s] NEWZONE[%s]", cD.sLThdrs[1]:GetText(), zone))
                  cD.sLThdrs[1]:SetText(zone)
                  cD.resetLootWindow()
                  cD.loadLastSession()
               end
               if cD.sLThdrs[2]:GetText() ~= subzone  then  cD.sLThdrs[2]:SetText(subzone)   end

               -- casts Total
               cD.today.casts =  cD.today.casts + 1
               cD.sLThdrs[3]:SetText(string.format("%5d", cD.today.casts))

               -- show timer on castButton
               cD.poleTimer:SetVisible(true)

               -- change action associated with cast button: now it will "/stopcasting"
               poleCastButton:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "stopcasting")

               cD.timeRStart  =  nil

               cD.itemBase =  cD.scanInventories()

--                Command.Event.Attach(Event.Unit.Detail.Combat,        cD.stopFishingEvent,    "Player in Combat")
               Command.Event.Attach(Event.Unit.Castbar,              cD.gotCastBar,          "Player is Casting")
               Command.Event.Attach(Event.System.Update.Begin,       cD.timedEventsManager,  "Event.System.Update.Begin")
            else
               --
               -- stop eventually still running loot event monitor
               --
               cD.detachLootWatchers()
--                cD.detachOtherWatchers()
               cD.waitingForTheSunRunning =  false
               --
               -- Clear eventually pending events in
               --
               cD.eventBuffer =  {}

               -- hide pole Timer
               cD.poleTimer:SetVisible(false)

               -- reset to default Macro Action
               -- THIS ONE MAY CRASH WHEN ENTERING IN COMBAT: frame is
               -- protected and we can't modify it while in combat.
               --
               poleCastButton:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "use" .. " " .. cD.poleTBL.name)
            end
         end
      end
   end

   cD.sLTFrames[POLECASTBUTTON] = poleCastButton

   -- Enable Dragging
   Library.LibDraggable.draggify(buttonFrame, cD.updateGuiCoordinates)

   return buttonFrame
end

