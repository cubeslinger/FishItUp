--
-- Addon       _fiu_gui_TotAndcache.lua
-- Author      marcob@marcob.org
-- StartDate   08/04/2017
-- StartDate   09/03/2017
--

local addon, cD = ...

cD.sTOFrames                  =  {}

-- local TITLEBARTOTALSFRAME     =  1
-- local TITLEBARTCONTENTFRAME   =  2
-- local EXTERNALTOTALSFRAME     =  3
-- local TOTALSMASKFRAME         =  4
-- local TOTALSFRAME             =  5
-- local TOTALSFRAMESCROLL       =  6
-- local STATUSBARTOTALSFRAME    =  7
-- local STATUSBARTFRAME         =  8

local tWINWIDTH               =  540
local tWINHEIGHT              =  276
local tMAXSTRINGSIZE          =  30
local tMAXLABELSIZE           =  200

-- Merged _fiu_gui_Cache.lua
local zlFrames                =  {}
local znListWIDTH             =  158
local sbWIDTH                 =  8
local tfScroll                =  nil   -- Totals Frame ScrollBar
local cfScroll                =  nil   -- Cache Items ScrollBar
local tlScrollStep            =  1
local ilScrollStep            =  1
local magicNumber             =  7.5
local ILStock                 =  {}
local lastZnSelected          =  nil
local lastBGused              =  {}
cD.sCACFrames                 =  {}
local itemsMaxLENGTH          =  40
local tLOOTNAMESIZE           =  172
local tITEMNAMESIZE           =  170
local visibleItems            =  9     -- Number of items details fully displayed in Cache window
local ivNAMESIZE              =  20

--     1        2        3       4    5      6      7
-- sellable, common, uncommon, rare, epic, quest, relic
local txtColors   =  {}
txtColors[1]   =  { r = .34375, g = .34375, b = .34375 } -- sellable
txtColors[2]   =  { r = .98,    g = .98,    b = .98 }    -- common / nil
txtColors[3]   =  { r = 0,      g = .797,   b = 0 }      -- uncommon
txtColors[4]   =  { r = .148,   g = .496,   b = .977 }   -- rare
txtColors[5]   =  { r = .676,   g = .281,   b = .98 }    -- epic
txtColors[6]   =  { r = 1,      g = 1,      b = 0 }      -- quest
txtColors[7]   =  { r = 1,      g = .5,     b = 0 }      -- relic
txtColors[8]   =  { r = 1,      g = 1,      b = 0 }      -- MfJ yellow
txtColors[9]   =  { r = .98,    g = .98,    b = .98 }    -- Totals white



--- Pads str to length len with char from right
local function lpad(str, len, char)
   if char == nil then char = ' ' end
--    return str .. string.rep(char, len - #str)
   return string.rep(char, len - #str) .. str
end

local function reverseTable(t)
   local reversedTable = {}
   local itemCount = #t
   for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
   end
   return reversedTable
end

local function buildForStock(parent,t)

   local first    = true
   local lastobj  =  nil

   if parent == nil then
      parent = cD.sCACFrames.cacheitemsframe
   else
      first = false
   end

   local zil, zilIcon, zilName, zilDesc, zilCat = nil, nil, nil, nil, nil

   zil =  UI.CreateFrame("Frame", "Zone_item_Frame", cD.sCACFrames.cacheitemsframe)
   zil:SetBackgroundColor(.2, .2, .2, .6)
   if cD.totallineheight then
--       print("HIT")
      zil:SetHeight(cD.totallineheight)
   else
      zil:SetHeight((lootIcon:GetBottom() + cD.borders.bottom ) - zil:GetTop())
   end
--    print("ZIL ["..zil:GetHeight().."]")

   if first then
      first = false
--       zil:SetPoint("TOPLEFT",  cD.sCACFrames.cacheitemsframe, "TOPLEFT",  0, 1)
--       zil:SetPoint("TOPRIGHT", cD.sCACFrames.cacheitemsframe, "TOPRIGHT", 0, 1)
      zil:SetPoint("TOPLEFT",  cD.sCACFrames.cacheitemsframe, "TOPLEFT",  0, 1)
      zil:SetPoint("TOPRIGHT", cD.sCACFrames.cacheitemsframe, "TOPRIGHT", 0, 1)


   else
--       zil:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT",  1,  1)
--       zil:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 1,  1)
      zil:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT", 0, 1)
      zil:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT",0, 1)


   end
   zil:SetLayer(3)

   local lootCnt  =  UI.CreateFrame("Text", "Loot_Cnt_" .. t.name, zil)
   local objColor =  cD.rarityColor("quest")
   lootCnt:SetFont(cD.addon, cD.text.base_font_name)
   lootCnt:SetFontSize(cD.text.base_font_size)
   lootCnt:SetFontColor(objColor.r, objColor.g, objColor.b)
   lootCnt:SetText(string.format("%3d", 0), true)
   lootCnt:SetLayer(3)
   lootCnt:SetPoint("TOPLEFT",   zil, "TOPLEFT", cD.borders.left, -1)

   -- Item's Type Icon
   local typeIcon = UI.CreateFrame("Texture", "Type_Icon_" .. t.name, zil)
   local categoryIcon  =  nil
   categoryIcon  =  cD.categoryIcon(t.category, t.id, t.description, t.name)
   if  categoryIcon ~= nil then typeIcon:SetTexture("Rift", categoryIcon)  end
   typeIcon:SetWidth(cD.text.base_font_size)
   typeIcon:SetHeight(cD.text.base_font_size)
   typeIcon:SetPoint("TOPLEFT",   lootCnt, "TOPRIGHT", cD.borders.left, 4)
   typeIcon:SetLayer(3)

   -- Item's Icon
   local lootIcon = UI.CreateFrame("Texture", "Loot_Icon_" .. t.name, zil)
   lootIcon:SetTexture("Rift", t.icon)
   lootIcon:SetWidth(cD.text.base_font_size)
   lootIcon:SetHeight(cD.text.base_font_size)
   lootIcon:SetPoint("TOPLEFT",   typeIcon, "TOPRIGHT", cD.borders.left, 0)
   lootIcon:SetLayer(3)

   -- Item's Name
   local textOBJ     =  UI.CreateFrame("Text", "Loot_" .. t.name, zil)
   local objRarity   =  t.rarity
   if objRarity == nil then objRarity   =  "common" end
   local objColor =  cD.rarityColor(objRarity)
   textOBJ:SetFont(cD.addon, cD.text.base_font_name)
   textOBJ:SetFontSize(cD.text.base_font_size)
   textOBJ:SetWidth(tLOOTNAMESIZE)
   textOBJ:SetText(t.name:sub(1, ivNAMESIZE))
   textOBJ:SetLayer(3)
   textOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   textOBJ:SetPoint("TOPLEFT",   lootIcon,    "TOPRIGHT", cD.borders.left, -4)
--    textOBJ:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(t.zone, t.id) end, "Item Selected" )

   -- Item's Value/Total
   -- item's Value
   local zilMfJ  =  UI.CreateFrame("Text", "Loot_Cnt_" .. t.name, zil)
   zilMfJ:SetFont(cD.addon, cD.text.base_font_name)
   zilMfJ:SetFontSize(cD.text.base_font_size - 2)
   zilMfJ:SetText(string.format("%s/%s", cD.printJunkMoney(t.value), cD.printJunkMoney(0)), true)
--    zilMfJ:SetWidth(lootCnt:GetWidth())
   zilMfJ:SetLayer(3)
   zilMfJ:SetPoint("TOPLEFT", textOBJ, "TOPRIGHT", cD.borders.left, 1)
--    zilMfJ:SetPoint("RIGHT", zil, "RIGHT")

   local retval=  {}
   retval   =  {
               inUse    =  true,
               zil      =  zil,
               zilCount =  lootCnt,
               zilTIcon =  typeIcon,
               zilIIcon =  lootIcon,
               zilName  =  textOBJ,
               zilMfJ   =  zilMfJ,
               }

   table.insert(ILStock, retval)

--    if cD.totallineheight then
--       print("HIT")
--       zil:SetHeight(cD.totallineheight)
--    else
--       zil:SetHeight((lootIcon:GetBottom() + cD.borders.bottom ) - zil:GetTop())
--    end
--    print("ZIL ["..zil:GetHeight().."]")

   return(retval)
end

local function fetchFromILStock(parent,t)
   local idx, tbl =  nil, {}
   local retval   =  nil

   for idx, tbl in pairs(ILStock) do
      if not tbl.inUse then
         retval = tbl
         -- set the frame as INUSE
         ILStock[idx].inUse     =  true
         break
      end
   end

   if not retval then
      retval = buildForStock(parent,t)
--       print("CREATING new from Stock")
   else
--       print("REUSING  old from Stock")
   end

   return retval
end

function cD.getCharScore(zID, oID)
   local retval   =  0

--    print("cD.getCharScore zone["..zID.."] oID["..oID.."]")

   if cD.charScore[zID] then
      local t = cD.charScore[zID]
      if t[oID] then
         retval = t[oID]
      end
   end

--    print("cD.getCharScore retval["..retval.."]")

   return retval
end

local function createZoneItemLine(parent, zoneName, zID, t)

   local zil, zilTIcon, zilIIcon, zilCount, zilName, zilDesc   =	nil, nil, nil, nil, nil, nil
   local fromILStock = fetchFromILStock(parent,t)

   zil      =  fromILStock.zil
   zilCount =  fromILStock.zilCount
   zilTIcon =  fromILStock.zilTIcon
   zilIIcon =  fromILStock.zilIIcon
   zilName  =  fromILStock.zilName
   zilMfJ   =  fromILStock.zilMfJ

   -- Item Counter
   local cnt = cD.getCharScore(zID, t.id)
   zilCount:SetText(string.format("%3d", cnt), true)

   -- Type Icon
   local categoryIcon  =  cD.categoryIcon(t.category, t.id, t.description, t.name)
   if categoryIcon then
      zilTIcon:SetTexture("Rift", categoryIcon)
      zilTIcon:SetVisible(true)
   else
      zilTIcon:SetVisible(false)
   end

   -- Item Icon
   zilIIcon:SetTexture("Rift", t.icon)

   -- Item Name
   local txtColor =  cD.rarityColor(t.rarity)
   zilName:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
   zilName:SetHeight(cD.text.base_font_size)
   zilName:SetText(t.name:sub(1, ivNAMESIZE))
   zilName:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(t.zone, t.id) end, "Item Selected" )
   -- ZZZZ  -----------------------------------------------------------------------------------------
   -- Mouse Hover IN    => show tooltip
   zilName:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(t.zone, t.id)  end, "Event.UI.Input.Mouse.Cursor.In")
   -- Mouse Hover OUT   => show tooltip
   zilName:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")

   -- ZZZZ  -----------------------------------------------------------------------------------------

   -- Item Value/Total
   local cnt = cD.getCharScore(zID, t.id)
   local mfj = t.value * cnt
--    print("MFJ 1 ["..cD.printJunkMoney(t.value).."]")
--    print("MFJ 2 ["..cD.printJunkMoney(mfj).."]")
   zilMfJ:SetText(string.format("%s/%s", cD.printJunkMoney(t.value), cD.printJunkMoney(mfj)), true)

   zil:SetHeight(cD.round(cD.borders.top + cD.borders.bottom + cD.text.base_font_size))
   zil:SetVisible(true)

--    print("zil HEIGHT ["..zil:GetHeight().."]")

   return zil
end


local function resetZoneItemsList()
   --
   -- Set all ILStock Frames to "invisible"
   -- and set all ILStock[].used = false
   --
   local idx, tbl = nil, {}
   for idx, tbl in pairs(ILStock) do
      tbl.inUse = false
      tbl.zil:SetVisible(false)
      tbl.zilName:EventDetach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(t.zone, t.id) end, "Item Selected" )
   end

   -- reparent itemFrame to MaskFrame to reset ScrollBar movements
   cD.sCACFrames.cacheitemsframe:ClearPoint("TOPLEFT")
   cD.sCACFrames.cacheitemsframe:ClearPoint("BOTTOMLEFT")
   cD.sCACFrames.cacheitemsframe:SetPoint("TOPLEFT", cD.sCACFrames.cacheitemsmaskframe, "TOPLEFT")

   return
end

--[[ ]]--
local function populateZoneItemsList(znID, zoneName)
   local parent   =  nil
   local cnt      =  0
   local iobj     =  nil
   local base     =  cD.charScore[znID]

--    for x,y in pairs(base) do print(string.format("++x[%s] y[%s]", x, y)) end

   for k,v in cD.spairs(base,
                        function(t,a,b)
                           local retval = nil
--                            print("--["..a.."]["..b.."]")
                           if b == "__orderedIndex" then
                              b = 0
                              a = 0
--                               print("skipping")
                              retval   =  nil
                           else
--                               print("//["..t[a].."]["..t[b].."]")
                              retval   =  t[b] < t[a]
                           end
                           return retval
                        end) do
--       print(k,v)

      if k ~= "__orderedIndex" then
         local tbl=  cD.itemCache[k]
         local z  =  createZoneItemLine(parent, zoneName, znID, tbl)
         parent   =  z
         cnt      =  cnt + 1
      end
   end


--    print("CNT {"..cnt.."}{"..visibleItems.."}")
   if cnt > visibleItems then
      cfScroll:SetVisible(true)
      cfScroll:SetEnabled(true)
      --       print("PRE HEIGHT   ["..cD.sCACFrames.cacheitemsframe:GetHeight().."]")

      local baseY =  cD.sCACFrames.cacheitemsframe:GetTop()
      local maxY  =  parent:GetBottom()

      cD.sCACFrames.cacheitemsframe:SetHeight(cD.round(maxY - baseY))
      --       print("POST HEIGHT  ["..cD.sCACFrames.cacheitemsframe:GetHeight().."]")

      cfScroll:SetRange(1, cnt - visibleItems)
      ilScrollStep   =  cD.round(cD.sCACFrames.cacheitemsframe:GetHeight()/cnt)

      --       print("ilScrollStep ["..ilScrollStep.."]")
      --       print("SETTING VISIBLE")
   else
      cfScroll:SetVisible(false)
      cfScroll:SetEnabled(false)
      --       print("SETTING INVISIBLE")
   end

   return
end

--[[ ]]--

local function selectZone(znID, zoneName)
   local unsel =  cD.rarityColor("common")
   local sel   =  cD.rarityColor("relic")
   local obj   =  nil

   -- reset last selected elemenent highlight
   if lastZnSelected ~= nil then
      lastZnSelected:SetBackgroundColor(lastBGused.r, lastBGused.g, lastBGused.b, lastBGused.a)
   end
   --
   -- Highligth selected Zone
   --
   -- flip/flop ?
   --
   if lastZnSelected ~= zlFrames[zoneName]   then
      lastBGused.r, lastBGused.g, lastBGused.b, lastBGused.a = zlFrames[zoneName]:GetBackgroundColor()
      zlFrames[zoneName]:SetBackgroundColor(.6, .6, .6, .6)
      lastZnSelected =  zlFrames[zoneName]

      cD.sTOFrames.totalsrightmaskframe:SetVisible(false)
      cD.sTOFrames.totalsrightframe:SetVisible(false)
      cD.sTOFrames.totalsframescroll:SetVisible(false)

      resetZoneItemsList()
      populateZoneItemsList(znID, zoneName)

      cD.sCACFrames.cacheitemsextframe:SetVisible(true)
      cD.sCACFrames.cacheitemsscroll:SetVisible(true)
   else
      cD.sCACFrames.cacheitemsextframe:SetVisible(false)
      cD.sCACFrames.cacheitemsscroll:SetVisible(false)
      --
      cD.sTOFrames.totalsrightmaskframe:SetVisible(true)
      cD.sTOFrames.totalsrightframe:SetVisible(true)
      cD.sTOFrames.totalsframescroll:SetVisible(true)

      lastZnSelected =  nil
      lastBGused     =  {}
   end

   return
end


function cD.createTotalsWindow()

   cD.sTOFrames   =  {}

   --Global context (parent frame-thing).
   local context = UI.CreateContext("Totals_context")

   local totalsWindow    =  UI.CreateFrame("Frame", "Totals", context)

   if cD.window.totalsX == nil or cD.window.totalsY == nil then
      -- first run, we position in the screen center
      totalsWindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      totalsWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.totalsX or 0, cD.window.totalsY or 0)
   end

   totalsWindow:SetWidth(tWINWIDTH)
   totalsWindow:SetHeight(tWINHEIGHT)
   totalsWindow:SetLayer(-1)
   totalsWindow:SetBackgroundColor(0, 0, 0, .5)

   -- TITLE BAR CONTAINER
   local titleTotalsFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   titleTotalsFrame:SetPoint("TOPLEFT",     totalsWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleTotalsFrame:SetPoint("TOPRIGHT",    totalsWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleTotalsFrame:SetBackgroundColor(.1, .1, .1, .6)
   titleTotalsFrame:SetLayer(1)
   titleTotalsFrame:SetHeight(cD.text.base_font_size + 4)
   cD.sTOFrames.titlebartotalsframe  =   titleTotalsFrame

      -- TITLE BAR TITLE
      local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleTotalsFrame)
      titleFIU:SetFontSize(cD.text.base_font_size)
      titleFIU:SetText("FIU! Lifetime Totals")
      titleFIU:SetFont(cD.addon, cD.text.base_font_name)
      titleFIU:SetLayer(3)
      titleFIU:SetPoint("TOPLEFT", cD.sTOFrames.titlebartotalsframe, "TOPLEFT", cD.borders.left, 0)
      cD.sTOFrames.titlebarcontentframe  =   titleFIU


      -- TITLE BAR Widgets: setup Icon for Iconize
      lootIcon = UI.CreateFrame("Texture", "Title_Icon_1", cD.sTOFrames.titlebartotalsframe)
      lootIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
      lootIcon:SetWidth(cD.text.base_font_size)
      lootIcon:SetHeight(cD.text.base_font_size)
      lootIcon:SetPoint("TOPRIGHT",   cD.sTOFrames.titlebartotalsframe, "TOPRIGHT", -cD.borders.right, 0)
      lootIcon:SetLayer(3)
      lootIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsOBJ:SetVisible(not cD.window.totalsOBJ:GetVisible()) end , "Iconize Totals Pressed" )

      titleTotalsFrame:SetHeight(cD.text.base_font_size + 6)

   -- EXTERNAL TOTALS CONTAINER FRAME
   local totalsExtFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   totalsExtFrame:SetPoint("TOPLEFT",     cD.sTOFrames.titlebartotalsframe, "BOTTOMLEFT",  cD.borders.left,    1)
   totalsExtFrame:SetPoint("TOPRIGHT",    cD.sTOFrames.titlebartotalsframe, "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), 1)
   totalsExtFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                      "BOTTOMLEFT",  cD.borders.left,    - cD.borders.bottom)
   totalsExtFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                      "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), - cD.borders.bottom)
--    totalsExtFrame:SetBackgroundColor(.2, .2, .2, .6)
   totalsExtFrame:SetLayer(1)
   cD.sTOFrames.externaltotalsframe  =   totalsExtFrame

      -- TOTALS MASK FRAME LEFT
      local leftMaskFrame = UI.CreateFrame("Mask", "Totals_Left_Mask_Frame", cD.sTOFrames.externaltotalsframe)
      leftMaskFrame:SetPoint("TOPLEFT",      cD.sTOFrames.externaltotalsframe, "TOPLEFT")
--       leftMaskFrame:SetPoint("TOPRIGHT",     cD.sTOFrames.externaltotalsframe, "TOPLEFT",    cD.borders.left + znListWIDTH, 0)
      leftMaskFrame:SetPoint("TOPRIGHT",     cD.sTOFrames.externaltotalsframe, "TOPLEFT",    znListWIDTH, 0)
      leftMaskFrame:SetPoint("BOTTOMLEFT",   cD.sTOFrames.externaltotalsframe, "BOTTOMLEFT")
--       leftMaskFrame:SetPoint("BOTTOMRIGHT",  cD.sTOFrames.externaltotalsframe, "BOTTOMLEFT", cD.borders.left + znListWIDTH, 0)
      leftMaskFrame:SetPoint("BOTTOMRIGHT",  cD.sTOFrames.externaltotalsframe, "BOTTOMLEFT", znListWIDTH, 0)
      cD.sTOFrames.totalsleftmaskframe  = leftMaskFrame

      -- TOTALS CONTAINER FRAME LEFT
      local totalsleftFrame =  UI.CreateFrame("Frame", "left_loot_frame", cD.sTOFrames.totalsleftmaskframe)
      totalsleftFrame:SetAllPoints(cD.sTOFrames.totalsleftmaskframe)
      totalsleftFrame:SetLayer(1)
   --    totalsleftFrame:SetBackgroundColor(1, 0, 0, .6)
      cD.sTOFrames.totalsleftframe  =   totalsleftFrame

      -- TOTALS MASK FRAME RIGHT
      local rightMaskFrame = UI.CreateFrame("Mask", "Totals_Right_Mask_Frame", cD.sTOFrames.externaltotalsframe)
--       rightMaskFrame:SetPoint("TOPLEFT",      cD.sTOFrames.externaltotalsframe, "TOPLEFT",    cD.borders.right + znListWIDTH + 1, 0)
      rightMaskFrame:SetPoint("TOPLEFT",      cD.sTOFrames.externaltotalsframe, "TOPLEFT",    znListWIDTH, 0)
      rightMaskFrame:SetPoint("TOPRIGHT",     cD.sTOFrames.externaltotalsframe, "TOPRIGHT")
--       rightMaskFrame:SetPoint("BOTTOMLEFT",   cD.sTOFrames.externaltotalsframe, "BOTTOMLEFT", cD.borders.right + znListWIDTH + 1, 0)
      rightMaskFrame:SetPoint("BOTTOMLEFT",   cD.sTOFrames.externaltotalsframe, "BOTTOMLEFT", znListWIDTH, 0)
      rightMaskFrame:SetPoint("BOTTOMRIGHT",  cD.sTOFrames.externaltotalsframe, "BOTTOMRIGHT")
      cD.sTOFrames.totalsrightmaskframe  = rightMaskFrame

      -- TOTALS CONTAINER FRAME RIGHT
      local totalsrightFrame =  UI.CreateFrame("Frame", "right_loot_frame", cD.sTOFrames.totalsrightmaskframe)
      totalsrightFrame:SetAllPoints(cD.sTOFrames.totalsrightmaskframe)
   --    totalsrightFrame:SetBackgroundColor(0, 1, 0, .6)
      totalsrightFrame:SetLayer(1)
      cD.sTOFrames.totalsrightframe  =   totalsrightFrame

   -- TOTALS ZONE ITEMS SCROLLBAR (BOTH)
   tfScroll = UI.CreateFrame("RiftScrollbar","Totals_Frame_scrollbar", cD.sTOFrames.externaltotalsframe)
   tfScroll:SetVisible(false)
   tfScroll:SetEnabled(false)
   tfScroll:SetWidth(sbWIDTH)
   tfScroll:SetOrientation("vertical")
   tfScroll:SetPoint("TOPLEFT",     cD.sTOFrames.externaltotalsframe,  "TOPRIGHT",    -(cD.borders.right/2)+1, 0)
   tfScroll:SetPoint("BOTTOMLEFT",  cD.sTOFrames.externaltotalsframe,  "BOTTOMRIGHT", -(cD.borders.right/2)+1, 0)
   tfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                           function()
                              local pos = tfScroll:GetPosition()
                              cD.sTOFrames.totalsrightframe:SetPoint("TOPLEFT", cD.sTOFrames.totalsrightmaskframe, "TOPLEFT", 0, -math.floor(tlScrollStep*pos) )
                              cD.sTOFrames.totalsleftframe:SetPoint( "TOPLEFT", cD.sTOFrames.totalsleftmaskframe,  "TOPLEFT", 0, -math.floor(tlScrollStep*pos) )
                           end,
                           "TotalsFrame_Scrollbar.Change"
                        )
   cD.sTOFrames.totalsframescroll  =   tfScroll

   --
   -- STATUS BAR - begin -------------------------------------------------------------------------------------------------------------------------------
   --
   -- STATUS BAR CONTAINER
   local statusBarFrame =  UI.CreateFrame("Frame", "External_statusBar_Frame", totalsWindow)
   statusBarFrame:SetPoint("TOPLEFT",     totalsWindow, "BOTTOMLEFT")
   statusBarFrame:SetPoint("TOPRIGHT",    totalsWindow, "BOTTOMRIGHT")
   statusBarFrame:SetBackgroundColor(0, 0, 0, .6)
   statusBarFrame:SetLayer(1)
   statusBarFrame:SetHeight(cD.text.base_font_size + 4)
   cD.sTOFrames.statusbartotalsframe  =   statusBarFrame

      -- How many Zones
      local zonesCnt =  UI.CreateFrame("Text", "zonesCnt", statusBarFrame)
      zonesCnt:SetFontSize(cD.text.base_font_size)
      zonesCnt:SetText(string.format("%s", "Totals:"), true)
      zonesCnt:SetFont(cD.addon, cD.text.base_font_name)
      zonesCnt:SetLayer(3)
      zonesCnt:SetPoint("TOPLEFT", cD.sTOFrames.statusbartotalsframe, "TOPLEFT", cD.borders.left, -2)
      cD.sTOFrames.sbzonescounter  =   zonesCnt

      -- How many sellables/junk
      local jnkCnt =  UI.CreateFrame("Text", "jnkCnt", statusBarFrame)
      jnkCnt:SetFontSize(cD.text.base_font_size)
      jnkCnt:SetText(string.format("%3d", 0), true)
      jnkCnt:SetFont(cD.addon, cD.text.base_font_name)
      jnkCnt:SetFontColor(txtColors[1].r, txtColors[1].g, txtColors[1].b)
      jnkCnt:SetLayer(3)
      jnkCnt:SetPoint("TOPLEFT", cD.sTOFrames.statusbartotalsframe, "TOPLEFT", cD.borders.left + znListWIDTH + 2 + cD.borders.left, -2)
      cD.sTOFrames.sbjnkcounter  =   jnkCnt

      -- How many common intems
      local comCnt =  UI.CreateFrame("Text", "commonCnt", statusBarFrame)
      comCnt:SetFontSize(cD.text.base_font_size)
      comCnt:SetText(string.format("%3d", 0), true)
      comCnt:SetFont(cD.addon, cD.text.base_font_name)
      comCnt:SetFontColor(txtColors[2].r, txtColors[2].g, txtColors[2].b)
      comCnt:SetLayer(3)
      comCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbjnkcounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbcomcounter  =   comCnt

      -- How many uncommon intems
      local uncCnt =  UI.CreateFrame("Text", "uncommonCnt", statusBarFrame)
      uncCnt:SetFontSize(cD.text.base_font_size)
      uncCnt:SetText(string.format("%3d", 0), true)
      uncCnt:SetFont(cD.addon, cD.text.base_font_name)
      uncCnt:SetFontColor(txtColors[3].r, txtColors[3].g, txtColors[3].b)
      uncCnt:SetLayer(3)
      uncCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbcomcounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbunccounter  =   uncCnt

      -- How many rare intems
      local rarCnt =  UI.CreateFrame("Text", "rareCnt", statusBarFrame)
      rarCnt:SetFontSize(cD.text.base_font_size)
      rarCnt:SetText(string.format("%3d", 0), true)
      rarCnt:SetFontColor(txtColors[4].r, txtColors[4].g, txtColors[4].b)
      rarCnt:SetFont(cD.addon, cD.text.base_font_name)
      rarCnt:SetLayer(3)
      rarCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbunccounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbrarcounter  =   rarCnt

      -- How many epic intems
      local epcCnt =  UI.CreateFrame("Text", "epicCnt", statusBarFrame)
      epcCnt:SetFontSize(cD.text.base_font_size)
      epcCnt:SetText(string.format("%3d", 0), true)
      epcCnt:SetFont(cD.addon, cD.text.base_font_name)
      epcCnt:SetFontColor(txtColors[5].r, txtColors[5].g, txtColors[5].b)
      epcCnt:SetLayer(3)
      epcCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbrarcounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbepccounter  =   epcCnt

      -- How many quest intems
      local qstCnt =  UI.CreateFrame("Text", "questCnt", statusBarFrame)
      qstCnt:SetFontSize(cD.text.base_font_size)
      qstCnt:SetText(string.format("%3d", 0), true)
      qstCnt:SetFontColor(txtColors[6].r, txtColors[6].g, txtColors[6].b)
      qstCnt:SetFont(cD.addon, cD.text.base_font_name)
      qstCnt:SetLayer(3)
      qstCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbepccounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbqstcounter  =   qstCnt

      -- How many relic intems
      local rlcCnt =  UI.CreateFrame("Text", "relicCnt", statusBarFrame)
      rlcCnt:SetFontSize(cD.text.base_font_size)
      rlcCnt:SetText(string.format("%3d", 0), true)
      rlcCnt:SetFont(cD.addon, cD.text.base_font_name)
      rlcCnt:SetFontColor(txtColors[7].r, txtColors[7].g, txtColors[7].b)
      rlcCnt:SetLayer(3)
      rlcCnt:SetPoint("TOPLEFT", cD.sTOFrames.sbqstcounter, "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames.sbrlccounter  =   rlcCnt

      -- total of MfJ
      local totMfJ	=  UI.CreateFrame("Text", "mfjCnt", statusBarFrame)
      totMfJ:SetFontSize(cD.text.base_font_size)
      totMfJ:SetText(string.format("%10s", cD.printJunkMoney(0)), true)
      totMfJ:SetFont(cD.addon, cD.text.base_font_name)
      totMfJ:SetFontColor(txtColors[7].r, txtColors[7].g, txtColors[7].b)
      totMfJ:SetLayer(3)
      totMfJ:SetPoint("TOPLEFT", cD.sTOFrames.sbrlccounter, "TOPRIGHT", cD.borders.right, 0)
      cD.sTOFrames.sbmfjcounter  =   totMfJ

      -- total of Totals
      local totOfTot	=  UI.CreateFrame("Text", "totOftotCnt", statusBarFrame)
      totOfTot:SetFontSize(cD.text.base_font_size)
      totOfTot:SetText(string.format("%5d", 0), true)
      totOfTot:SetFont(cD.addon, cD.text.base_font_name)
      totOfTot:SetFontColor(txtColors[2].r, txtColors[2].g, txtColors[2].b)
      totOfTot:SetLayer(3)
      totOfTot:SetPoint("TOPRIGHT", cD.sTOFrames.statusbartotalsframe, "TOPRIGHT", -(cD.borders.right + sbWIDTH + cD.borders.left), -2)
      cD.sTOFrames.sbtotoftot  =   totOfTot

   statusBarFrame:SetHeight(cD.text.base_font_size + 6)
   --
   -- STATUS BAR - end ---------------------------------------------------------------------------------------------------------------------------------
   --

   -- -----------------------------------------------------------------------------
   -- SECOND PANE - charScore VIEWER
   -- -----------------------------------------------------------------------------
   local deltaX   =  cD.borders.left + znListWIDTH + 1
   local itemsExtFrame = UI.CreateFrame("Frame", "Cache_Items_Excternal_frame", totalsWindow)
   itemsExtFrame:SetBackgroundColor(.2, .2, .2, 0)
   itemsExtFrame:SetVisible(false)
   itemsExtFrame:SetLayer(2)
   itemsExtFrame:SetPoint("TOPLEFT",     cD.sTOFrames.titlebartotalsframe,   "BOTTOMLEFT",  deltaX,    1)
   itemsExtFrame:SetPoint("TOPRIGHT",    cD.sTOFrames.titlebartotalsframe,   "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), 1)
   itemsExtFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                       "BOTTOMLEFT",  deltaX,    - cD.borders.bottom)
   itemsExtFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                       "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), -cD.borders.bottom)
   cD.sCACFrames.cacheitemsextframe  = itemsExtFrame

      -- CACHE ZONE ITEMS MASK FRAME
      local itemsMaskFrame = UI.CreateFrame("Mask", "Cache_Items_Mask_Frame", cD.sCACFrames.cacheitemsextframe)
      itemsMaskFrame:SetPoint("TOPLEFT",     cD.sCACFrames.cacheitemsextframe, "TOPLEFT")
      itemsMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames.cacheitemsextframe, "TOPRIGHT",    -cD.borders.right, 0)
      itemsMaskFrame:SetPoint("BOTTOMRIGHT", cD.sCACFrames.cacheitemsextframe, "BOTTOMRIGHT", -cD.borders.right, 0)
      itemsMaskFrame:SetLayer(4)
      cD.sCACFrames.cacheitemsmaskframe  = itemsMaskFrame

      -- CACHE ZONE ITEMS CONTAINER FRAME
      local cacheFrame =  UI.CreateFrame("Frame", "Cache_Items_frame", cD.sCACFrames.cacheitemsmaskframe)
      cacheFrame:SetAllPoints(cD.sCACFrames.cacheitemsmaskframe)
      cacheFrame:SetPoint("TOPLEFT", itemsMaskFrame, "TOPLEFT")
   --    cacheFrame:SetBackgroundColor(0, 0, 0, .6)
      cacheFrame:SetLayer(4)
      cD.sCACFrames.cacheitemsframe  =   cacheFrame

      -- CACHE ZONE ITEMS SCROLLBAR
   --    cfScroll = UI.CreateFrame("RiftScrollbar","item_list_scrollbar", cD.sCACFrames.cacheitemsextframe)
      cfScroll = UI.CreateFrame("RiftScrollbar","item_list_scrollbar", cD.sTOFrames.externaltotalsframe)
      cfScroll:SetVisible(false)
      cfScroll:SetEnabled(false)
      cfScroll:SetWidth(sbWIDTH)
      cfScroll:SetOrientation("vertical")
      cfScroll:SetPoint("TOPLEFT",     cD.sTOFrames.externaltotalsframe,  "TOPRIGHT",    -(cD.borders.right/2)+1, 0)
      cfScroll:SetPoint("BOTTOMLEFT",  cD.sTOFrames.externaltotalsframe,  "BOTTOMRIGHT", -(cD.borders.right/2)+1, 0)
      cfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                                    function()
                                       local pos = cD.round(cD.sCACFrames.cacheitemsscroll:GetPosition())
                                       local smin, smax = cD.sCACFrames.cacheitemsscroll:GetRange()
   --                                     print(string.format("cfScroll:GetPosition() [%s] min[%s] max[%s]", pos, smin, smax))
                                       if       pos == smin  then
                                                cD.sCACFrames.cacheitemsframe:ClearPoint("TOPLEFT")
                                                cD.sCACFrames.cacheitemsframe:ClearPoint("BOTTOMLEFT")
                                                cD.sCACFrames.cacheitemsframe:SetPoint("TOPLEFT",      cD.sCACFrames.cacheitemsmaskframe, "TOPLEFT")
   --                                              print("got TOP")
                                       elseif   pos == smax  then
                                                cD.sCACFrames.cacheitemsframe:ClearPoint("TOPLEFT")
                                                cD.sCACFrames.cacheitemsframe:ClearPoint("BOTTOMLEFT")
                                                cD.sCACFrames.cacheitemsframe:SetPoint("BOTTOMLEFT",   cD.sCACFrames.cacheitemsmaskframe, "BOTTOMLEFT")
   --                                              print("got BOTTOM")
                                       else
                                          cD.sCACFrames.cacheitemsframe:ClearPoint("TOPLEFT")
                                          cD.sCACFrames.cacheitemsframe:ClearPoint("BOTTOMLEFT")
                                          cD.sCACFrames.cacheitemsframe:SetPoint("TOPLEFT", cD.sCACFrames.cacheitemsmaskframe, "TOPLEFT", 0, -(ilScrollStep*pos) )
                                       end
                                    end,
                                 "ItemsFrame_Scrollbar.Change"
                           )
      cD.sCACFrames.cacheitemsscroll  =   cfScroll
      -- -----------------------------------------------------------------------------

   -- Enable Dragging
   Library.LibDraggable.draggify(totalsWindow, cD.updateGuiCoordinates)

   return totalsWindow

end

function cD.createTotalsLine(leftparent, rightparent, zoneName, znID, zoneTotals, isLegend)

   if leftparent  == nil then leftparent  = cD.sTOFrames.totalsleftframe   end
   if rightparent == nil then rightparent = cD.sTOFrames.totalsrightframe  end

   local leftitemframe  =  nil
   local rightitemframe =  nil
   local znOBJ          =  nil
   local idx            =  nil
   local parentOBJ      =  nil
   local totOBJs        =  {}
   local legendColor    =  1
   cD.totallineheight   =  nil

   -- setup LEFT Item containing Frame (zone name)
   leftitemframe =  UI.CreateFrame("Frame", "Totals_line_left_Container", leftparent)
   leftitemframe:SetHeight(cD.text.base_font_size)
   leftitemframe:SetLayer(1)
   leftitemframe:SetBackgroundColor(.2, .2, .2, .6)
   if table.getn(cD.sTOLeftFrames) > 0 then
      leftitemframe:SetPoint("TOPLEFT",    cD.sTOLeftFrames[#cD.sTOLeftFrames], "BOTTOMLEFT",  0, 1)
      leftitemframe:SetPoint("TOPRIGHT",   cD.sTOLeftFrames[#cD.sTOLeftFrames], "BOTTOMRIGHT", 0, 1)
   else
      leftitemframe:SetPoint("TOPLEFT",    leftparent, "TOPLEFT")
      leftitemframe:SetPoint("TOPRIGHT",   leftparent, "TOPRIGHT")
   end

   -- Zone Name
   znOBJ       =  UI.CreateFrame("Text", "Totals_" ..zoneName, leftitemframe)
   local zn    =  string.sub(zoneName, 1, tMAXSTRINGSIZE)
   znOBJ:SetWidth(150)
   znOBJ:SetFontSize(cD.text.base_font_size)
   znOBJ:SetFont(cD.addon, cD.text.base_font_name)
   znOBJ:SetText(zn)
   znOBJ:SetPoint("TOPLEFT",   leftitemframe, "TOPLEFT", cD.borders.left, 0)
   znOBJ:EventAttach(Event.UI.Input.Mouse.Left.Click, function() selectZone(znID, zoneName) end, "Zone Selected" )
   zlFrames[zoneName] = znOBJ  -- we save the text frame for highlighting

   -- setup RIGHT Item containing Frame (totals)
   rightitemframe =  UI.CreateFrame("Frame", "Totals_line_right_Container", rightparent)
   rightitemframe:SetHeight(cD.text.base_font_size)
   rightitemframe:SetLayer(1)
   rightitemframe:SetBackgroundColor(.2, .2, .2, .6)
   if table.getn(cD.sTORightFrames) > 0 then
--       print("cD.createTotalsLine: > 0")
      rightitemframe:SetPoint("TOPLEFT",    cD.sTORightFrames[#cD.sTORightFrames], "BOTTOMLEFT",  0, 1)
      rightitemframe:SetPoint("TOPRIGHT",   cD.sTORightFrames[#cD.sTORightFrames], "BOTTOMRIGHT", 0, 1)
   else
--       print("cD.createTotalsLine: < 0")
      rightitemframe:SetPoint("TOPLEFT",    rightparent, "TOPLEFT")
      rightitemframe:SetPoint("TOPRIGHT",   rightparent, "TOPRIGHT")
   end

   local parentOBJ	=  rightitemframe
   local total       =  0
   for idx=1, 7 do
      -- setup Totals Item's Counter
      local totalsCnt  =  UI.CreateFrame("Text", "Totals_Cnt_" .. idx, parentOBJ)
      totalsCnt:SetFont(cD.addon, cD.text.base_font_name)
      totalsCnt:SetFontSize(cD.text.base_font_size)
      totalsCnt:SetFontColor(txtColors[idx].r, txtColors[idx].g, txtColors[idx].b)
--       totalsCnt:SetBackgroundColor(txtColors[idx].r, txtColors[idx].g, txtColors[idx].b)
      totalsCnt:SetText(string.format("%3d", zoneTotals[idx]))
      if idx==1 then
         totalsCnt:SetPoint("TOPLEFT",   parentOBJ, "TOPLEFT", cD.borders.left, 0)
      else
         totalsCnt:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
      end
      parentOBJ   =  totalsCnt
      table.insert(totOBJs, totalsCnt)

      total = total + zoneTotals[idx]
--       print(string.format("cD.createTotalsLine: idx=%s total=%s parent=%s", idx, total, parentOBJ))
   end

   -- This field is the MfJ (Money from Junk)
   local mfjTotal  =  UI.CreateFrame("Text", "MfJ", parentOBJ)
   mfjTotal:SetFont(cD.addon, cD.text.base_font_name)
   mfjTotal:SetFontSize(cD.text.base_font_size)
   mfjTotal:SetWidth(cD.text.base_font_size * 5.5)
   mfjTotal:SetText(string.format("%10s", cD.printJunkMoney(zoneTotals[8])), true)
   mfjTotal:SetFontColor(txtColors[8].r, txtColors[8].g, txtColors[8].b)
   mfjTotal:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(totOBJs, mfjTotal)
   parentOBJ   =  mfjTotal

   -- This field is the Total of Totals
   local totalsTotal  =  UI.CreateFrame("Text", "Totals_Total", parentOBJ)
   totalsTotal:SetFont(cD.addon, cD.text.base_font_name)
   totalsTotal:SetFontSize(cD.text.base_font_size)
   totalsTotal:SetText(string.format("%5d", total))
   totalsTotal:SetFontColor(txtColors[9].r, txtColors[9].g, txtColors[9].b)
   totalsTotal:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
   table.insert(totOBJs, totalsTotal)
   parentOBJ   =  totalsTotal

   cD.totallineheight   =  znOBJ:GetHeight() + 1
   rightitemframe:SetHeight(cD.totallineheight)
   leftitemframe:SetHeight(cD.totallineheight)
--    print("CREATE: ["..cD.totallineheight.."]")
--    print("LEFT: ["..leftitemframe:GetHeight().."]")
--    print("RIGHT: ["..rightitemframe:GetHeight().."]")

   return leftitemframe, rightitemframe, znOBJ, totOBJs
end



function cD.updateTotalsStatusBar(znTot, totMfJ, totOfTot)

   local cnts  =  {}
   local i     =  0

   -- per-init cnts{}
   for i=1,9 do cnts[i] = 0 end

   if totOfTot == nil then totOfTot = 0 end

   -- calculate totals
   for a,b in pairs(cD.zoneTotalCnts) do
      cnts[10]  =  (cnts[10] or 0) + 1   -- i=10  total number of zones
      for i=1, 8 do
         cnts[i]  =  (cnts[i] or 0) +  b[i]
         -- i=9  is totOfTot so we skip accountig field 8 (i=8 is MfJ)
         if i  ~= 8 then cnts[9]  =  (cnts[9] or 0) +  b[i] end
      end
   end

--    print(string.format("znTot[%s], totMfJ[%s], totOfTot[%s]", znTot, totMfJ, totOfTot))

--    -- How Many Zones
--    if cD.sTOFrames.sbzonescounter then
--       if znTot == nil then
--          znTot =  cnts[10]
-- --          znTot =  #cD.zoneTotalCnts
-- --          print(string.format("znTot[%s]", znTot))
--       end
--       cD.sTOFrames.sbzonescounter:SetText(string.format("%10d", znTot))
--    end

   if cD.sTOFrames.sbjnkcounter then cD.sTOFrames.sbjnkcounter:SetText(string.format("%3d", cnts[1])) end
   if cD.sTOFrames.sbcomcounter then cD.sTOFrames.sbcomcounter:SetText(string.format("%3d", cnts[2])) end
   if cD.sTOFrames.sbunccounter then cD.sTOFrames.sbunccounter:SetText(string.format("%3d", cnts[3])) end
   if cD.sTOFrames.sbrarcounter then cD.sTOFrames.sbrarcounter:SetText(string.format("%3d", cnts[4])) end
   if cD.sTOFrames.sbepccounter then cD.sTOFrames.sbepccounter:SetText(string.format("%3d", cnts[5])) end
   if cD.sTOFrames.sbqstcounter then cD.sTOFrames.sbqstcounter:SetText(string.format("%3d", cnts[6])) end
   if cD.sTOFrames.sbrclcounter then cD.sTOFrames.sbrlccounter:SetText(string.format("%3d", cnts[7])) end

   -- Total of Money from Junk
   if cD.sTOFrames.sbmfjcounter then
      if totMfJ == nil then totMfJ   =  cnts[8] end
      cD.sTOFrames.sbmfjcounter:SetText(string.format("%10s", cD.printJunkMoney(totMfJ)), true)
   end

   -- Total of Totals
   if cD.sTOFrames.sbtotoftot then

      if totOfTot == 0 then totOfTot =  cnts[9] end
      cD.sTOFrames.sbtotoftot:SetText(string.format("%5d", totOfTot))
   end

   return
end



function cD.initTotalsWindow()

   local zn, tbl        =	nil, {}
   local parentOBJ      =  cD.sTOFrames.totalsleftframe
   local znTot          =  0
   local totMfJ         =  0
   local totOfTot       =  0
   local leftparentOBJ  =  cD.sTOFrames.totalsleftframe
   local rightparentOBJ =  cD.sTOFrames.totalsrightframe
   cD.sTOLeftFrames     =  {}
   cD.sTORightFrames    =  {}

   for zn, tbl in pairs(cD.zoneTotalCnts) do

      local znName   =  Inspect.Zone.Detail(zn).name
      local znID     =  Inspect.Zone.Detail(zn).id
--       local totalsFrame, znOBJ, totOBJs = cD.createTotalsLine(leftparentOBJ, rightparentOBJ, znName, znID, tbl)
      local leftItemFrame, rightItemFrame, znOBJ, totOBJs = cD.createTotalsLine(leftparentOBJ, rightparentOBJ, znName, znID, tbl)

      table.insert(cD.sTOzoneIDs,   zn)
--       table.insert(cD.sTOFrames,     totalsFrame)
      table.insert(cD.sTOLeftFrames,   leftItemFrame)
      table.insert(cD.sTORightFrames,  rightItemFrame)
      table.insert(cD.sTOznOBJs,       znOBJ)
      cD.sTOcntOBJs[znID] = totOBJs

--       parentOBJ   =  totalsFrame
      leftparentOBJ  =  leftItemFrame
      rightparentOBJ =  rightItemFrame

      znTot          =  znTot + 1

      --
      -- FOR STATUS BAR
      --
      -- calculate and add to totMfJ MfJ for this zone
      totMfJ = totMfJ + tbl[8]   -- field number 8 in MfJ per zone

      -- calculate and add to totOfTot totals for this zone
      local idx  =  nil
      for idx=1, 7 do totOfTot = totOfTot + tbl[idx] end
   end

   -- should Totals Scrollbar be enabled?
   if znTot > visibleItems then
      cD.sTOFrames.totalsframescroll:SetEnabled(true)
      cD.sTOFrames.totalsframescroll:SetVisible(true)
   else
      cD.sTOFrames.totalsframescroll:SetEnabled(false)
      cD.sTOFrames.totalsframescroll:SetVisible(false)
   end

   cD.updateTotalsStatusBar(znTot, totMfJ, totOfTot)

   return
end

