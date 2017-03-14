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
--    titleInfoFrame:SetHeight(tFONTSIZE + 4)
   
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

--    infoWindow:SetWidth(cD.window.width)
   infoWindow:SetWidth(tWIDTH)
   infoWindow:SetLayer(-1)
   infoWindow:SetBackgroundColor(0, 0, 0, .5)

   -- WINDOW Title
   local zone, subZone, zoneID =  cD.getZoneInfos()                                       
   local totalsText    =  "      0"
   
   local titleBar =  createTitleBar(infoWindow) 
   

   -- HEADER CONTAINER FRAME
   local headerFrame =  UI.CreateFrame("Frame", infoWindow:GetName() .. "_header_frame", infoWindow)
--    headerFrame:SetPoint("TOPLEFT",     infoWindow, "TOPLEFT",     cD.borders.left, cD.borders.top )
--    headerFrame:SetPoint("BOTTOMRIGHT", infoWindow, "BOTTOMRIGHT", - cD.borders.right, - cD.borders.bottom )
--    headerFrame:SetPoint("TOPLEFT",     titleBar, "TOPLEFT",     cD.borders.left, cD.borders.top )
--    headerFrame:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", - cD.borders.right, - cD.borders.bottom )
   headerFrame:SetPoint("TOPLEFT",     titleBar, "TOPLEFT")
   headerFrame:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT")

   
   headerFrame:SetLayer(1)
   headerFrame:SetBackgroundColor(.2, .2, .2, .5)   
   cD.sLTFrames[HEADERFRAME]   =  headerFrame

   -- HEADER   -- ZONE NAME Header [idx=1]
   local lineOBJ_2 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zone", headerFrame)
   local objColor  =  cD.rarityColor("quest")
   lineOBJ_2:SetText(zone)
--    lineOBJ_2:SetFontSize(cD.text.base_font_size -2 )
   lineOBJ_2:SetFont(cD.addon, "fonts/unispace.ttf")
   lineOBJ_2:SetFontSize(tFONTSIZE)
   lineOBJ_2:SetLayer(1)
   lineOBJ_2:SetFontColor(objColor.r, objColor.g, objColor.b)
--    lineOBJ_2:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, 0)
   lineOBJ_2:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight())
   table.insert(cD.sLThdrs, lineOBJ_2 )

   -- HEADER   -- SUB-ZONE NAME Header [idx=2]
   local lineOBJ_1 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_subzone", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green
   lineOBJ_1:SetText(subZone)
--    lineOBJ_1:SetFontSize(cD.text.base_font_size -2 )
   lineOBJ_1:SetFont(cD.addon, "fonts/unispace.ttf")
   lineOBJ_1:SetFontSize(tFONTSIZE)
   lineOBJ_1:SetLayer(1)
   lineOBJ_1:SetFontColor(objColor.r, objColor.g, objColor.b)
   lineOBJ_1:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_2:GetHeight())
   table.insert(cD.sLThdrs, lineOBJ_1 )

   
   -- HEADER   -- LABEL -- ZONE MIN SKILL Header
   local labelMinSkillOBJ  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zoneminskill_label", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green                     
   labelMinSkillOBJ:SetText("Skill  :")
--    lineOBJ:SetFontSize(cD.text.base_font_size -2 )
   labelMinSkillOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   labelMinSkillOBJ:SetFontSize(tFONTSIZE)
   labelMinSkillOBJ:SetLayer(1)
   labelMinSkillOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   labelMinSkillOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight())  
   
   -- HEADER   -- ZONE MIN SKILL Header
   local lineMinSkillOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_zoneminskill", headerFrame)
   local objColor  =  cD.rarityColor("common") -- green
   lineMinSkillOBJ:SetText(string.format("%5s", cD.getZoneMinSkill(zoneID)))
--    lineOBJ:SetFontSize(cD.text.base_font_size -2 )
   lineMinSkillOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   lineMinSkillOBJ:SetFontSize(tFONTSIZE)
   lineMinSkillOBJ:SetLayer(1)
   lineMinSkillOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   lineMinSkillOBJ:SetPoint("TOPLEFT", labelMinSkillOBJ, "TOPRIGHT", cD.borders.left, 0)
--    table.insert(cD.sLThdrs, lineOBJ )
   
   
   -- HEADER   -- LABEL -- TOTALS Header
   local labelOBJ  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals_label", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green                     
   labelOBJ:SetText("Totals :")
--    lineOBJ:SetFontSize(cD.text.base_font_size -2 )
   labelOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   labelOBJ:SetFontSize(tFONTSIZE)
   labelOBJ:SetLayer(1)
   labelOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   labelOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineMinSkillOBJ:GetHeight())  
   
   -- HEADER   -- TOTALS Header [idx=3]
   local lineOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals", headerFrame)
   local objColor  =  cD.rarityColor("common") -- green
   lineOBJ:SetText(totalsText)
--    lineOBJ:SetFontSize(cD.text.base_font_size -2 )
   lineOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   lineOBJ:SetFontSize(tFONTSIZE)
   lineOBJ:SetLayer(1)
   lineOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   lineOBJ:SetPoint("TOPLEFT", labelOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(cD.sLThdrs, lineOBJ )

   
   
   -- HEADER   -- LABEL -- CASTS Header
   local labelCastsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals_label", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green                                                             
   labelCastsOBJ:SetText("Casts  :")
   labelCastsOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   labelCastsOBJ:SetFontSize(tFONTSIZE)
   labelCastsOBJ:SetLayer(1)
   labelCastsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--    castsOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight())
   labelCastsOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ_2:GetHeight() + lineMinSkillOBJ:GetHeight())
   
   -- HEADER   -- CASTS Header [idx=4]
   local castsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals", headerFrame)
   local objColor  =  cD.rarityColor("common") -- green                                   
   castsOBJ:SetText(string.format("%5d", cD.today.casts))
   castsOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   castsOBJ:SetFontSize(tFONTSIZE)
   castsOBJ:SetLayer(1)
   castsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--    castsOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight())
--    castsOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ_2:GetHeight())
   castsOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(cD.sLThdrs, castsOBJ )

   -- HEADER -- LABEL  -- CAST TIMER Header
   local labelTimerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green                          

   labelTimerOBJ:SetText("Timer  :")
--    timerOBJ:SetFontSize(cD.text.base_font_size -2 )
   labelTimerOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   labelTimerOBJ:SetFontSize(tFONTSIZE)
   labelTimerOBJ:SetLayer(1)
   labelTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   labelTimerOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + lineMinSkillOBJ:GetHeight() + castsOBJ:GetHeight())  
   
   
   -- HEADER   -- CAST TIMER Header [idx=5]
   local timerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer_label", headerFrame)
   local objColor  =  cD.rarityColor("common") -- green
   timerOBJ:SetText("--:--")
--    timerOBJ:SetFontSize(cD.text.base_font_size -2 )
   timerOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   timerOBJ:SetFontSize(tFONTSIZE)
   timerOBJ:SetLayer(1)
   timerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--    timerOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + castsOBJ:GetHeight())
   timerOBJ:SetPoint("TOPLEFT", labelTimerOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(cD.sLThdrs, timerOBJ )



   -- HEADER -- LABEL  -- DAY TIMER Header [idx=6]
   local labelDayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer_label", headerFrame)
   local objColor  =  cD.rarityColor("quest") -- green

   labelDayOBJ:SetText("Session:")
--    dayOBJ:SetFontSize(cD.text.base_font_size -2 )
   labelDayOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   labelDayOBJ:SetFontSize(tFONTSIZE)
   labelDayOBJ:SetLayer(1)
   labelDayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--    dayOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + castsOBJ:GetHeight()  + timerOBJ:GetHeight())
   labelDayOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + lineMinSkillOBJ:GetHeight() + castsOBJ:GetHeight() + timerOBJ:GetHeight())
   
   -- HEADER   -- DAY TIMER Header [idx=6]
   local dayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer", headerFrame)
   local objColor  =  cD.rarityColor("common") -- green
   dayOBJ:SetText("--:--")
--    dayOBJ:SetFontSize(cD.text.base_font_size -2 )
   dayOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   dayOBJ:SetFontSize(tFONTSIZE)
   dayOBJ:SetLayer(1)
   dayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--    dayOBJ:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", - cD.borders.right, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + castsOBJ:GetHeight()  + timerOBJ:GetHeight())
--    dayOBJ:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", cD.borders.left, lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + castsOBJ:GetHeight() + timerOBJ:GetHeight())
   dayOBJ:SetPoint("TOPLEFT", labelDayOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(cD.sLThdrs, dayOBJ )

--    local hdrsHeight = lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + timerOBJ:GetHeight()
   local hdrsHeight = titleBar:GetHeight() + lineOBJ_1:GetHeight() + lineOBJ_2:GetHeight() + lineOBJ:GetHeight() + lineMinSkillOBJ:GetHeight() + castsOBJ:GetHeight() + timerOBJ:GetHeight() + dayOBJ:GetHeight()
   infoWindow:SetHeight(cD.borders.top + hdrsHeight + cD.borders.bottom)

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
   cD.sLThdrs[3]:SetText("0")
   cD.sLThdrs[4]:SetText(string.format("%5d", cD.today.casts))
   cD.sLThdrs[5]:SetText("--:--")
   cD.sLThdrs[6]:SetText("--:--")
   local zone, subzone = cD.getZoneInfos()
   cD.sLThdrs[1]:SetText(zone)
   cD.sLThdrs[2]:SetText(subzone)

   return
end

