--
-- Addon       _fiu_gui_Info4.lua
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
--

local addon, cD = ...

local HEADERFRAME       =  1
local tWIDTH            =  355
local tMAXSTRINGSIZE    =	20
local tWIDTH				=  200
local iconsize          =  32
cD.iconStock            =  {}
displayedIcons          =  {}

local function createTitleBar(parent)

   -- TITLE BAR CONTAINER
   local titleInfoFrame =  UI.CreateFrame("Frame", "External_Info_Frame", parent)
   titleInfoFrame:SetPoint("TOPLEFT",     parent, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleInfoFrame:SetPoint("TOPRIGHT",    parent, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleInfoFrame:SetBackgroundColor(.1, .1, .1, .7)
   titleInfoFrame:SetLayer(1)
   cD.attachTT(titleInfoFrame, "titlebar")

      -- HEADER FishItUp! Icon
      local fiuIcon  = UI.CreateFrame("Texture", "fiuIcon", titleInfoFrame)
      fiuIcon:SetTexture("Rift", "Fish_icon.png.dds")
--       fiuIcon:SetHeight(titleFIU:GetHeight())
--       fiuIcon:SetWidth(titleFIU:GetHeight())
      fiuIcon:SetHeight(cD.round(cD.text.base_font_size*1.5))
      fiuIcon:SetWidth(cD.round(cD.text.base_font_size*1.5))
      fiuIcon:SetLayer(1)
      fiuIcon:SetPoint("TOPLEFT", titleInfoFrame, "TOPLEFT", 0, -1)

      -- TITLE BAR TITLE
      local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleInfoFrame)
      titleFIU:SetFontSize(cD.text.base_font_size -2)
--       titleFIU:SetText("FishItUp!")
      titleFIU:SetText(cD.fiuTITLE, true)
      titleFIU:SetFont(cD.addon, cD.text.base_font_name)
      titleFIU:SetLayer(3)
      titleFIU:SetPoint("TOPLEFT", fiuIcon, "TOPRIGHT", cD.borders.left, 0)

      -- HEADER ICONIZE BUTTON
      local iconizeButton = UI.CreateFrame("Texture", "Iconize Button", titleInfoFrame)
      iconizeButton:SetTexture("Rift", "splitbtn_arrow_D_(normal).png.dds")
      iconizeButton:SetHeight(titleFIU:GetHeight())
      iconizeButton:SetWidth(titleFIU:GetHeight())
      iconizeButton:SetLayer(1)
      iconizeButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.infoOBJ:SetVisible(false) cD.window.lootOBJ:SetVisible(false)end, "Iconize Info Button Pressed" )
      iconizeButton:SetPoint("TOPRIGHT", titleInfoFrame, "TOPRIGHT", - cD.borders.right, 1)
      cD.attachTT(iconizeButton, "minimize")

      -- HEADER RESET BUTTON
      local resetButton = UI.CreateFrame("Texture", "Reset Button", titleInfoFrame)
      resetButton:SetTexture("Rift", "NPCDialogIcon_questrepeatable.png.dds")
      resetButton:SetHeight(titleFIU:GetHeight())
      resetButton:SetWidth(titleFIU:GetHeight())
      resetButton:SetLayer(1)
      resetButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.resetInfoWindow() cD.resetLootWindow(true) end, "Reset Button Pressed" )
--       resetButton:SetPoint("TOPRIGHT", titleInfoFrame, "TOPRIGHT", - cD.borders.right, 1)
      resetButton:SetPoint("TOPRIGHT", iconizeButton, "TOPLEFT", -2, -1)
      cD.attachTT(resetButton, "reset")

      -- HEADER SHOW TOTALS WINDOW BUTTON
      local showTotalsButton = UI.CreateFrame("Texture", "totalsButton", titleInfoFrame)
      showTotalsButton:SetTexture("Rift", "reward_gold.png.dds")
      showTotalsButton:SetHeight(titleFIU:GetHeight())
      showTotalsButton:SetWidth(titleFIU:GetHeight())
      showTotalsButton:SetLayer(1)
      showTotalsButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsOBJ:SetVisible(not cD.window.totalsOBJ:GetVisible()) end, "Totals Button Pressed" )
--       showTotalsButton:SetPoint("TOPRIGHT", resetButton, "TOPLEFT", -2, 1)
      showTotalsButton:SetPoint("TOPRIGHT", resetButton, "TOPLEFT")
      cD.attachTT(showTotalsButton, "totwin")

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

         -- ZONE NAME CONTAINER Header
         local lbl1  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_zone_label", headerFrame)
         local objColor  =  cD.rarityColor("common")
--          lbl1:SetHeight(cD.text.base_font_size)
         lbl1:SetText("Zone    :")
         lbl1:SetFont(cD.addon, cD.text.base_font_name)
         lbl1:SetFontSize(cD.text.base_font_size)
         lbl1:SetLayer(1)
         lbl1:SetPoint("TOPLEFT",  headerFrame, "TOPLEFT")

            -- ZONE NAME Header [idx=1]
         local lineOBJ_2 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_zone", headerFrame)
         local objColor  =  cD.rarityColor("quest")
         lineOBJ_2:SetText(zone)
         lineOBJ_2:SetFont(cD.addon, cD.text.base_font_name)
         lineOBJ_2:SetFontSize(cD.text.base_font_size)
         lineOBJ_2:SetLayer(1)
         lineOBJ_2:SetFontColor(objColor.r, objColor.g, objColor.b)
         lineOBJ_2:SetPoint("TOPLEFT", lbl1, "TOPRIGHT", cD.borders.left, 0)
         table.insert(cD.sLThdrs, lineOBJ_2 )

         -- HEADER   -- SUB-ZONE NAME CONTAINER Header
         local lbl2  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_subzone_label", headerFrame)
--          lbl2:SetHeight(cD.text.base_font_size)
         lbl2:SetText("Subzone :")
         lbl2:SetFont(cD.addon, cD.text.base_font_name)
         lbl2:SetFontSize(cD.text.base_font_size)
         lbl2:SetLayer(1)
         lbl2:SetPoint("TOPLEFT",  lbl1, "BOTTOMLEFT",  0,  cD.borders.top/2)

         -- HEADER   -- SUB-ZONE NAME Header [idx=2]
         local lineOBJ_1 =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_subzone", headerFrame)
         local objColor  =  cD.rarityColor("rare") -- green
         lineOBJ_1:SetText(subZone)
         lineOBJ_1:SetFont(cD.addon, cD.text.base_font_name)
         lineOBJ_1:SetFontSize(cD.text.base_font_size)
         lineOBJ_1:SetLayer(1)
         lineOBJ_1:SetFontColor(objColor.r, objColor.g, objColor.b)
         lineOBJ_1:SetPoint("TOPLEFT", lbl2, "TOPRIGHT", cD.borders.left, 0)
         table.insert(cD.sLThdrs, lineOBJ_1 )

         -- HEADER   -- LABEL -- CASTS Header
         local labelCastsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals_label", headerFrame)
         local objColor  =  cD.rarityColor("common")
         labelCastsOBJ:SetText("Cst/Ctch:")
         labelCastsOBJ:SetFont(cD.addon, cD.text.base_font_name)
         labelCastsOBJ:SetFontSize(cD.text.base_font_size)
         labelCastsOBJ:SetLayer(1)
         labelCastsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
         labelCastsOBJ:SetPoint("TOPLEFT", lbl2, "BOTTOMLEFT", 0, cD.borders.top/2)

         -- HEADER   -- CASTS Header [idx=3]
         local castsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals", headerFrame)
         local objColor  =  cD.rarityColor("quest")
         castsOBJ:SetText(string.format("%5d", cD.today.casts))
         castsOBJ:SetFont(cD.addon, cD.text.base_font_name)
         castsOBJ:SetFontSize(cD.text.base_font_size)
         castsOBJ:SetLayer(1)
         castsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          castsOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "TOPRIGHT", cD.borders.left, 0)
         castsOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "TOPRIGHT")
         table.insert(cD.sLThdrs, castsOBJ )

         -- HEADER   -- SEPARATOR Header
         local sepOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green
         sepOBJ:SetText("/")
         sepOBJ:SetFont(cD.addon, cD.text.base_font_name)
         sepOBJ:SetFontSize(cD.text.base_font_size)
         sepOBJ:SetLayer(1)
         sepOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          sepOBJ:SetPoint("TOPLEFT", castsOBJ, "TOPRIGHT", cD.borders.right, 0)
         sepOBJ:SetPoint("TOPLEFT", castsOBJ, "TOPRIGHT")

         -- HEADER   -- TOTALS Header [idx=4]
         local lineOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green
         lineOBJ:SetText(totalsText)
         lineOBJ:SetFont(cD.addon, cD.text.base_font_name)
         lineOBJ:SetFontSize(cD.text.base_font_size)
         lineOBJ:SetLayer(1)
         lineOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          lineOBJ:SetPoint("TOPLEFT", sepOBJ, "TOPRIGHT", cD.borders.right, 0)
         lineOBJ:SetPoint("TOPLEFT", sepOBJ, "TOPRIGHT")
         table.insert(cD.sLThdrs, lineOBJ )

         -- HEADER -- LABEL  -- CAST TIMER Header
         local labelTimerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer", headerFrame)
         local objColor  =  cD.rarityColor("common") -- green
         labelTimerOBJ:SetText("Sec/Sess:")
         labelTimerOBJ:SetFont(cD.addon, cD.text.base_font_name)
         labelTimerOBJ:SetFontSize(cD.text.base_font_size)
         labelTimerOBJ:SetLayer(1)
         labelTimerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
         labelTimerOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "BOTTOMLEFT", 0, cD.borders.top/2)

         -- HEADER   -- CAST TIMER Header [idx=5]
         local timerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer_label", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green
         timerOBJ:SetText("--:--")
         timerOBJ:SetFont(cD.addon, cD.text.base_font_name)
         timerOBJ:SetFontSize(cD.text.base_font_size)
         timerOBJ:SetLayer(1)
         timerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          timerOBJ:SetPoint("TOPLEFT", labelTimerOBJ, "TOPRIGHT", cD.borders.left, 0)
         timerOBJ:SetPoint("TOPLEFT", labelTimerOBJ, "TOPRIGHT")
         table.insert(cD.sLThdrs, timerOBJ )

         -- HEADER   -- SEPARATOR Header
         local sep1OBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_separator_1", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green
         sep1OBJ:SetText("/")
         sep1OBJ:SetFont(cD.addon, cD.text.base_font_name)
         sep1OBJ:SetFontSize(cD.text.base_font_size)
         sep1OBJ:SetLayer(1)
         sep1OBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          sep1OBJ:SetPoint("TOPLEFT", timerOBJ, "TOPRIGHT", cD.borders.right, 0)
         sep1OBJ:SetPoint("TOPLEFT", timerOBJ, "TOPRIGHT")

         -- HEADER   -- DAY TIMER Header [idx=6]
         local dayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer", headerFrame)
         local objColor  =  cD.rarityColor("quest") -- green
         dayOBJ:SetText("--:--")
         dayOBJ:SetFont(cD.addon, cD.text.base_font_name)
         dayOBJ:SetFontSize(cD.text.base_font_size)
--          dayOBJ:SetHeight(cD.text.base_font_size)
         dayOBJ:SetLayer(1)
         dayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
--          dayOBJ:SetPoint("TOPLEFT", sep1OBJ, "TOPRIGHT", cD.borders.right, 0)
         dayOBJ:SetPoint("TOPLEFT", sep1OBJ, "TOPRIGHT")
         table.insert(cD.sLThdrs, dayOBJ )

      -- loot viewer
      local iconsFrame =  UI.CreateFrame("Frame", infoWindow:GetName() .. "_icons_frame", infoWindow)
      iconsFrame:SetPoint("TOPLEFT",     titleBar,   "BOTTOMRIGHT",  -(iconsize + cD.borders.right*2),	cD.borders.top*2)
      iconsFrame:SetPoint("TOPRIGHT",    titleBar,   "BOTTOMRIGHT", -cD.borders.right*2,  cD.borders.top*2)
      iconsFrame:SetPoint("BOTTOMLEFT",  infoWindow, "BOTTOMRIGHT",  -(iconsize + cD.borders.right*2),  -cD.borders.bottom)
      iconsFrame:SetPoint("BOTTOMRIGHT", infoWindow, "BOTTOMRIGHT", -cD.borders.right*2,  -cD.borders.bottom)
--       iconsFrame:SetBackgroundColor(1, 0, 0, 1)
      iconsFrame:SetLayer(2)
      table.insert(cD.sLThdrs, iconsFrame )

      -- loot window Widget
      local lwwidget = UI.CreateFrame("Texture", "Reset Button", infoWindow)
      lwwidget:SetTexture("Rift", "splitbtn_arrow_D_(normal).png.dds")
--       lwwidget:SetHeight(titleFIU:GetHeight())
--       lwwidget:SetWidth(titleFIU:GetHeight())
      lwwidget:SetLayer(1)
      lwwidget:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.lootOBJ:SetVisible(not cD.window.lootOBJ:GetVisible()) end, "lootwindow widget pressed" )
      lwwidget:SetPoint("BOTTOMRIGHT", infoWindow, "BOTTOMRIGHT", -(cD.borders.right*2), -cD.borders.bottom)
      cD.attachTT(lwwidget, "lootwin")

      headerFrame:SetHeight(cD.round(labelTimerOBJ:GetBottom() - headerFrame:GetTop()) + cD.borders.top + cD.borders.bottom)

      local bottom = infoWindow:GetTop() + titleBar:GetHeight() + headerFrame:GetHeight()
      infoWindow:SetHeight( bottom - infoWindow:GetTop() + cD.borders.top + cD.borders.bottom*2)

   -- Enable Dragging
   Library.LibDraggable.draggify(infoWindow, cD.updateGuiCoordinates)

   return infoWindow
end

function cD.resetIconsList()

--    displayedIcons =  {}

   for idx, tbl in pairs(cD.iconStock) do
      if tbl.inUse then
         --
         -- reset tooltip mouse events
         --
         local a,b,c,d
         local eventlist =  tbl.lootIcon:EventList(Event.UI.Input.Mouse.Cursor.In)
            for a,b in pairs(eventlist) do
               for c, d in pairs(b) do
                  print(string.format("a[%s] c[%s] d[%s]", a, c, d))
               end
               tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.In, b.handler, b.label)
            end
--          tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.In, eventlist[1].handler, eventlist[1].label)

         eventlist =  tbl.lootIcon:EventList(Event.UI.Input.Mouse.Cursor.Out)
            for a,b in pairs(eventlist) do
               for c, d in pairs(b) do
                  print(string.format("c[%s] d[%s]", c, d))
               end
               tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.Out, b.handler, b.label)
            end
--          tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.Out, eventlist[1].handler, eventlist[1].label)
      end

      tbl.inUse = false
   end

   displayedIcons =  {}

   return
end

function  cD.resetInfoWindow()
   --
   -- Reset Fields
   --
   local zone, subzone, zoneID = cD.getZoneInfos()
   cD.sLThdrs[1]:SetText(zone)
   cD.sLThdrs[2]:SetText(subzone)
   --
   cD.today.casts =  0
   cD.sLThdrs[3]:SetText(string.format("%5d", cD.today.casts))
   cD.sLThdrs[4]:SetText(string.format("%5d", 0))
   cD.sLThdrs[5]:SetText("--:--")
   cD.sLThdrs[6]:SetText("--:--")

   cD.resetIconsList()

   return
end

function buildIconForStock(parent, objID, quantity, zoneID)
--    local retval   =  nil

   local lootIcon    =  nil
   local lciFrame    =  nil
   local lootCatIcon =  nil
   local lootQuantity=  nil


   if parent and objID then
      print(string.format("parent[%s] objID[%s]", parent, objID))
      local o  =  Inspect.Item.Detail(objID)
      -- setup Loot Item's Icon
      lootIcon = UI.CreateFrame("Texture", "Loot_Icon_" .. o.name, parent)
      lootIcon:SetTexture("Rift", o.icon)
      lootIcon:SetWidth(iconsize)
      lootIcon:SetHeight(iconsize)
      -- are we second?
      if displayedIcons and displayedIcons[#displayedIcons] then
--          lootIcon:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 1)
         lootIcon:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, cD.borders.top*2)
      else
         lootIcon:SetPoint("TOPLEFT", parent, "TOPLEFT")
      end
      lootIcon:SetLayer(3)

      -- IF IT AIN'T JUNK WE ATTACH the TOOLTIP EVENTS!
      -- ToolTip  -----------------------------------------------------------------------------------------
      -- Mouse Hover IN    => show tooltip
      lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(zoneID, objID)  end, "Event.UI.Input.Mouse.Cursor.In")
      -- Mouse Hover OUT   => hide tooltip
      lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")
      -- ToolTip  -----------------------------------------------------------------------------------------

      -- category Icon
      local catIcon     =  cD.categoryIcon(o.category, objID, o.description, o.name)
--       if catIcon then
         lciFrame =  UI.CreateFrame("Frame", "Loot_Category_Icon_Frame" .. o.name, parent)
         lciFrame:SetWidth(cD.text.base_font_size)
         lciFrame:SetHeight(cD.text.base_font_size)
         lciFrame:SetBackgroundColor(.2, .2, .2, 0)
         lciFrame:SetLayer(4)
         lciFrame:SetPoint("TOPRIGHT", lootIcon, "TOPRIGHT")
         if catIcon  then lciFrame:SetVisible(true) else lciFrame:SetVisible(false) end
--       end

         lootCatIcon =  UI.CreateFrame("Texture", "Loot_Category_Icon_" .. o.name, parent)
         if catIcon then lootCatIcon:SetTexture("Rift", catIcon) end
         lootCatIcon:SetWidth(cD.text.base_font_size -2)
         lootCatIcon:SetHeight(cD.text.base_font_size -2)
         lootCatIcon:SetPoint("CENTER", lciFrame, "CENTER")
         lootCatIcon:SetLayer(5)
         if catIcon  then lootCatIcon:SetVisible(true) else lootCatIcon:SetVisible(false) end
--       end

      -- quantity
      lootQuantity  =  UI.CreateFrame("Text", "Loot_quantity_" .. o.name, parent)
      lootQuantity:SetFont(cD.addon, cD.text.base_font_name)
      lootQuantity:SetFontSize(cD.text.base_font_size -2)
      lootQuantity:SetBackgroundColor(0, 0, 0, .7)
      lootQuantity:SetText(string.format("<b>%d</b>", quantity), true)
      lootQuantity:SetLayer(4)
      lootQuantity:SetPoint("BOTTOMRIGHT",  lootIcon, "BOTTOMRIGHT")

      table.insert(cD.iconStock, { inUse=true, lootIcon=lootIcon, lootQuantity=lootQuantity, lootCatIcon=lootCatIcon })

--       retval   =  lootIcon
   else
      print(string.format("buildIconForStock: parent[%s] objID[%s]", parent, objID))
   end

   return lootIcon, lootCatIcon, lootQuantity
end

local function fetchIconFromStock(obj, quantity, zoneID)

   local retval   =  nil
   local gotStock =  nil

   if displayedIcons and displayedIcons[#displayedIcons] then
      parent = displayedIcons[#displayedIcons]
   else
      parent = cD.sLThdrs[7]
   end

   for idx, tbl in pairs(cD.iconStock) do
      if not tbl.inUse then
         -- set the frame as INUSE
         tbl.inUse   =  true
         gotStock    =  tbl

         break
      end
   end

   if not gotStock then
--       retval = buildIconForStock(parent, obj, quantity, zoneID)
      local lootIcon, lootCatIcon, lootQuantity =  buildIconForStock(parent, obj, quantity, zoneID)
      retval   =  lootIcon
   else
      local o  =  Inspect.Item.Detail(obj)
      gotStock.lootIcon:SetTexture("Rift", o.icon)

      local catIcon     =  cD.categoryIcon(o.category, objID, o.description, o.name)
      if catIcon then gotStock.lootCatIcon:SetTexture("Rift", catIcon) gotStock.lootCatIcon:SetVisible(true) else gotStock.lootCatIcon:SetVisible(false)end

      gotStock.lootQuantity:SetText(string.format("<b>%d</b>", quantity), true)

      -- IF IT AIN'T JUNK WE ATTACH the TOOLTIP EVENTS!
      -- ToolTip  -----------------------------------------------------------------------------------------
            -- Mouse Hover IN    => show tooltip
      gotStock.lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(zoneID, obj)  end, "Event.UI.Input.Mouse.Cursor.In")
      -- Mouse Hover OUT   => hide tooltip
      gotStock.lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")
      -- ToolTip  -----------------------------------------------------------------------------------------

      retval   =  gotStock.lootIcon
   end

   return retval
end


function cD.updateInfoIcons(o, quantity)
   local parent   =  nil

   if o  then
      local zoneID   =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
      local oo = Inspect.Item.Detail(o) print(string.format("o[%s] o.name[%s]", o, oo.name))

--       if cD.iconStock and cD.iconStock[#cD.iconStock] then
--          parent = cD.iconStock[#cD.iconStock].lootIcon
--       else
--          parent = cD.sLThdrs[7]
--       end

      local lootIcon =  fetchIconFromStock(o, quantity, zoneID)
      table.insert(displayedIcons, lootIcon)
      print("ADDED")
      print(string.format("loot Icon [%s]", lootIcon))
--       lootIcon:SetTexture("Rift", oo.icon)
   end

   return
end
