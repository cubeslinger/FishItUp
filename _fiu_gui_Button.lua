--
-- Addon       _fiu_gui_Button.lua
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
--

local addon, cD = ...

local function getPole()

   local poles =  {}

   for bagnumber=1,10 do
      for bagslot=1,40 do
         itemslot = "si"..string.format("%2.2d",bagnumber).."."..string.format("%3.3d",bagslot)
         d = Inspect.Item.Detail(itemslot)
         if d then
            if d.name then
--                if string.suffix(d.name, "Fishing Pole") or string.suffix(d.name, "Fishin' Pole") then
               if ((string.find(d.name, "Fishing Pole") and not string.find(d.name, "Recipe")) or
                  (string.find(d.name, "Fishin' Pole") and not string.find(d.name, "Recipe"))) then
                  table.insert(poles, d)
--                   for a,b in pairs(d) do print(string.format("running [%s]=[%s]", a, b)) end
               end
            end
         end
      end
   end

   local bestpole  =  nil
   for idx, tbl in pairs(poles) do

      if bestpole == nil then
         bestpole = tbl
      else
         if bestpole.requiredSkillLevel < tbl.requiredSkillLevel then   bestpole  =  tbl  end
      end
   end

--    print(string.format("Pole [%s] rarity[%s]", bestpole.name, bestpole.rarity))
   return bestpole
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
   local poleContext       =  nil
   local poleCastFrame     =  nil
   local poleCastButton    =  nil
   local poleCastTimerOBJ  =  nil

   --Global context (parent frame-thing).
   poleContext = UI.CreateContext("button_context")
   poleContext:SetSecureMode("restricted")

   -- detect Fishing Pole
   if cD.poleTBL == nil or cD.poleTBL.name == nil then
      cD.poleTBL = getPole()
      print(string.format("pole [%s]", cD.poleTBL.name))
   end

   -- Frame Cornice
   poleCastFrame  = UI.CreateFrame("Texture", "Button", poleContext)
   poleCastFrame:SetSecureMode("restricted")
   poleCastFrame:SetTexture("Rift", "AATree_IF8.dds")
   poleCastFrame:SetLayer(0)
   poleCastFrame:SetWidth(cD.window.buttonW  or 64)
   poleCastFrame:SetHeight(cD.window.buttonH or 64)
   if cD.window.buttonX == nil or cD.window.buttonY == nil then
      -- first run, we position in the screen center
      poleCastFrame:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      poleCastFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.buttonX, cD.window.buttonY)
   end

   -- Pole Icon
   poleCastButton = UI.CreateFrame("Texture", poleCastFrame:GetName().."_poleCastIcon", poleCastFrame)
   poleCastButton:SetTexture("Rift", cD.poleTBL.icon)
   poleCastButton:SetPoint("CENTER", poleCastFrame, "CENTER")
   poleCastButton:SetSecureMode("restricted")
   poleCastButton:SetLayer(1)
--    poleCastButton:SetWidth(42)
--    poleCastButton:SetHeight(42)
   poleCastButton:SetWidth(cD.round(poleCastFrame:GetWidth()/1.5))
   poleCastButton:SetHeight(cD.round(poleCastFrame:GetHeight()/1.5))

   poleCastButton:EventAttach(Event.UI.Input.Mouse.Wheel.Back,    function()
--                                                                      print"WHEEL BACK!"
                                                                     poleCastFrame:SetWidth(poleCastFrame:GetWidth()    - 2)
                                                                     poleCastFrame:SetHeight(poleCastFrame:GetHeight()  - 2)
                                                                     poleCastButton:SetWidth(cD.round(poleCastFrame:GetWidth()/1.5))
                                                                     poleCastButton:SetHeight(cD.round(poleCastFrame:GetHeight()/1.5))
                                                                     if poleCastTimerOBJ then poleCastTimerOBJ:SetFontSize(poleCastTimerOBJ:GetFontSize() + 2) end
                                                                     -- save button scale factor
                                                                     cD.window.buttonW =  poleCastFrame:GetWidth()
                                                                     cD.window.buttonH =  poleCastFrame:GetHeight()
                                                                  end,
                                                                  "poleCastButton_wheel_back")
   poleCastButton:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function()
--                                                                      print"WHEEL FORWARD!"
                                                                     poleCastFrame:SetWidth(poleCastFrame:GetWidth()    + 2)
                                                                     poleCastFrame:SetHeight(poleCastFrame:GetHeight()  + 2)
                                                                     poleCastButton:SetWidth(cD.round(poleCastFrame:GetWidth()/1.5))
                                                                     poleCastButton:SetHeight(cD.round(poleCastFrame:GetHeight()/1.5))
                                                                     if poleCastTimerOBJ then poleCastTimerOBJ:SetFontSize(poleCastTimerOBJ:GetFontSize() - 2) end
                                                                     -- save button scale factor
                                                                     cD.window.buttonW =  poleCastFrame:GetWidth()
                                                                     cD.window.buttonH =  poleCastFrame:GetHeight()
                                                                  end,
                                                                  "poleCastButton_wheel_forward")

   -- Fishing Timer
   local tFONTSIZE        =   11
   local poleCastTimerOBJ =   UI.CreateFrame("Text", poleCastFrame:GetName().."_poleCastTimer", poleCastFrame)
   poleCastTimerOBJ:SetFont(cD.addon, cD.text.base_font_name)
   poleCastTimerOBJ:SetFontSize(tFONTSIZE+7)
   poleCastTimerOBJ:SetText("00")
   poleCastTimerOBJ:SetLayer(2)
   local objColor  =  cD.rarityColor("common")
   poleCastTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   poleCastTimerOBJ:SetPoint("CENTER", poleCastFrame, "CENTER")
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

               Command.Event.Attach(Event.Unit.Castbar,              cD.gotCastBar,          "Player is Casting")
               Command.Event.Attach(Event.System.Update.Begin,       cD.timedEventsManager,  "Event.System.Update.Begin")
            else
               --
               -- stop eventually still running loot event monitor
               --
               cD.detachLootWatchers()
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

   cD.sLTFrames.polecastbutton   =  poleCastButton

   -- Enable Dragging
   Library.LibDraggable.draggify(poleCastFrame, cD.updateGuiCoordinates)

   return poleCastFrame
end

