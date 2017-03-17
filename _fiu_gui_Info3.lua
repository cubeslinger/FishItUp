--
-- Addon       _fiu_gui_Info2.lua
-- Version     0.2
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   12/03/2017
--

local addon, cD = ...

local HEADERFRAME       =  1
local tFONTSIZE         =  11
local tWIDTH            =  355
local tMAXSTRINGSIZE    =	20
local tWIDTH				=  200

local function createTitleBar(parent)

   -- TITLE BAR CONTAINER
   local titleInfoFrame =  UI.CreateFrame("Frame", "External_Info_Frame", parent)
   titleInfoFrame:SetPoint("TOPLEFT",     parent, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleInfoFrame:SetPoint("TOPRIGHT",    parent, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleInfoFrame:SetBackgroundColor(.1, .1, .1, .7)
   titleInfoFrame:SetLayer(1)

   -- TITLE BAR TITLE
   local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleInfoFrame)
   titleFIU:SetFontSize(tFONTSIZE)
   titleFIU:SetText("FishItUp!")
   titleFIU:SetFont(cD.addon, "fonts/unispace.ttf")
   titleFIU:SetLayer(3)
   titleFIU:SetPoint("TOPLEFT", titleInfoFrame, "TOPLEFT", cD.borders.left, 1)

   -- TITLE BAR Widgets: setup MINIMIZE Icon Frame
   frameMinimizeIcon  =  UI.CreateFrame("Texture", "Minimize_Icon_Frame", titleInfoFrame)
   frameMinimizeIcon:SetHeight(titleFIU:GetHeight())
   frameMinimizeIcon:SetLayer(2)
   frameMinimizeIcon:SetBackgroundColor(0, 0, 0, .5)
   frameMinimizeIcon:SetPoint("TOPRIGHT",   titleInfoFrame, "TOPRIGHT", - 2, 1)
   -- TITLE BAR Widgets: setup MINIMIZE  Icon
   minimizeIcon = UI.CreateFrame("Texture", "MinimizeIcon", titleInfoFrame)
   minimizeIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
   minimizeIcon:SetHeight(titleFIU:GetHeight())
   minimizeIcon:SetLayer(3)
   minimizeIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsObj:SetVisible(not cD.window.totalsObj:GetVisible()) end , "Iconize Totals Pressed"
 )
   minimizeIcon:SetPoint("CENTER",    frameMinimizeIcon, "CENTER", -2, 1)

   -- HEADER RESET BUTTON
   local menuButton = UI.CreateFrame("Texture", "Reset Button", titleInfoFrame)
   menuButton:SetTexture("Rift", "NPCDialogIcon_questrepeatable.png.dds")
   menuButton:SetHeight(titleFIU:GetHeight())
   menuButton:SetLayer(1)
   menuButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.resetInfoWindow() cD.resetLootWindow() cD.addToZoneID() end, "Menu Button Pressed" )
   menuButton:SetPoint("TOPRIGHT", frameMinimizeIcon, "TOPLEFT", - cD.borders.right, 1)

   -- HEADER SHOW TOTALS WINDOW BUTTON
   local showTotalsButton = UI.CreateFrame("Texture", "totalsButton", titleInfoFrame)
   showTotalsButton:SetTexture("Rift", "arrow_dropdown.png.dds")
   showTotalsButton:SetHeight(titleFIU:GetHeight())
   showTotalsButton:SetLayer(1)
   showTotalsButton:SetHeight(cD.text.base_font_size)
   showTotalsButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsObj:SetVisible(not cD.window.totalsObj:GetVisible()) end, "Menu Button Pressed" )
   showTotalsButton:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -2, 1)

   -- re-arrenge title container Height
   titleInfoFrame:SetHeight((titleFIU:GetBottom() - titleInfoFrame:GetTop()) + 2)

   return titleInfoFrame
end


function cD.createInfoWindow()

   --Global context (parent frame-thing).
   local infoWindow  =  UI.CreateFrame("Frame", "Info", UI.CreateContext("Info_context"))

   if cD.window.infoX == nil or cD.window.infoY == nil then
      -- first run, we position in the screen center
      infoWindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      infoWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.infoX or 0, cD.window.infoY or 0)
   end

--    infoWindow:SetWidth(tWIDTH)
   infoWindow:SetWidth(cD.window.width)
   infoWindow:SetLayer(-1)
   infoWindow:SetBackgroundColor(0, 0, 0, .5)

   -- WINDOW Title
   local zone, subZone, zoneID =  cD.getZoneInfos()
   local totalsText    =   string.format("%d", 0)

   local titleBar =  createTitleBar(infoWindow)

      -- HEADER CONTAINER FRAME
      local headerFrame =  UI.CreateFrame("Frame", infoWindow:GetName() .. "_header_frame", infoWindow)
      headerFrame:SetPoint("TOPLEFT",     titleBar,   "BOTTOMLEFT",  cD.borders.left,     cD.borders.top)
      headerFrame:SetPoint("TOPRIGHT",    titleBar,   "BOTTOMRIGHT", - cD.borders.right,  cD.borders.top)

      headerFrame:SetPoint("BOTTOMLEFT",  infoWindow, "BOTTOMLEFT",  cD.borders.left,  - cD.borders.bottom)
      headerFrame:SetPoint("BOTTOMRIGHT", infoWindow, "BOTTOMRIGHT", - cD.borders.right,  - cD.borders.bottom)
      headerFrame:SetLayer(1)
      cD.sLTFrames[HEADERFRAME]   =  headerFrame

         -- HEADER   -- ZONE NAME CONTAINER Header
         local container1  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone_container", headerFrame)
         container1:SetLayer(1)
         container1:SetPoint("TOPLEFT",  headerFrame, "TOPLEFT",  0,  cD.borders.top*2)
         container1:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", 0,  cD.borders.top*2)

            -- HEADER   -- ZONE NAME Header [idx=1]
            local lineOBJ_2 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone", headerFrame)
            local objColor  =  cD.rarityColor("quest")
            lineOBJ_2:SetText(zone)
            lineOBJ_2:SetFont(cD.addon, "fonts/unispace.ttf")
            lineOBJ_2:SetFontSize(tFONTSIZE + 2)
            lineOBJ_2:SetLayer(1)
            lineOBJ_2:SetFontColor(objColor.r, objColor.g, objColor.b)
            lineOBJ_2:SetPoint("CENTER", container1, "CENTER")
            table.insert(cD.sLThdrs, lineOBJ_2 )

         -- HEADER   -- SUB-ZONE NAME CONTAINER Header
         local container2  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone_container", headerFrame)
         container2:SetLayer(1)
         container2:SetPoint("TOPLEFT",  container1, "BOTTOMLEFT",  cD.borders.left,  (cD.borders.top*3))
         container2:SetPoint("TOPRIGHT", container1, "BOTTOMRIGHT", 0,  (cD.borders.top*3))


            -- HEADER   -- SUB-ZONE NAME Header [idx=2]
            local lineOBJ_1 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_subzone", headerFrame)
            local objColor  =  cD.rarityColor("rare") -- green
            lineOBJ_1:SetText("("..subZone..")")
            lineOBJ_1:SetFont(cD.addon, "fonts/unispace.ttf")
            lineOBJ_1:SetFontSize(tFONTSIZE)
            lineOBJ_1:SetLayer(1)
            lineOBJ_1:SetFontColor(objColor.r, objColor.g, objColor.b)
            lineOBJ_1:SetPoint("CENTER", container2, "CENTER")
            table.insert(cD.sLThdrs, lineOBJ_1 )


            -- HEADER   -- LABEL -- CASTS Header
            local labelCastsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals_label", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            labelCastsOBJ:SetText("Casts/Catches:")
            labelCastsOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            labelCastsOBJ:SetFontSize(tFONTSIZE)
            labelCastsOBJ:SetLayer(1)
            labelCastsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--             labelCastsOBJ:SetPoint("TOPLEFT", labelOBJ, "BOTTOMLEFT", 0, cD.borders.top/2)
            labelCastsOBJ:SetPoint("TOPLEFT", container2, "BOTTOMLEFT", cD.borders.left, (cD.borders.top*3))

            -- HEADER   -- CASTS Header [idx=4]
            local castsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            castsOBJ:SetText(string.format("%5d", cD.today.casts))
            castsOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            castsOBJ:SetFontSize(tFONTSIZE)
            castsOBJ:SetLayer(1)
            castsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            castsOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "TOPRIGHT", cD.borders.left, 0)
            table.insert(cD.sLThdrs, castsOBJ )

            -- HEADER   -- SEPARATOR Header [idx=3]
            local sepOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            sepOBJ:SetText("/")
            sepOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            sepOBJ:SetFontSize(tFONTSIZE)
            sepOBJ:SetLayer(1)
            sepOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            sepOBJ:SetPoint("TOPLEFT", castsOBJ, "TOPRIGHT", cD.borders.right, 0)
--             table.insert(cD.sLThdrs, lineOBJ )


            -- HEADER   -- TOTALS Header [idx=3]
            local lineOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            lineOBJ:SetText(totalsText)
            lineOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            lineOBJ:SetFontSize(tFONTSIZE)
            lineOBJ:SetLayer(1)
            lineOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   --          lineOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, (cD.borders.top*3))
            lineOBJ:SetPoint("TOPLEFT", sepOBJ, "TOPRIGHT", cD.borders.right, 0)
            table.insert(cD.sLThdrs, lineOBJ )


         -- HEADER -- LABEL  -- CAST TIMER Header
         local labelTimerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green

         labelTimerOBJ:SetText("Time/Session :")
         labelTimerOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
         labelTimerOBJ:SetFontSize(tFONTSIZE)
         labelTimerOBJ:SetLayer(1)
         labelTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
         labelTimerOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "BOTTOMLEFT", 0, cD.borders.top/2)


            -- HEADER   -- CAST TIMER Header [idx=5]
            local timerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer_label", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            timerOBJ:SetText("--:--")
            timerOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            timerOBJ:SetFontSize(tFONTSIZE)
            timerOBJ:SetLayer(1)
            timerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
         --    timerOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + castsOBJ:GetHeight())
            timerOBJ:SetPoint("TOPLEFT", labelTimerOBJ, "TOPRIGHT", cD.borders.left, 0)
            table.insert(cD.sLThdrs, timerOBJ )

            -- HEADER   -- SEPARATOR Header [idx=3]
            local sep1OBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator_1", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            sep1OBJ:SetText("/")
            sep1OBJ:SetFont(cD.addon, "fonts/unispace.ttf")
            sep1OBJ:SetFontSize(tFONTSIZE)
            sep1OBJ:SetLayer(1)
            sep1OBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            --          lineOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, (cD.borders.top*3))
            sep1OBJ:SetPoint("TOPLEFT", timerOBJ, "TOPRIGHT")
--             table.insert(cD.sLThdrs, lineOBJ )


         -- HEADER   -- DAY TIMER Header [idx=6]
         local dayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer", headerFrame)
         local objColor  =  cD.rarityColor("common") -- green
         dayOBJ:SetText("--:--")
         dayOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
         dayOBJ:SetFontSize(tFONTSIZE)
         dayOBJ:SetHeight(tFONTSIZE)
         dayOBJ:SetLayer(1)
         dayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
         dayOBJ:SetPoint("TOPLEFT", sep1OBJ, "TOPRIGHT", cD.borders.left, 0)
         table.insert(cD.sLThdrs, dayOBJ )


--    headerFrame:SetHeight(((cD.round(dayOBJ:GetBottom() - headerFrame:GetTop())) /2.5) + cD.borders.bottom*2)
--    infoWindow:SetHeight(((infoWindow:GetTop() + headerFrame:GetHeight() )/2.5) + cD.borders.bottom*2)

   headerFrame:SetHeight(cD.round(dayOBJ:GetBottom() - headerFrame:GetTop()) + cD.borders.bottom * 2 )
   infoWindow:SetHeight(cD.round((infoWindow:GetTop() - headerFrame:GetHeight()))    + cD.borders.bottom * 2 )


   -- Enable Dragging
   Library.LibDraggable.draggify(infoWindow, cD.updateGuiCoordinates)

   return infoWindow
end


function  cD.resetInfoWindow()
   --
   -- Reset Fields
   --
--    totalsCnt:SetFont(cD.addon, "fonts/unispace.ttf")
--    totalsCnt:SetFontSize(tFONTSIZE)

   cD.sLThdrs[3]:SetText(string.format("%5d", cD.today.casts))
   cD.sLThdrs[4]:SetText(string.format("%5d", 0))
   cD.sLThdrs[5]:SetText("--:--")
   cD.sLThdrs[6]:SetText("--:--")
   local zone, subzone = cD.getZoneInfos()
   cD.sLThdrs[1]:SetText(zone)
   cD.sLThdrs[2]:SetText(subzone)

   return
end

