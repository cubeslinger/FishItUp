--
-- Addon       _fiu_gui_Info5.lua
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
--

local addon, cD = ...

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
      fiuIcon:SetHeight(cD.round(cD.text.base_font_size*1.5))
      fiuIcon:SetWidth(cD.round(cD.text.base_font_size*1.5))
      fiuIcon:SetLayer(1)
      fiuIcon:SetPoint("TOPLEFT", titleInfoFrame, "TOPLEFT", 0, -1)

      -- TITLE BAR TITLE
      local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleInfoFrame)
      titleFIU:SetFontSize(cD.text.base_font_size -2)
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
      iconizeButton:SetPoint("TOPRIGHT", titleInfoFrame, "TOPRIGHT", -cD.borders.right, 1)
      cD.attachTT(iconizeButton, "minimize")

      -- HEADER RESET BUTTON
      local resetButton = UI.CreateFrame("Texture", "Reset Button", titleInfoFrame)
      resetButton:SetTexture("Rift", "NPCDialogIcon_questrepeatable.png.dds")
      resetButton:SetHeight(titleFIU:GetHeight())
      resetButton:SetWidth(titleFIU:GetHeight())
      resetButton:SetLayer(1)
      resetButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.resetInfoWindow() cD.resetLootWindow(true) end, "Reset Button Pressed" )
      resetButton:SetPoint("TOPRIGHT", iconizeButton, "TOPLEFT", -cD.borders.right, -1)
      cD.attachTT(resetButton, "reset")

      -- HEADER SHOW TOTALS WINDOW BUTTON
      local showTotalsButton = UI.CreateFrame("Texture", "totalsButton", titleInfoFrame)
      showTotalsButton:SetTexture("Rift", "reward_gold.png.dds")
      showTotalsButton:SetHeight(titleFIU:GetHeight())
      showTotalsButton:SetWidth(titleFIU:GetHeight())
      showTotalsButton:SetLayer(1)
      showTotalsButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsOBJ:SetVisible(not cD.window.totalsOBJ:GetVisible()) end, "Totals Button Pressed" )
      showTotalsButton:SetPoint("TOPRIGHT", resetButton, "TOPLEFT", -cD.borders.right,0 )
      cD.attachTT(showTotalsButton, "totwin")

      -- loot window Widget
      local lwwidget = UI.CreateFrame("Texture", "Reset Button", titleInfoFrame)
      lwwidget:SetTexture("Rift", "scrollvert_chat_pgdwn_(normal).png.dds")
      lwwidget:SetHeight(titleFIU:GetHeight())
      lwwidget:SetWidth(titleFIU:GetHeight())
      lwwidget:SetLayer(1)
      lwwidget:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.lootOBJ:SetVisible(not cD.window.lootOBJ:GetVisible()) end, "lootwindow widget pressed" )
      lwwidget:SetPoint("TOPRIGHT", showTotalsButton, "TOPLEFT", -cD.borders.right,0 )
      cD.attachTT(lwwidget, "lootwin")

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

   infoWindow:SetWidth(cD.sizes.info[cD.text.base_font_size].winwidth)
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

         -- ZONE NAME CONTAINER Header
         local lbl1  =  UI.CreateFrame("Text", infoWindow:GetName() .. "_zone_label", headerFrame)
         local objColor  =  cD.rarityColor("common")
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
         lbl2:SetText("Subzone :")
         lbl2:SetFont(cD.addon, cD.text.base_font_name)
         lbl2:SetFontSize(cD.text.base_font_size)
         lbl2:SetLayer(1)
         lbl2:SetPoint("TOPLEFT",  lbl1, "BOTTOMLEFT")

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
         labelCastsOBJ:SetPoint("TOPLEFT", lbl2, "BOTTOMLEFT")

            -- HEADER   -- CASTS Header [idx=3]
            local castsOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_casts_totals", headerFrame)
            local objColor  =  cD.rarityColor("quest")
            castsOBJ:SetText(string.format("%5d", cD.today.casts))
            castsOBJ:SetFont(cD.addon, cD.text.base_font_name)
            castsOBJ:SetFontSize(cD.text.base_font_size)
            castsOBJ:SetLayer(1)
            castsOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
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
            sepOBJ:SetPoint("TOPLEFT", castsOBJ, "TOPRIGHT")

            -- HEADER   -- TOTALS Header [idx=4]
            local lineOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_header_totals", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            lineOBJ:SetText(totalsText)
            lineOBJ:SetFont(cD.addon, cD.text.base_font_name)
            lineOBJ:SetFontSize(cD.text.base_font_size)
            lineOBJ:SetLayer(1)
            lineOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
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
         labelTimerOBJ:SetPoint("TOPLEFT", labelCastsOBJ, "BOTTOMLEFT")

            -- HEADER   -- CAST TIMER Header [idx=5]
            local timerOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_session_timer_label", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            timerOBJ:SetText("--:--")
            timerOBJ:SetFont(cD.addon, cD.text.base_font_name)
            timerOBJ:SetFontSize(cD.text.base_font_size)
            timerOBJ:SetLayer(1)
            timerOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
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
            sep1OBJ:SetPoint("TOPLEFT", timerOBJ, "TOPRIGHT")

            -- HEADER   -- DAY TIMER Header [idx=6]
            local dayOBJ =  UI.CreateFrame("Text", infoWindow:GetName() .. "_day_timer", headerFrame)
            local objColor  =  cD.rarityColor("quest") -- green
            dayOBJ:SetText("--:--")
            dayOBJ:SetFont(cD.addon, cD.text.base_font_name)
            dayOBJ:SetFontSize(cD.text.base_font_size)
            dayOBJ:SetLayer(1)
            dayOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
            dayOBJ:SetPoint("TOPLEFT", sep1OBJ, "TOPRIGHT")
            table.insert(cD.sLThdrs, dayOBJ )

         -- HEADER   -- LABEL -- LOOT VIEWER Header
         local ifLabel =  UI.CreateFrame("Text", infoWindow:GetName() .. "_icons_frame_label", headerFrame)
         local objColor  =  cD.rarityColor("common")
         ifLabel:SetText("Looted  :")
         ifLabel:SetFont(cD.addon, cD.text.base_font_name)
         ifLabel:SetFontSize(cD.text.base_font_size)
         ifLabel:SetLayer(1)
         ifLabel:SetFontColor(objColor.r, objColor.g, objColor.b)
         ifLabel:SetPoint("TOPLEFT", labelTimerOBJ, "BOTTOMLEFT", 0, cD.borders.top/2)

            -- loot viewer
            local iconsFrame =  UI.CreateFrame("Frame", infoWindow:GetName() .. "_icons_frame", headerFrame)
            iconsFrame:SetHeight(cD.sizes.info[cD.text.base_font_size].iconsize)
            iconsFrame:SetLayer(2)
            iconsFrame:SetPoint("TOPLEFT", ifLabel, "TOPRIGHT", cD.borders.left, 0)
            table.insert(cD.sLThdrs, iconsFrame )

      headerFrame:SetHeight(cD.round(iconsFrame:GetBottom() - headerFrame:GetTop()) + cD.borders.top + cD.borders.bottom)

      local bottom = infoWindow:GetTop() + titleBar:GetHeight() + headerFrame:GetHeight()
      infoWindow:SetHeight( bottom - infoWindow:GetTop() + cD.borders.top + cD.borders.bottom*3)

   -- Enable Dragging
   Library.LibDraggable.draggify(infoWindow, cD.updateGuiCoordinates)

   return infoWindow
end

function cD.resetIconsList()

   for idx, tbl in pairs(cD.iconStock) do
      if tbl.inUse then
         --
         -- reset tooltip mouse events
         --
         local a,b,c,d
         local eventlist =  tbl.lootIcon:EventList(Event.UI.Input.Mouse.Cursor.In)
            for a,b in pairs(eventlist) do
               tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.In, b.handler, b.label)
            end

         eventlist =  tbl.lootIcon:EventList(Event.UI.Input.Mouse.Cursor.Out)
            for a,b in pairs(eventlist) do
               tbl.lootIcon:EventDetach(Event.UI.Input.Mouse.Cursor.Out, b.handler, b.label)
            end
      end

      tbl.inUse = false
      tbl.lootIcon:SetVisible(false)
      tbl.lootQuantity:SetVisible(false)
      tbl.lootCatIcon:SetVisible(false)
      tbl.lootTotal:SetVisible(false)
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

function buildIconForStock(parent, objID, quantity, zoneID, category, total)

   local lootIcon    =  nil
   local lciFrame    =  nil
   local lootCatIcon =  nil
   local lootQuantity=  nil


   if parent and objID then
      local o  =  Inspect.Item.Detail(objID)
      -- setup Loot Item's Icon
      lootIcon = UI.CreateFrame("Texture", "Loot_Icon_" .. o.name, parent)
      lootIcon:SetTexture("Rift", o.icon)
      lootIcon:SetWidth(cD.sizes.info[cD.text.base_font_size].iconsize)
      lootIcon:SetHeight(cD.sizes.info[cD.text.base_font_size].iconsize)

      -- are we second?
      if displayedIcons and displayedIcons[#displayedIcons] then
         lootIcon:SetPoint("TOPLEFT", parent, "TOPRIGHT", cD.borders.left, 0)
      else
         lootIcon:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 2)
      end

      lootIcon:SetLayer(3)

      -- IF IT AIN'T JUNK WE ATTACH the TOOLTIP EVENTS!
      -- Mouse Hover IN    => show tooltip
      lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(zoneID, objID)  end, "Event.UI.Input.Mouse.Cursor.In")
      -- Mouse Hover OUT   => hide tooltip
      lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")

      -- category Icon
      local catIcon     =  cD.categoryIcon(o.category, objID, o.description, o.name)
      lciFrame =  UI.CreateFrame("Frame", "Loot_Category_Icon_Frame" .. o.name, parent)
      lciFrame:SetWidth(cD.text.base_font_size)
      lciFrame:SetHeight(cD.text.base_font_size)
      lciFrame:SetBackgroundColor(.2, .2, .2, 0)
      lciFrame:SetLayer(4)
      lciFrame:SetPoint("TOPRIGHT", lootIcon, "TOPRIGHT")
      if catIcon  then lciFrame:SetVisible(true) else lciFrame:SetVisible(false) end

      lootCatIcon =  UI.CreateFrame("Texture", "Loot_Category_Icon_" .. o.name, parent)
      if catIcon then lootCatIcon:SetTexture("Rift", catIcon) end
      lootCatIcon:SetWidth(cD.text.base_font_size -2)
      lootCatIcon:SetHeight(cD.text.base_font_size -2)
      lootCatIcon:SetPoint("CENTER", lciFrame, "CENTER")
      lootCatIcon:SetLayer(5)
      if catIcon  then lootCatIcon:SetVisible(true) else lootCatIcon:SetVisible(false) end

      -- quantity
      lootQuantity  =  UI.CreateFrame("Text", "Loot_quantity_" .. o.name, parent)
      lootQuantity:SetFont(cD.addon, cD.text.base_font_name)
      lootQuantity:SetFontSize(cD.text.base_font_size -2)
      local col =   cD.rarityColor(category)
--       print(string.format("category[%s] col [%s] r[%s] g[%s] b[%s]", category, col, col.r, col.g, col.b))
      lootQuantity:SetFontColor(col.r, col.g, col.b)
      lootQuantity:SetBackgroundColor(0, 0, 0, .7)
      lootQuantity:SetText(string.format("<b>%d</b>", quantity), true)
      lootQuantity:SetLayer(4)
      lootQuantity:SetPoint("BOTTOMRIGHT",  lootIcon, "BOTTOMRIGHT")

      -- loot total
      lootTotal  =  UI.CreateFrame("Text", "Loot_total_" .. o.name, parent)
      lootTotal:SetFont(cD.addon, cD.text.base_font_name)
      lootTotal:SetFontSize(cD.text.base_font_size -2)
--       local col =   cD.rarityColor("common")
      --       print(string.format("category[%s] col [%s] r[%s] g[%s] b[%s]", category, col, col.r, col.g, col.b))
      lootTotal:SetFontColor(col.r, col.g, col.b)
      lootTotal:SetText(string.format("%d", total), true)
      lootTotal:SetLayer(4)
      lootTotal:SetPoint("TOPCENTER",  lootIcon, "BOTTOMCENTER", 0, -2)

      table.insert(cD.iconStock, { inUse=true, lootIcon=lootIcon, lootQuantity=lootQuantity, lootCatIcon=lootCatIcon, lootTotal=lootTotal })
   end

   return lootIcon, lootCatIcon, lootQuantity, lootTotal
end

local function fetchIconFromStock(obj, quantity, zoneID, category, total)

   local retval   =  {}
   local gotStock =  nil


   if displayedIcons and displayedIcons[#displayedIcons] then  parent = displayedIcons[#displayedIcons]
                                                         else  parent = cD.sLThdrs[7]
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
      local lootIcon, lootCatIcon, lootQuantity, lootTotal =  buildIconForStock(parent, obj, quantity, zoneID, category, total)
      retval   =  { lootIcon, lootCatIcon, lootQuantity, lootTotal }
   else
      local o  =  Inspect.Item.Detail(obj)
      gotStock.lootIcon:SetTexture("Rift", o.icon)
      gotStock.lootIcon:SetVisible(true)

      local catIcon     =  cD.categoryIcon(o.category, objID, o.description, o.name)
      if catIcon then
         gotStock.lootCatIcon:SetTexture("Rift", catIcon)
         gotStock.lootCatIcon:SetVisible(true)
      else
         gotStock.lootCatIcon:SetVisible(false)
      end

      gotStock.lootQuantity:SetText(string.format("<b>%d</b>", quantity), true)
      local col =   cD.rarityColor(category)
--       print(string.format("category[%s] col [%s] r[%s] g[%s] b[%s]", category, col, col.r, col.g, col.b))
      gotStock.lootQuantity:SetFontColor(col.r, col.g, col.b)
      gotStock.lootQuantity:SetVisible(true)

      gotStock.lootTotal:SetText(string.format("%d", total), true)
      gotStock.lootTotal:SetFontColor(col.r, col.g, col.b)
      gotStock.lootTotal:SetVisible(true)

      -- IF IT AIN'T JUNK WE ATTACH the TOOLTIP EVENTS!
      -- Mouse Hover IN    => show tooltip
      gotStock.lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(zoneID, obj)  end, "Event.UI.Input.Mouse.Cursor.In")
      -- Mouse Hover OUT   => hide tooltip
      gotStock.lootIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")

      retval   =  { gotStock.lootIcon, gotStock.lootQuantity, gotStock.lootCatIcon, gotStock.lootTotal }
   end

   return retval
end


function cD.updateInfoIcons(o, quantity)
   local parent   =  nil

   if o  then
      local zoneID   =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
      local oo = Inspect.Item.Detail(o) -- print(string.format("o[%s] o.name[%s]", o, oo.name))

      -- get session quantity for this item
      -- is it junk?
      local idx
      if oo.rarity == "sellable" then
         local jnkName  =  Inspect.Item.Detail(cD.junkOBJ).name
         idx   =  cD.searchloottable(cD.junkOBJ, Inspect.Item.Detail(cD.junkOBJ).name)
      else
         idx   =  cD.searchloottable(o, oo.name)
      end

      local total =  0
      if idx   then  total =  cD.sLTcnts[idx] end

--       print(string.format("o[%s] oo.name[%s] idx[%s] total=[%s]", o, oo.name, idx, idx, total))

      local retval = fetchIconFromStock(o, quantity, zoneID, oo.rarity, total)
      local lootIcon, lootQuantity, lootCatIcon, lootTotal = unpack(retval)
      table.insert(displayedIcons, lootIcon)
   end

   return
end
