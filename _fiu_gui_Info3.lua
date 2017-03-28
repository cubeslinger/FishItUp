--
-- Addon       _fiu_gui_Info2.lua
-- Version     0.2
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   12/03/2017
--

local addon, cD = ...

local HEADERFRAME       =  1
-- local cD.text.base_font_size         =  11
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
      titleFIU:SetFontSize(cD.text.base_font_size)
      titleFIU:SetText("FishItUp!")
      titleFIU:SetFont(cD.addon, cD.text.base_font_name)
      titleFIU:SetLayer(3)
      titleFIU:SetPoint("TOPLEFT", titleInfoFrame, "TOPLEFT", cD.borders.left, 1)

      -- HEADER RESET BUTTON
      local menuButton = UI.CreateFrame("Texture", "Reset Button", titleInfoFrame)
      menuButton:SetTexture("Rift", "NPCDialogIcon_questrepeatable.png.dds")
      menuButton:SetHeight(titleFIU:GetHeight())
      menuButton:SetWidth(titleFIU:GetHeight())
      menuButton:SetLayer(1)
      menuButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.resetInfoWindow() cD.resetLootWindow(true) end, "Menu Button Pressed" )
      menuButton:SetPoint("TOPRIGHT", titleInfoFrame, "TOPRIGHT", - cD.borders.right, 1)

      -- HEADER SHOW TOTALS WINDOW BUTTON
      local showTotalsButton = UI.CreateFrame("Texture", "totalsButton", titleInfoFrame)
--       showTotalsButton:SetTexture("Rift", "arrow_dropdown.png.dds")
      showTotalsButton:SetTexture("Rift", "reward_gold.png.dds")
--       showTotalsButton:SetHeight(titleFIU:GetHeight())
      showTotalsButton:SetHeight(titleFIU:GetHeight())
      showTotalsButton:SetWidth(titleFIU:GetHeight())
      showTotalsButton:SetLayer(1)
      showTotalsButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsObj:SetVisible(not cD.window.totalsObj:GetVisible()) end, "Menu Button Pressed" )
      showTotalsButton:SetPoint("TOPRIGHT", menuButton, "TOPLEFT", -2, 1)

   -- re-arrenge title container Height
   titleInfoFrame:SetHeight((titleFIU:GetBottom() - titleInfoFrame:GetTop()))

   return titleInfoFrame
end


function cD.createInfoWindow()

   -- Global context (parent frame-thing).
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
         container1:SetHeight(cD.text.base_font_size)
         container1:SetLayer(1)
--          container1:SetPoint("TOPLEFT",  headerFrame, "TOPLEFT",  0,  cD.borders.top)
--          container1:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", 0,  cD.borders.top)
         container1:SetPoint("TOPLEFT",  headerFrame, "TOPLEFT")
         container1:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT")


            -- HEADER   -- ZONE NAME Header [idx=1]
            local lineOBJ_2 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone", headerFrame)
            local objColor  =  cD.rarityColor("quest")
            lineOBJ_2:SetText(zone)
            lineOBJ_2:SetFont(cD.addon, cD.text.base_font_name)
            lineOBJ_2:SetFontSize(cD.text.base_font_size + 2)
            lineOBJ_2:SetLayer(1)
            lineOBJ_2:SetFontColor(objColor.r, objColor.g, objColor.b)
            lineOBJ_2:SetPoint("CENTER", container1, "CENTER")
            table.insert(cD.sLThdrs, lineOBJ_2 )

         -- HEADER   -- SUB-ZONE NAME CONTAINER Header
         local container2  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone_container", headerFrame)
         container2:SetHeight(cD.text.base_font_size)
         container2:SetLayer(1)
         container2:SetPoint("TOPLEFT",  container1, "BOTTOMLEFT",  cD.borders.left,  (cD.borders.top))
         container2:SetPoint("TOPRIGHT", container1, "BOTTOMRIGHT", 0,  (cD.borders.top))


            -- HEADER   -- SUB-ZONE NAME Header [idx=2]
            local lineOBJ_1 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_subzone", headerFrame)
            local objColor  =  cD.rarityColor("rare") -- green
            lineOBJ_1:SetText("("..subZone..")")
            lineOBJ_1:SetFont(cD.addon, cD.text.base_font_name)
            lineOBJ_1:SetFontSize(cD.text.base_font_size)
            lineOBJ_1:SetLayer(1)
            lineOBJ_1:SetFontColor(objColor.r, objColor.g, objColor.b)
            lineOBJ_1:SetPoint("CENTER", container2, "CENTER")
            table.insert(cD.sLThdrs, lineOBJ_1 )


         -- HEADER   -- GRPAHIC SEPARATOR CONTAINER Header
         local container3  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator_container", headerFrame)
         container3:SetHeight(cD.text.base_font_size/2)
         container3:SetLayer(1)
         container3:SetPoint("TOPLEFT",  container2, "BOTTOMLEFT",  cD.borders.left,  (cD.borders.top/2))
         container3:SetPoint("TOPRIGHT", container2, "BOTTOMRIGHT", 0,  (cD.borders.top/2))

            -- HEADER GRAPHIC SEPARATOR
            local graphSep = UI.CreateFrame("Texture", "Separator", headerFrame)
            graphSep:SetTexture("Rift", "underscore.png.dds")
--             graphSep:SetTexture("Rift", "line_window_break_png.dds")
--             graphSep:SetHeight(titleBar:GetHeight())
            graphSep:SetHeight(cD.text.base_font_size/2)
            graphSep:SetWidth(container3:GetWidth())
            graphSep:SetLayer(1)
--             graphSep:SetPoint("TOPLEFT",  container2, "BOTTOMLEFT",  cD.borders.right,   cD.borders.top *3)
--             graphSep:SetPoint("TOPRIGHT", container2, "BOTTOMRIGHT", - cD.borders.right, cD.borders.top *3)
--             graphSep:SetPoint("TOPLEFT",  container2, "BOTTOMLEFT",  - cD.borders.left,   cD.borders.top *4)
--             graphSep:SetPoint("TOPRIGHT", container2, "BOTTOMRIGHT", cD.borders.right, cD.borders.top *4)
            graphSep:SetPoint("CENTER", container3, "CENTER")


         -- HEADER   -- CASTS/CATCHES CONTAINER Header
         local container4  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_castscatches_container", headerFrame)
         container4:SetLayer(1)
         container4:SetHeight(cD.text.base_font_size)
         container4:SetPoint("TOPLEFT",  container3, "BOTTOMLEFT",  cD.borders.left,  (cD.borders.top/2))
         container4:SetPoint("TOPRIGHT", container3, "BOTTOMRIGHT", 0,  (cD.borders.top/2))


            -- HEADER   -- LABEL -- CASTS Header
            local labelCastsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals_label", headerFrame)
            local objColor  =  cD.rarityColor("common")
            labelCastsOBJ:SetText("Casts/Catches:")
            labelCastsOBJ:SetFont(cD.addon, cD.text.base_font_name)
            labelCastsOBJ:SetFontSize(cD.text.base_font_size)
            labelCastsOBJ:SetLayer(1)
            labelCastsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--             labelCastsOBJ:SetPoint("TOPLEFT", graphSep, "BOTTOMLEFT", cD.borders.left *5, (cD.borders.top))
            labelCastsOBJ:SetPoint("TOPLEFT", container4, "TOPLEFT", cD.borders.left, 0)

            -- HEADER   -- CASTS Header [idx=3]
            local castsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals", headerFrame)
            local objColor  =  cD.rarityColor("quest")
            castsOBJ:SetText(string.format("%5d", cD.today.casts))
            castsOBJ:SetFont(cD.addon, cD.text.base_font_name)
            castsOBJ:SetFontSize(cD.text.base_font_size)
            castsOBJ:SetLayer(1)
            castsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            castsOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "TOPRIGHT", cD.borders.left, 0)
            table.insert(cD.sLThdrs, castsOBJ )

            -- HEADER   -- SEPARATOR Header
            local sepOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            sepOBJ:SetText("/")
            sepOBJ:SetFont(cD.addon, cD.text.base_font_name)
            sepOBJ:SetFontSize(cD.text.base_font_size)
            sepOBJ:SetLayer(1)
            sepOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            sepOBJ:SetPoint("TOPLEFT", castsOBJ, "TOPRIGHT", cD.borders.right, 0)


            -- HEADER   -- TOTALS Header [idx=4]
            local lineOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            lineOBJ:SetText(totalsText)
            lineOBJ:SetFont(cD.addon, cD.text.base_font_name)
            lineOBJ:SetFontSize(cD.text.base_font_size)
            lineOBJ:SetLayer(1)
            lineOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            lineOBJ:SetPoint("TOPLEFT", sepOBJ, "TOPRIGHT", cD.borders.right, 0)
            table.insert(cD.sLThdrs, lineOBJ )

         -- HEADER   -- TIMERS CONTAINER Header
         local container5  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_timers_container", headerFrame)
         container5:SetHeight(cD.text.base_font_size)
         container5:SetLayer(1)
         container5:SetPoint("TOPLEFT",  container4, "BOTTOMLEFT",  cD.borders.left,  (cD.borders.top))
         container5:SetPoint("TOPRIGHT", container4, "BOTTOMRIGHT", 0,  (cD.borders.top))

            -- HEADER -- LABEL  -- CAST TIMER Header
            local labelTimerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer", headerFrame)
            local objColor  =  cD.rarityColor("common") -- green
            labelTimerOBJ:SetText("Time/Session :")
            labelTimerOBJ:SetFont(cD.addon, cD.text.base_font_name)
            labelTimerOBJ:SetFontSize(cD.text.base_font_size)
            labelTimerOBJ:SetLayer(1)
            labelTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--             labelTimerOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "BOTTOMLEFT")
            labelTimerOBJ:SetPoint("TOPLEFT", container5, "TOPLEFT")


            -- HEADER   -- CAST TIMER Header [idx=5]
            local timerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer_label", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            timerOBJ:SetText("--:--")
            timerOBJ:SetFont(cD.addon, cD.text.base_font_name)
            timerOBJ:SetFontSize(cD.text.base_font_size)
            timerOBJ:SetLayer(1)
            timerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            timerOBJ:SetPoint("TOPLEFT", labelTimerOBJ, "TOPRIGHT", cD.borders.left, 0)
            table.insert(cD.sLThdrs, timerOBJ )

            -- HEADER   -- SEPARATOR Header
            local sep1OBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator_1", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            sep1OBJ:SetText("/")
            sep1OBJ:SetFont(cD.addon, cD.text.base_font_name)
            sep1OBJ:SetFontSize(cD.text.base_font_size)
            sep1OBJ:SetLayer(1)
            sep1OBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            sep1OBJ:SetPoint("TOPLEFT", timerOBJ, "TOPRIGHT", cD.borders.right, 0)

            -- HEADER   -- DAY TIMER Header [idx=6]
            local dayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            dayOBJ:SetText("--:--")
            dayOBJ:SetFont(cD.addon, cD.text.base_font_name)
            dayOBJ:SetFontSize(cD.text.base_font_size)
            dayOBJ:SetHeight(cD.text.base_font_size)
            dayOBJ:SetLayer(1)
            dayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            dayOBJ:SetPoint("TOPLEFT", sep1OBJ, "TOPRIGHT", cD.borders.right, 0)
            table.insert(cD.sLThdrs, dayOBJ )

--    headerFrame:SetHeight(cD.round(dayOBJ:GetBottom() - headerFrame:GetTop()) + cD.borders.bottom )
--    infoWindow:SetHeight(cD.round((infoWindow:GetTop() - headerFrame:GetHeight()))    + cD.borders.bottom * 10 )

--       headerFrame:SetHeight(cD.round(container5:GetBottom() - headerFrame:GetTop()) + cD.borders.top + cD.borders.bottom)
      headerFrame:SetHeight(cD.round(container5:GetBottom() - headerFrame:GetTop()) + cD.borders.top + cD.borders.bottom)
--       headerFrame:SetBackgroundColor(1, 0, 0, .5)

      local bottom = infoWindow:GetTop() + titleBar:GetHeight() + headerFrame:GetHeight()
      infoWindow:SetHeight( bottom - infoWindow:GetTop() + cD.borders.top + cD.borders.bottom*2)


-- --       local H = titleBar:GetBottom() + cD.borders.bottom
-- --       infoWindow:SetHeight((H - titleBar:GetTop()) + cD.borders.top + cD.borders.bottom)


   -- Enable Dragging
   Library.LibDraggable.draggify(infoWindow, cD.updateGuiCoordinates)

   return infoWindow
end


function  cD.resetInfoWindow()
   --
   -- Reset Fields
   --
   local zone, subzone = cD.getZoneInfos()
   cD.sLThdrs[1]:SetText(zone)
   cD.sLThdrs[2]:SetText(subzone)
   --
   cD.today.casts =  0
   cD.sLThdrs[3]:SetText(string.format("%5d", cD.today.casts))
   cD.sLThdrs[4]:SetText(string.format("%5d", 0))
   cD.sLThdrs[5]:SetText("--:--")
   cD.sLThdrs[6]:SetText("--:--")

   return
end

