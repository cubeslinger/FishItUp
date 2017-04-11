--
-- Addon       _fiu_gui_TotAndcache.lua
-- Author      marcob@marcob.org
-- StartDate   08/04/2017
-- StartDate   09/03/2017
--

local addon, cD = ...

local TITLEBARTOTALSFRAME     =  1
local TITLEBARTCONTENTFRAME   =  2
local EXTERNALTOTALSFRAME     =  3
local TOTALSMASKFRAME         =  4
local TOTALSFRAME             =  5

local tWINWIDTH               =  516
local tWINHEIGHT              =  310
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

local function reverseTable(t)
   local reversedTable = {}
   local itemCount = #t
   for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
   end
   return reversedTable
end

local function fetchFromILStock()
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

   return retval
end

local function multiLineString(s, size)

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

local function createZoneItemLine(parent, t)

   local first    = true
   local lastobj  =  nil

   if parent == nil then
      parent = cD.sCACFrames["CACHEITEMSFRAME"]
   else
      first = false
   end

   local zil, zilIcon, zilName, zilDesc, zilCat = nil, nil, nil, nil, nil

   local fromILStock = fetchFromILStock()

   if fromStock == nil then

      zil =  UI.CreateFrame("Frame", "Zone_item_Frame", cD.sCACFrames["CACHEITEMSFRAME"])
      zil:SetBackgroundColor(.2, .2, .2, .6)
      if first then
         first = false
         zil:SetPoint("TOPLEFT",  cD.sCACFrames["CACHEITEMSFRAME"], "TOPLEFT",  0, 1)
         zil:SetPoint("TOPRIGHT", cD.sCACFrames["CACHEITEMSFRAME"], "TOPRIGHT", 0, 1)
      else
         zil:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT",  0, 2)
         zil:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, 2)
      end
      zil:SetLayer(3)

      -- ITEM NAME
      --    { id=itemID, name=itemName, rarity=itemRarity, description=itemDesc, category=itemCategory, icon=itemIcon, value=itemValue, zone=itemZone }
      zilName = UI.CreateFrame("Text", "Item_name", zil)
      zilName:SetFont(cD.addon, cD.text.base_font_name)
      zilName:SetFontSize(cD.text.base_font_size)
      local txtColor =  cD.rarityColor(t.rarity)
      zilName:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
      zilName:SetText(t.name)
      zilName:SetPoint("TOPLEFT",  zil, "TOPLEFT",  cD.borders.left, 0)

      -- setup Loot Item's Icon
      zilIcon =  UI.CreateFrame("Texture", "Item_Icon_" .. t.name, zil)
      zilIcon:SetTexture("Rift", t.icon)
      zilIcon:SetHeight(32)
      zilIcon:SetWidth(32)
      zilIcon:SetPoint("TOPLEFT",      zilName, "BOTTOMLEFT", 0, 1)

      local flavor   =  t.flavor or "n/a"
      zilFlav = UI.CreateFrame("Text", "Item_name", zil)
      zilFlav:SetFont(cD.addon, cD.text.base_font_name)
      zilFlav:SetFontSize(cD.text.base_font_size -2)
      local txtColor =  cD.rarityColor("relic")
      zilFlav:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
      local dText = multiLineString(flavor, itemsMaxLENGTH)
      zilFlav:SetText(dText)
      zilFlav:SetPoint("TOPLEFT",  zilIcon, "TOPRIGHT", cD.borders.left, 0)
      lastobj  =  zilFlav

      local description =  t.description or "n/a"
      zilDesc = UI.CreateFrame("Text", "Item_name", zil)
      zilDesc:SetFont(cD.addon, cD.text.base_font_name)
      zilDesc:SetFontSize(cD.text.base_font_size -2)
      local txtColor =  cD.rarityColor("quest")
      zilDesc:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
      local dText = multiLineString(description, itemsMaxLENGTH)
      zilDesc:SetText(dText)
      zilDesc:SetPoint("TOPLEFT",  zilIcon, "BOTTOMLEFT", 0, cD.borders.top)
      lastobj  =  zilDesc

      local H = zilDesc:GetBottom() - zil:GetTop()
      zil:SetHeight(H)
      print("HEIGHT ["..H.."]")

      local tmp   =  {}
      tmp         =  {
         inUse    =  true,
         zil      =  zil,
         zilIcon  =  zilIcon,
         zilName  =  zilName,
         zilCat   =  zilCat,
         zilDesc  =  zilDesc,
      }

      table.insert(ILStock, tmp)
      tmp   =  {}
   else
      --
      -- We recycle an old set of object, so we need just
      -- to put in new values
      --
            lootFrame      =  fromStock.lootFrame
      zil      =  fromILStock.zil
      zilIcon  =  fromILStock.zilIcon
      zilName  =  fromILStock.zilName
      zilCat   =  fromILStock.zilCat
      zilDesc  =  fromILStock.zilDesc

      zilIcon:SetTexture("Rift", t.icon)

      local txtColor =  cD.rarityColor(t.rarity)
      zilName:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
      zilName:SetText(t.name)

      zilCat:SetText("("..t.category..")")

      if t.description then
         ilDesc:SetVisible(true)
         local dText = multiLineString(t.description, itemsMaxLENGTH)
         zilDesc:SetText(dText)
      else
         ilDesc:SetVisible(false)
      end

      zil:SetVisible(true)

   end

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
   end

   -- reparent itemFrame to MaskFrame to reset ScrollBar movements
   cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT", cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT")

   return
end


local function populateZoneItemsList(znID, zoneName)

   local parent   =  nil
   local cnt      =  0
   local frameH   =  0

   for iobj, t in pairs(cD.itemCache) do

      if t.zone   == znID  then
         local z  =  createZoneItemLine(parent, t)
         parent   =  z
         cnt      =  cnt + 1
         frameH   =  frameH + z:GetHeight()
      end
   end

   if cnt > 0 then
      frameH   =  frameH + cnt -- there's a 1 pixel separator between items, so be add it
      print("ITEMS ["..cnt.."]")
      cfScroll:SetRange(1, cnt)
--       ilScrollStep   = math.floor(frameH / cnt)
--       print("ScrollSTEP ["..ilScrollStep.."]")
   end

   return
end


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
      cD.sCACFrames["CACHEITEMSEXTFRAME"]:SetVisible(true)
   else
      cD.sCACFrames["CACHEITEMSEXTFRAME"]:SetVisible(false)
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


   -- -----------------------------------------------------------------------------
   local itemsExtFrame = UI.CreateFrame("Frame", "Cache_Items_Excternal_frame", totalsWindow)
--    itemsExtFrame:SetBackgroundColor(0, 0, 0, 1)
   itemsExtFrame:SetBackgroundColor(.2, .2, .2, 1)
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
   itemsMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["CACHEITEMSEXTFRAME"], "TOPRIGHT")
   itemsMaskFrame:SetPoint("BOTTOMRIGHT", cD.sCACFrames["CACHEITEMSEXTFRAME"], "BOTTOMRIGHT")

   itemsMaskFrame:SetLayer(4)
   cD.sCACFrames["CACHEITEMSMASKFRAME"]  = itemsMaskFrame

   -- CACHE ZONE ITEMS CONTAINER FRAME
   local cacheFrame =  UI.CreateFrame("Frame", "Cache_Items_frame", cD.sCACFrames["CACHEITEMSMASKFRAME"])
   cacheFrame:SetAllPoints(cD.sCACFrames["CACHEITEMSMASKFRAME"])
   cacheFrame:SetPoint("TOPLEFT", itemsMaskFrame, "TOPLEFT")
   cacheFrame:SetBackgroundColor(0, 0, 0, .6)   -- GREEN
   cacheFrame:SetLayer(4)
   cD.sCACFrames["CACHEITEMSFRAME"]  =   cacheFrame

   -- CACHE ZONE ITEMS SCROLLBAR
   cfScroll = UI.CreateFrame("RiftScrollbar","item_list_scrollbar", cD.sCACFrames["CACHEITEMSEXTFRAME"])
   cfScroll:SetVisible(true)
   cfScroll:SetEnabled(true)
   cfScroll:SetWidth(sbWIDTH)
   cfScroll:SetOrientation("vertical")
   cfScroll:SetPoint("TOPLEFT",     cD.sCACFrames["CACHEITEMSEXTFRAME"],   "TOPRIGHT",    -(cD.borders.right/2)+1, 0)
   cfScroll:SetPoint("BOTTOMLEFT",  cD.sCACFrames["CACHEITEMSEXTFRAME"],   "BOTTOMRIGHT", -(cD.borders.right/2)+1, 0)
   cfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                              function()
                                 cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT", cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT", 0, -ilScrollStep*cfScroll:GetPosition() )
                              end,
                              "ItemsFrame_Scrollbar.Change"
                        )
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
      mfjTotal:SetWidth(cD.text.base_font_size * 4)
      if isLegend then
         mfjTotal:SetText(string.format("%5s", zoneTotals[8]), true)
      else
         mfjTotal:SetText(string.format("%5s", cD.printJunkMoney(zoneTotals[8])), true)
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

   function cD.initTotalsWindow()

      local zn, tbl     =  nil, {}
      local parentOBJ   =  cD.sTOFrames[TOTALSFRAME]

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
      end

      return
   end
