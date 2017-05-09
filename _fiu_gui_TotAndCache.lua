--
-- Addon       _fiu_gui_TotAndcache.lua
-- Author      marcob@marcob.org
-- StartDate   08/04/2017
-- StartDate   09/03/2017
--

local addon, cD = ...

cD.sTOFrames                  =  {}

local TITLEBARTOTALSFRAME     =  1
local TITLEBARTCONTENTFRAME   =  2
local EXTERNALTOTALSFRAME     =  3
local TOTALSMASKFRAME         =  4
local TOTALSFRAME             =  5
local TOTALSFRAMESCROLL       =  6
local STATUSBARTOTALSFRAME    =  7
local STATUSBARTFRAME         =  8

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
      parent = cD.sCACFrames["CACHEITEMSFRAME"]
   else
      first = false
   end

   local zil, zilIcon, zilName, zilDesc, zilCat = nil, nil, nil, nil, nil

   zil =  UI.CreateFrame("Frame", "Zone_item_Frame", cD.sCACFrames["CACHEITEMSFRAME"])
   zil:SetBackgroundColor(.3, .3, .3, .6) -- HERE
   if first then
      first = false
      zil:SetPoint("TOPLEFT",  cD.sCACFrames["CACHEITEMSFRAME"], "TOPLEFT",  cD.borders.left,  cD.borders.top)
      zil:SetPoint("TOPRIGHT", cD.sCACFrames["CACHEITEMSFRAME"], "TOPRIGHT", -cD.borders.right, cD.borders.bottom)

   else
      zil:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT",  0,  cD.borders.top)
      zil:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0,  cD.borders.top)
   end
   zil:SetLayer(3)

   local lootCnt  =  UI.CreateFrame("Text", "Loot_Cnt_" .. t.name, zil)
   local objColor =  cD.rarityColor("quest")
   lootCnt:SetFont(cD.addon, cD.text.base_font_name)
   lootCnt:SetFontSize(cD.text.base_font_size)
   lootCnt:SetFontColor(objColor.r, objColor.g, objColor.b)
   lootCnt:SetText(string.format("%3d", 0), true)
   lootCnt:SetLayer(3)
   lootCnt:SetPoint("TOPLEFT",   zil, "TOPLEFT", cD.borders.left, 0)

   -- Item's Type Icon
   local typeIcon = UI.CreateFrame("Texture", "Type_Icon_" .. t.name, zil)
   local categoryIcon  =  nil
   categoryIcon  =  cD.categoryIcon(t.category, t.id, t.description, t.name)
   if  categoryIcon ~= nil then typeIcon:SetTexture("Rift", categoryIcon)  end
   typeIcon:SetWidth(cD.text.base_font_size)
   typeIcon:SetHeight(cD.text.base_font_size)
   typeIcon:SetPoint("TOPLEFT",   lootCnt, "TOPRIGHT", cD.borders.left, 3)
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

   zil:SetHeight((lootIcon:GetBottom() + cD.borders.bottom ) - zil:GetTop())

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

   --
   -- FIRST ROW
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
   cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("TOPLEFT")
   cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("BOTTOMLEFT")
   cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT", cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT")

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

   if cnt > visibleItems then
      cfScroll:SetVisible(true)
      cfScroll:SetEnabled(true)
      --       print("PRE HEIGHT   ["..cD.sCACFrames["CACHEITEMSFRAME"]:GetHeight().."]")

      local baseY =  cD.sCACFrames["CACHEITEMSFRAME"]:GetTop()
      local maxY  =  parent:GetBottom()

      cD.sCACFrames["CACHEITEMSFRAME"]:SetHeight(cD.round(maxY - baseY))
      --       print("POST HEIGHT  ["..cD.sCACFrames["CACHEITEMSFRAME"]:GetHeight().."]")

      cfScroll:SetRange(1, cnt - visibleItems)
      ilScrollStep   =  cD.round(cD.sCACFrames["CACHEITEMSFRAME"]:GetHeight()/cnt)

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
      lastBGused.r, lastBGused.g, lastBGused.b, lastBGused.a     =  zlFrames[zoneName]:GetBackgroundColor()
      zlFrames[zoneName]:SetBackgroundColor(.6, .6, .6, .6)
      lastZnSelected =  zlFrames[zoneName]

      resetZoneItemsList()
      populateZoneItemsList(znID, zoneName)
      cD.sTOFrames[TOTALSFRAMESCROLL]:SetVisible(false)
      cD.sCACFrames["CACHEITEMSEXTFRAME"]:SetVisible(true)
      cD.sCACFrames["CACHEITEMSSCROLL"]:SetVisible(true)
   else
      cD.sCACFrames["CACHEITEMSEXTFRAME"]:SetVisible(false)
      cD.sCACFrames["CACHEITEMSSCROLL"]:SetVisible(false)
      cD.sTOFrames[TOTALSFRAMESCROLL]:SetVisible(true)
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
   cD.sTOFrames[TITLEBARTOTALSFRAME]  =   titleTotalsFrame

   -- TITLE BAR TITLE
   local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleTotalsFrame)
   titleFIU:SetFontSize(cD.text.base_font_size)
   titleFIU:SetText("FIU! Lifetime Totals")
   titleFIU:SetFont(cD.addon, cD.text.base_font_name)
   titleFIU:SetLayer(3)
   titleFIU:SetPoint("TOPLEFT", cD.sTOFrames[TITLEBARTOTALSFRAME], "TOPLEFT", cD.borders.left, 0)
   cD.sTOFrames[TITLEBARTCONTENTFRAME]  =   titleFIU


   -- TITLE BAR Widgets: setup Icon for Iconize
   lootIcon = UI.CreateFrame("Texture", "Title_Icon_1", cD.sTOFrames[TITLEBARTOTALSFRAME])
   lootIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
   lootIcon:SetWidth(cD.text.base_font_size)
   lootIcon:SetHeight(cD.text.base_font_size)
   lootIcon:SetPoint("TOPRIGHT",   cD.sTOFrames[TITLEBARTOTALSFRAME], "TOPRIGHT", -cD.borders.right, 0)
   lootIcon:SetLayer(3)
   lootIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsOBJ:SetVisible(not cD.window.totalsOBJ:GetVisible()) end , "Iconize Totals Pressed" )

   titleTotalsFrame:SetHeight(cD.text.base_font_size + 6)

   -- EXTERNAL TOTALS CONTAINER FRAME
   local totalsExtFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   totalsExtFrame:SetPoint("TOPLEFT",     cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMLEFT",  cD.borders.left,    1)
   totalsExtFrame:SetPoint("TOPRIGHT",    cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), 1)
   totalsExtFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                      "BOTTOMLEFT",  cD.borders.left,    - cD.borders.bottom)
   totalsExtFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                      "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), - cD.borders.bottom)
   totalsExtFrame:SetBackgroundColor(.2, .2, .2, .6)
   totalsExtFrame:SetLayer(1)
   cD.sTOFrames[EXTERNALTOTALSFRAME]  =   totalsExtFrame

   -- MASK FRAME
   local maskFrame = UI.CreateFrame("Mask", "Totals_Mask_Frame", cD.sTOFrames[EXTERNALTOTALSFRAME])
   maskFrame:SetAllPoints(cD.sTOFrames[EXTERNALTOTALSFRAME])
   cD.sTOFrames[TOTALSMASKFRAME]  = maskFrame

   -- TOTALS CONTAINER FRAME
   local totalsFrame =  UI.CreateFrame("Frame", "loot_frame", cD.sTOFrames[TOTALSMASKFRAME])
   totalsFrame:SetAllPoints(cD.sTOFrames[TOTALSMASKFRAME])
   totalsFrame:SetLayer(1)
   cD.sTOFrames[TOTALSFRAME]  =   totalsFrame

   -- CACHE ZONE ITEMS SCROLLBAR
   tfScroll = UI.CreateFrame("RiftScrollbar","Totals_Frame_scrollbar", cD.sTOFrames[EXTERNALTOTALSFRAME])
   tfScroll:SetVisible(true)
   tfScroll:SetEnabled(true)
   tfScroll:SetWidth(sbWIDTH)
   tfScroll:SetOrientation("vertical")
   tfScroll:SetPoint("TOPLEFT",     cD.sTOFrames[EXTERNALTOTALSFRAME],  "TOPRIGHT",    -(cD.borders.right/2)+1, 0)
   tfScroll:SetPoint("BOTTOMLEFT",  cD.sTOFrames[EXTERNALTOTALSFRAME],  "BOTTOMRIGHT", -(cD.borders.right/2)+1, 0)
   tfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                           function()
                              cD.sTOFrames[TOTALSFRAME]:SetPoint("TOPLEFT", cD.sTOFrames[TOTALSMASKFRAME], "TOPLEFT", 0, -math.floor(tlScrollStep*tfScroll:GetPosition()) )
                           end,
                           "TotalsFrame_Scrollbar.Change"
                        )
   cD.sTOFrames[TOTALSFRAMESCROLL]  =   tfScroll

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
   cD.sTOFrames[STATUSBARTOTALSFRAME]  =   statusBarFrame

      -- How many Zones
      local zonesCnt =  UI.CreateFrame("Text", "zonesCnt", statusBarFrame)
      zonesCnt:SetFontSize(cD.text.base_font_size)
      zonesCnt:SetText(string.format("%5d", 0), true)
      zonesCnt:SetFont(cD.addon, cD.text.base_font_name)
      zonesCnt:SetLayer(3)
      zonesCnt:SetPoint("TOPLEFT", cD.sTOFrames[STATUSBARTOTALSFRAME], "TOPLEFT", cD.borders.left, -2)
      cD.sTOFrames["SBZONESCOUNTER"]  =   zonesCnt

      -- How many sellables/junk
      local jnkCnt =  UI.CreateFrame("Text", "jnkCnt", statusBarFrame)
      jnkCnt:SetFontSize(cD.text.base_font_size)
      jnkCnt:SetText(string.format("%3d", 0), true)
      jnkCnt:SetFont(cD.addon, cD.text.base_font_name)
      jnkCnt:SetFontColor(txtColors[1].r, txtColors[1].g, txtColors[1].b)
      jnkCnt:SetLayer(3)
      jnkCnt:SetPoint("TOPLEFT", cD.sTOFrames[STATUSBARTOTALSFRAME], "TOPLEFT", znListWIDTH + cD.borders.left, -2)
      cD.sTOFrames["SBJNKCOUNTER"]  =   jnkCnt

      -- How many common intems
      local comCnt =  UI.CreateFrame("Text", "commonCnt", statusBarFrame)
      comCnt:SetFontSize(cD.text.base_font_size)
      comCnt:SetText(string.format("%3d", 0), true)
      comCnt:SetFont(cD.addon, cD.text.base_font_name)
      comCnt:SetFontColor(txtColors[2].r, txtColors[2].g, txtColors[2].b)
      comCnt:SetLayer(3)
      comCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBJNKCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBCOMCOUNTER"]  =   comCnt

      -- How many uncommon intems
      local uncCnt =  UI.CreateFrame("Text", "uncommonCnt", statusBarFrame)
      uncCnt:SetFontSize(cD.text.base_font_size)
      uncCnt:SetText(string.format("%3d", 0), true)
      uncCnt:SetFont(cD.addon, cD.text.base_font_name)
      uncCnt:SetFontColor(txtColors[3].r, txtColors[3].g, txtColors[3].b)
      uncCnt:SetLayer(3)
      uncCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBCOMCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBUNCCOUNTER"]  =   uncCnt

      -- How many rare intems
      local rarCnt =  UI.CreateFrame("Text", "rareCnt", statusBarFrame)
      rarCnt:SetFontSize(cD.text.base_font_size)
      rarCnt:SetText(string.format("%3d", 0), true)
      rarCnt:SetFontColor(txtColors[4].r, txtColors[4].g, txtColors[4].b)
      rarCnt:SetFont(cD.addon, cD.text.base_font_name)
      rarCnt:SetLayer(3)
      rarCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBUNCCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBRARCOUNTER"]  =   rarCnt

      -- How many epic intems
      local epcCnt =  UI.CreateFrame("Text", "epicCnt", statusBarFrame)
      epcCnt:SetFontSize(cD.text.base_font_size)
      epcCnt:SetText(string.format("%3d", 0), true)
      epcCnt:SetFont(cD.addon, cD.text.base_font_name)
      epcCnt:SetFontColor(txtColors[5].r, txtColors[5].g, txtColors[5].b)
      epcCnt:SetLayer(3)
      epcCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBRARCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBEPCCOUNTER"]  =   epcCnt

      -- How many quest intems
      local qstCnt =  UI.CreateFrame("Text", "questCnt", statusBarFrame)
      qstCnt:SetFontSize(cD.text.base_font_size)
      qstCnt:SetText(string.format("%3d", 0), true)
      qstCnt:SetFontColor(txtColors[6].r, txtColors[6].g, txtColors[6].b)
      qstCnt:SetFont(cD.addon, cD.text.base_font_name)
      qstCnt:SetLayer(3)
      qstCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBEPCCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBQSTCOUNTER"]  =   qstCnt

      -- How many relic intems
      local rlcCnt =  UI.CreateFrame("Text", "relicCnt", statusBarFrame)
      rlcCnt:SetFontSize(cD.text.base_font_size)
      rlcCnt:SetText(string.format("%3d", 0), true)
      rlcCnt:SetFont(cD.addon, cD.text.base_font_name)
      rlcCnt:SetFontColor(txtColors[7].r, txtColors[7].g, txtColors[7].b)
      rlcCnt:SetLayer(3)
      rlcCnt:SetPoint("TOPLEFT", cD.sTOFrames["SBQSTCOUNTER"], "TOPRIGHT", cD.borders.left, 0)
      cD.sTOFrames["SBRLCCOUNTER"]  =   rlcCnt

      -- total of MfJ
      local totMfJ	=  UI.CreateFrame("Text", "mfjCnt", statusBarFrame)
      totMfJ:SetFontSize(cD.text.base_font_size)
      totMfJ:SetText(string.format("%10s", cD.printJunkMoney(0)), true)
      totMfJ:SetFont(cD.addon, cD.text.base_font_name)
      totMfJ:SetFontColor(txtColors[7].r, txtColors[7].g, txtColors[7].b)
      totMfJ:SetLayer(3)
      totMfJ:SetPoint("TOPLEFT", cD.sTOFrames["SBRLCCOUNTER"], "TOPRIGHT", cD.borders.right, 0)
      cD.sTOFrames["SBMFJCOUNTER"]  =   totMfJ

      -- total of Totals
      local totOfTot	=  UI.CreateFrame("Text", "totOftotCnt", statusBarFrame)
      totOfTot:SetFontSize(cD.text.base_font_size)
      totOfTot:SetText(string.format("%5d", 0), true)
      totOfTot:SetFont(cD.addon, cD.text.base_font_name)
      totOfTot:SetFontColor(txtColors[2].r, txtColors[2].g, txtColors[2].b)
      totOfTot:SetLayer(3)
      totOfTot:SetPoint("TOPRIGHT", cD.sTOFrames[STATUSBARTOTALSFRAME], "TOPRIGHT", -(cD.borders.right + sbWIDTH + cD.borders.left), -2)
      cD.sTOFrames["SBTOTOFTOT"]  =   totOfTot

   statusBarFrame:SetHeight(cD.text.base_font_size + 6)
   --
   -- STATUS BAR - end ---------------------------------------------------------------------------------------------------------------------------------
   --

   -- -----------------------------------------------------------------------------
   -- SECOND PANE - charScore VIEWER
   -- -----------------------------------------------------------------------------
   local itemsExtFrame = UI.CreateFrame("Frame", "Cache_Items_Excternal_frame", totalsWindow)
--    itemsExtFrame:SetBackgroundColor(0, 0, 0, 1)
--    itemsExtFrame:SetBackgroundColor(.2, .2, .2, 1)
   itemsExtFrame:SetBackgroundColor(0, 0, 0, 1)
   itemsExtFrame:SetVisible(false)
   itemsExtFrame:SetLayer(2)

   local deltaX   =  cD.borders.left + znListWIDTH + 1
   itemsExtFrame:SetPoint("TOPLEFT",     cD.sTOFrames[TITLEBARTOTALSFRAME],   "BOTTOMLEFT",  deltaX,    1)
   itemsExtFrame:SetPoint("TOPRIGHT",    cD.sTOFrames[TITLEBARTOTALSFRAME],   "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), 1)
   itemsExtFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                        "BOTTOMLEFT",  deltaX,    - cD.borders.bottom)
   itemsExtFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                        "BOTTOMRIGHT", -(cD.borders.right + sbWIDTH), -cD.borders.bottom)
   cD.sCACFrames["CACHEITEMSEXTFRAME"]  = itemsExtFrame

   -- CACHE ZONE ITEMS MASK FRAME
   local itemsMaskFrame = UI.CreateFrame("Mask", "Cache_Items_Mask_Frame", cD.sCACFrames["CACHEITEMSEXTFRAME"])
   itemsMaskFrame:SetPoint("TOPLEFT",     cD.sCACFrames["CACHEITEMSEXTFRAME"], "TOPLEFT")
   itemsMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["CACHEITEMSEXTFRAME"], "TOPRIGHT",    -cD.borders.right, 0)
   itemsMaskFrame:SetPoint("BOTTOMRIGHT", cD.sCACFrames["CACHEITEMSEXTFRAME"], "BOTTOMRIGHT", -cD.borders.right, 0)
   itemsMaskFrame:SetLayer(4)
   cD.sCACFrames["CACHEITEMSMASKFRAME"]  = itemsMaskFrame

   -- CACHE ZONE ITEMS CONTAINER FRAME
   local cacheFrame =  UI.CreateFrame("Frame", "Cache_Items_frame", cD.sCACFrames["CACHEITEMSMASKFRAME"])
   cacheFrame:SetAllPoints(cD.sCACFrames["CACHEITEMSMASKFRAME"])
   cacheFrame:SetPoint("TOPLEFT", itemsMaskFrame, "TOPLEFT")
   cacheFrame:SetBackgroundColor(0, 0, 0, .6)
   cacheFrame:SetLayer(4)
   cD.sCACFrames["CACHEITEMSFRAME"]  =   cacheFrame

   -- CACHE ZONE ITEMS SCROLLBAR
   cfScroll = UI.CreateFrame("RiftScrollbar","item_list_scrollbar", cD.sCACFrames["CACHEITEMSEXTFRAME"])
--    cfScroll:SetVisible(true)
--    cfScroll:SetEnabled(true)
   cfScroll:SetWidth(sbWIDTH)
   cfScroll:SetOrientation("vertical")
   cfScroll:SetPoint("TOPLEFT",     cD.sCACFrames["CACHEITEMSEXTFRAME"],   "TOPRIGHT",    -(cD.borders.right/2)+1, 0)
   cfScroll:SetPoint("BOTTOMLEFT",  cD.sCACFrames["CACHEITEMSEXTFRAME"],   "BOTTOMRIGHT", -(cD.borders.right/2)+1, 0)
   cfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                                 function()
                                    local pos = cD.round(cD.sCACFrames["CACHEITEMSSCROLL"]:GetPosition())
                                    local smin, smax = cD.sCACFrames["CACHEITEMSSCROLL"]:GetRange()
--                                     print(string.format("cfScroll:GetPosition() [%s] min[%s] max[%s]", pos, smin, smax))
                                    if       pos == smin  then
                                             cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("TOPLEFT")
                                             cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("BOTTOMLEFT")
                                             cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT",      cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT")
--                                              print("got TOP")
                                    elseif   pos == smax  then
                                             cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("TOPLEFT")
                                             cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("BOTTOMLEFT")
                                             cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("BOTTOMLEFT",   cD.sCACFrames["CACHEITEMSMASKFRAME"], "BOTTOMLEFT")
--                                              print("got BOTTOM")
                                    else
                                       cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("TOPLEFT")
                                       cD.sCACFrames["CACHEITEMSFRAME"]:ClearPoint("BOTTOMLEFT")
                                       cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT", cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT", 0, -(ilScrollStep*pos) )
                                    end
                                 end,
                              "ItemsFrame_Scrollbar.Change"
                        )
   cD.sCACFrames["CACHEITEMSSCROLL"]  =   cfScroll
   -- -----------------------------------------------------------------------------
   --[[  ITEM VIEWER ]]-- [[END]]--

   -- Enable Dragging
   Library.LibDraggable.draggify(totalsWindow, cD.updateGuiCoordinates)

   return totalsWindow

end

function cD.createTotalsLine(parent, zoneName, znID, zoneTotals, isLegend)

   if parent == nil then parent = cD.sTOFrames[TOTALSFRAME] end

   local totalsFrame =  nil
   local znOBJ       =  nil
   local idx         =  nil
   local parentOBJ   =  nil
   local totOBJs     =  {}
   local legendColor =  1

   -- setup Totals containing Frame
   totalsFrame =  UI.CreateFrame("Frame", "Totals_line_Container", parent)
   totalsFrame:SetHeight(cD.text.base_font_size)
   totalsFrame:SetLayer(1)
   totalsFrame:SetBackgroundColor(.2, .2, .2, .6)
   if table.getn(cD.sTOFrame) > 0 then
      totalsFrame:SetPoint("TOPLEFT",    cD.sTOFrame[#cD.sTOFrame], "BOTTOMLEFT",  0, 1)
      totalsFrame:SetPoint("TOPRIGHT",   cD.sTOFrame[#cD.sTOFrame], "BOTTOMRIGHT", 0, 1)
   else
      totalsFrame:SetPoint("TOPLEFT",    parent, "TOPLEFT",  0, 1)
      totalsFrame:SetPoint("TOPRIGHT",   parent, "TOPRIGHT", 0, 1)
   end

   -- Zone Name
   znOBJ       =  UI.CreateFrame("Text", "Totals_" ..zoneName, totalsFrame)
   local zn    =  string.sub(zoneName, 1, tMAXSTRINGSIZE)
   znOBJ:SetWidth(150)
--    znOBJ:SetLayer(3)
   znOBJ:SetFontSize(cD.text.base_font_size)
   znOBJ:SetFont(cD.addon, cD.text.base_font_name)
   znOBJ:SetText(zn)
   znOBJ:SetPoint("TOPLEFT",   totalsFrame, "TOPLEFT", cD.borders.left, 2)
   znOBJ:EventAttach(Event.UI.Input.Mouse.Left.Click, function() selectZone(znID, zoneName) end, "Zone Selected" )
   zlFrames[zoneName] = znOBJ  -- we save the text frame for highlighting

   local parentOBJ   =  znOBJ
   local total       =  0
   --    for idx, _ in pairs(zoneTotals) do
      for idx=1, 7 do
         -- setup Totals Item's Counter
         local totalsCnt  =  UI.CreateFrame("Text", "Totals_Cnt_" .. idx, totalsFrame)
         totalsCnt:SetFont(cD.addon, cD.text.base_font_name)
         totalsCnt:SetFontSize(cD.text.base_font_size)
--          totalsCnt:SetLayer(2)

         if isLegend then
            totalsCnt:SetFontColor(txtColors[legendColor].r, txtColors[legendColor].g, txtColors[legendColor].b)
            totalsFrame:SetBackgroundColor(.0, .0, .0, .6)
            totalsCnt:SetText(string.format("%3s", zoneTotals[idx]))
            legendColor = legendColor + 1
         else
            totalsCnt:SetFontColor(txtColors[idx].r, txtColors[idx].g, txtColors[idx].b)
            totalsCnt:SetText(string.format("%3d", zoneTotals[idx]))
         end

         totalsCnt:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
         parentOBJ   =  totalsCnt
         table.insert(totOBJs, totalsCnt)

         if not isLegend then total = total + zoneTotals[idx] end
      end

      -- This field is the MfJ (Money from Junk)
      local mfjTotal  =  UI.CreateFrame("Text", "MfJ", totalsFrame)
      mfjTotal:SetFont(cD.addon, cD.text.base_font_name)
      mfjTotal:SetFontSize(cD.text.base_font_size)
      mfjTotal:SetWidth(cD.text.base_font_size * 5.5)
      if isLegend then
         mfjTotal:SetText(string.format("%6s", zoneTotals[8]), true)
      else
         mfjTotal:SetText(string.format("%10s", cD.printJunkMoney(zoneTotals[8])), true)
      end
      mfjTotal:SetFontColor(txtColors[8].r, txtColors[8].g, txtColors[8].b)
      mfjTotal:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
      table.insert(totOBJs, mfjTotal)
      parentOBJ   =  mfjTotal

      -- This field is the Total of Totals
      local totalsTotal  =  UI.CreateFrame("Text", "Totals_Total", totalsFrame)
      totalsTotal:SetFont(cD.addon, cD.text.base_font_name)
      totalsTotal:SetFontSize(cD.text.base_font_size)
      if isLegend then
         totalsTotal:SetText(string.format("%5s", zoneTotals[9]))
      else
         totalsTotal:SetText(string.format("%5d", total))
      end
--       totalsTotal:SetLayer(3)
      totalsTotal:SetFontColor(txtColors[9].r, txtColors[9].g, txtColors[9].b)
      totalsTotal:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
      table.insert(totOBJs, totalsTotal)
      parentOBJ   =  totalsTotal

      totalsFrame:SetHeight(znOBJ:GetHeight() + 1)

      return totalsFrame, znOBJ, totOBJs
   end


function cD.updateTotalsStatusBar(znTot, totMfJ, totOfTot)

   local cnts  =  {}

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

   -- How Many Zones
   if cD.sTOFrames["SBZONESCOUNTER"] then
      if znTot == nil then
         znTot =  cnts[10]
--          znTot =  #cD.zoneTotalCnts
--          print(string.format("znTot[%s]", znTot))
      end
      cD.sTOFrames["SBZONESCOUNTER"]:SetText(string.format("%10d", znTot))
   end

   if cD.sTOFrames["SBJNKCOUNTER"] then cD.sTOFrames["SBJNKCOUNTER"]:SetText(string.format("%3d", cnts[1])) end
   if cD.sTOFrames["SBCOMCOUNTER"] then cD.sTOFrames["SBCOMCOUNTER"]:SetText(string.format("%3d", cnts[2])) end
   if cD.sTOFrames["SBUNCCOUNTER"] then cD.sTOFrames["SBUNCCOUNTER"]:SetText(string.format("%3d", cnts[3])) end
   if cD.sTOFrames["SBRARCOUNTER"] then cD.sTOFrames["SBRARCOUNTER"]:SetText(string.format("%3d", cnts[4])) end
   if cD.sTOFrames["SBEPCCOUNTER"] then cD.sTOFrames["SBEPCCOUNTER"]:SetText(string.format("%3d", cnts[5])) end
   if cD.sTOFrames["SBQSTCOUNTER"] then cD.sTOFrames["SBQSTCOUNTER"]:SetText(string.format("%3d", cnts[6])) end
   if cD.sTOFrames["SBELCCOUNTER"] then cD.sTOFrames["SBRLCCOUNTER"]:SetText(string.format("%3d", cnts[7])) end

   -- Total of Money from Junk
   if cD.sTOFrames["SBMFJCOUNTER"] then
      if totMfJ == nil then totMfJ   =  cnts[8] end
      cD.sTOFrames["SBMFJCOUNTER"]:SetText(string.format("%10s", cD.printJunkMoney(totMfJ)), true)
   end

   -- Total of Totals
   if cD.sTOFrames["SBTOTOFTOT"] then

      if totOfTot == 0 then totOfTot =  cnts[9] end
      cD.sTOFrames["SBTOTOFTOT"]:SetText(string.format("%5d", totOfTot))
   end

   return
end



function cD.initTotalsWindow()

   local zn, tbl     =  nil, {}
   local parentOBJ   =  cD.sTOFrames[TOTALSFRAME]
   local znTot       =  0
   local totMfJ      =  0
   local totOfTot    =  0

   -- Inject Legend into Table 1st row - begin
   local legendZnName   =  "Zone Name"
   local legendTbl      =  { "jnk", "Com", "Unc" , "Rar" , "Epi" , "Qst", "Rel", "MfJ", "Total" }
   local legendFrame, legendZnOBJ, legendTotOBJs = cD.createTotalsLine(parentOBJ, legendZnName, nil, legendTbl, true)

   table.insert(cD.sTOzoneIDs,   legendZnName)
   table.insert(cD.sTOFrame,     legendFrame)
   table.insert(cD.sTOznOBJs,    legendZnOBJ)

   cD.sTOcntOBJs[legendZnName] = legendTotOBJs
   parentOBJ   =  legendFrame
   -- Inject Legend into Table 1st row - end


   for zn, tbl in pairs(cD.zoneTotalCnts) do

      local znName   =  Inspect.Zone.Detail(zn).name
      local znID     =  Inspect.Zone.Detail(zn).id
      local totalsFrame, znOBJ, totOBJs = cD.createTotalsLine(parentOBJ, znName, znID, tbl)

      table.insert(cD.sTOzoneIDs,   zn)
      table.insert(cD.sTOFrame,     totalsFrame)
      table.insert(cD.sTOznOBJs,    znOBJ)
      cD.sTOcntOBJs[znID] = totOBJs

      parentOBJ   =  totalsFrame
      znTot       =  znTot + 1

      --
      -- FOR STATUS BAR
      --
      -- calculate and add to totMfJ MfJ for this zone
      totMfJ = totMfJ + tbl[8]   -- field number 8 in MfJ per zone

      -- calculate and add to totOfTot totals for this zone
      local idx  =  nil
      for idx=1, 7 do totOfTot = totOfTot + tbl[idx] end
   end

   cD.updateTotalsStatusBar(znTot, totMfJ, totOfTot)

   return
   end

