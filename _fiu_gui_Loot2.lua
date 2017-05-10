--
-- Addon       _fiu_gui_Loot.lua
-- Version     0.4
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   13/03/2017
--

local addon, cD = ...

local MASKFRAME         =  2
local LOOTFRAME         =  3
local LOOTSCROLLBAR     =  4
local POLECASTBUTTON    =  5
local EXTERNALLOOTFRAME =  6
local tLOOTNAMESIZE     =  172

function cD.createLootWindow()

   --Global context (parent frame-thing).
   local context = UI.CreateContext("Loot_context")

   local lootWindow    =  UI.CreateFrame("Frame", "Loot", context)

   -- Clamp to InfoWindow Bottom
   lootWindow:SetPoint("TOPLEFT",   cD.window.infoOBJ, "BOTTOMLEFT",  0, 1)
   lootWindow:SetPoint("TOPRIGHT",  cD.window.infoOBJ, "BOTTOMRIGHT", 0, 1)

   lootWindow:SetWidth(cD.window.width)
   lootWindow:SetLayer(-1)
   lootWindow:SetBackgroundColor(0, 0, 0, .5)

   -- EXTERNAL LOOT CONTAINER FRAME
   local externaLootFrame =  UI.CreateFrame("Frame", "External_Loot_Frame", lootWindow)
   externaLootFrame:SetPoint("TOPLEFT",     lootWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   externaLootFrame:SetPoint("TOPRIGHT",    lootWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   externaLootFrame:SetPoint("BOTTOMLEFT",  lootWindow, "BOTTOMLEFT",  cD.borders.left,    - cD.borders.bottom)
   externaLootFrame:SetPoint("BOTTOMRIGHT", lootWindow, "BOTTOMRIGHT", - cD.borders.right, - cD.borders.bottom)
   --    externaLootFrame:SetBackgroundColor(.6, .6, .6, .3)
   externaLootFrame:SetBackgroundColor(.2, .2, .2, .5)
   externaLootFrame:SetLayer(1)
   cD.sLTFrames[EXTERNALLOOTFRAME]  =   externaLootFrame

   -- MASK FRAME
   local maskFrame = UI.CreateFrame("Mask", "Loot_Mask_Frame", cD.sLTFrames[EXTERNALLOOTFRAME])
   maskFrame:SetAllPoints(cD.sLTFrames[EXTERNALLOOTFRAME])
   cD.sLTFrames[MASKFRAME]  = maskFrame

   -- LOOT CONTAINER FRAME
   local lootFrame =  UI.CreateFrame("Frame", "loot_frame", cD.sLTFrames[MASKFRAME])
   lootFrame:SetAllPoints(cD.sLTFrames[MASKFRAME])
   lootFrame:SetLayer(1)
   cD.sLTFrames[LOOTFRAME]  =   lootFrame

   lootWindow:SetHeight( cD.borders.top + cD.sLTFrames[LOOTFRAME]:GetHeight() + cD.borders.bottom)

   -- Enable Dragging
   Library.LibDraggable.draggify(lootWindow, cD.updateGuiCoordinates)

   return lootWindow

end

function cD.createLootLine(parent, txtCnt, lootOBJ, fromHistory)

   local lootFrame      =  nil
   local typeIconFrame  =  nil
   local typeIcon       =  nil
   local lootIconFrame  =  nil
   local lootIcon       =  nil
   local lootCnt        =  nil
   local textOBJ        =  nil
   local prcntCnt       =  nil
   --
   local itemID         =  nil
   local itemName       =  nil
   local itemRarity     =  nil
   local itemDesc       =  nil
   local itemCat        =  nil
   local itemIcon       =  nil
   local itemValue      =  nil
   local itemZone       =  nil

   if fromHistory == nil then fromHistory = false end

   if fromHistory == true then
      itemID      =  cD.itemCache[lootOBJ].id
      itemName    =  cD.itemCache[lootOBJ].name
      itemRarity  =  cD.itemCache[lootOBJ].rarity
      itemDesc    =  cD.itemCache[lootOBJ].description
      itemCat     =  cD.itemCache[lootOBJ].category
      itemIcon    =  cD.itemCache[lootOBJ].icon
      itemValue   =  cD.itemCache[lootOBJ].value
      itemZone    =  cD.itemCache[lootOBJ].zone
      itemFlavor  =  cD.itemCache[lootOBJ].flavor
      if itemValue == nil then itemValue = 0 end
   else
      itemID      =  Inspect.Item.Detail(lootOBJ).id
      itemName    =  Inspect.Item.Detail(lootOBJ).name
--       itemRarity  =  Inspect.Item.Detail(lootOBJ).rarity
      itemRarity  =  (Inspect.Item.Detail(lootOBJ).rarity  or "common") -- Some items don't have a rarity (ex.: Bundles), we default to common
      itemDesc    =  Inspect.Item.Detail(lootOBJ).description
      itemCat     =  Inspect.Item.Detail(lootOBJ).category
      itemIcon    =  Inspect.Item.Detail(lootOBJ).icon
      itemValue   =  Inspect.Item.Detail(lootOBJ).sell
      itemFlavor  =  Inspect.Item.Detail(lootOBJ).flavor
      itemZone    =  Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
      if itemValue == nil then itemValue = 0 end
   end


   local fromStock = fetchFromStock()

   if fromStock   == nil   then
      -- setup Loot Item's containing Frame
      lootFrame =  UI.CreateFrame("Frame", "Loot_line_Container", parent)
      lootFrame:SetHeight(cD.text.base_font_size + 2)
      lootFrame:SetLayer(1)

      -- attach to the last object present in loot table
      if table.getn(cD.sLTids) > 0 then
         lootFrame:SetPoint("TOPLEFT", cD.sLTfullOBJs[table.getn(cD.sLTids)], "BOTTOMLEFT", 0, cD.borders.top)
      else
         lootFrame:SetPoint("TOPLEFT",    parent, "TOPLEFT",  0, cD.borders.top)
         lootFrame:SetPoint("TOPRIGHT",   parent, "TOPRIGHT", 0, cD.borders.top)
      end

--       lootFrame:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(itemZone, itemID) end, "Item Selected" )

      --
      -- Actually we draw Icons for just 2 itemtypes: Exchangeable Fishes and Artifacts.
      --
      local categoryIcon  =  nil
      categoryIcon  =  cD.categoryIcon(itemCat, lootOBJ, itemDesc, itemName)

      -- setup Loot Item's Type Icon
      typeIcon = UI.CreateFrame("Texture", "Type_Icon_" .. itemName, lootFrame)
      if  categoryIcon ~= nil then typeIcon:SetTexture("Rift", categoryIcon)  end
      typeIcon:SetWidth(cD.text.base_font_size)
      typeIcon:SetHeight(cD.text.base_font_size)
      typeIcon:SetPoint("TOPLEFT",   lootFrame, "TOPLEFT", cD.borders.left, 0)
      typeIcon:SetLayer(3)

      -- setup Loot Item's Icon
      lootIcon = UI.CreateFrame("Texture", "Loot_Icon_" .. itemName, lootFrame)
      lootIcon:SetTexture("Rift", itemIcon)
      lootIcon:SetWidth(cD.text.base_font_size)
      lootIcon:SetHeight(cD.text.base_font_size)
      lootIcon:SetPoint("TOPLEFT",   typeIcon, "TOPRIGHT", cD.borders.left, 0)
      lootIcon:SetLayer(3)

      -- setup Loot Item's Counter
      lootCnt  =  UI.CreateFrame("Text", "Loot_Cnt_" .. itemName, lootFrame)
      lootCnt:SetFont(cD.addon, cD.text.base_font_name)
      lootCnt:SetFontSize(cD.text.base_font_size )
      lootCnt:SetText(string.format("%3d", txtCnt))
      lootCnt:SetLayer(3)
      lootCnt:SetPoint("TOPLEFT",   lootIcon, "TOPRIGHT", cD.borders.left, -4)
      --
      -- setup Loot Item's Text Color based on Loot Item Rarity
      --
      -- RARITY: all "common" items have a rarity of nil
      --         "trash" has been renamed sellable
      --
      textOBJ     =  UI.CreateFrame("Text", "Loot_" .. itemName, lootFrame)
      local objRarity   =  itemRarity
      if objRarity == nil then objRarity   =  "common" end

      local objColor =  cD.rarityColor(objRarity)
      local lootText =  itemName
      textOBJ:SetFont(cD.addon, cD.text.base_font_name)
      lootText =  string.sub(lootText, 1, 20)
      textOBJ:SetFontSize(cD.text.base_font_size )
      textOBJ:SetHeight(cD.text.base_font_size)
      textOBJ:SetWidth(tLOOTNAMESIZE)
      -- we pack Junk/Sellable Items
      if objRarity == "sellable" then
         cD.totJunkMoney = cD.totJunkMoney + itemValue
         lootText  =  "Junk "..cD.printJunkMoney(cD.totJunkMoney)
      end
      textOBJ:SetText(lootText, true)
      textOBJ:SetLayer(3)
      textOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
      textOBJ:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(itemZone, itemID) end, "Item Selected" )
-- ZZZZ  -----------------------------------------------------------------------------------------
      -- Mouse Hover IN    => show tooltip   -- cD.selectItemtoView(t.zone, t.id)
--       textOBJ:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()  Command.Tooltip(lootOBJ) end, "Event.UI.Input.Mouse.Cursor.In")
      textOBJ:EventAttach(Event.UI.Input.Mouse.Cursor.In, function() cD.selectItemtoView(itemZone, lootOBJ)  end, "Event.UI.Input.Mouse.Cursor.In")
      -- Mouse Hover OUT   => show tooltip
--       textOBJ:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() Command.Tooltip(nil) end, "Event.UI.Input.Mouse.Cursor.Out")
      textOBJ:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function() cD.selectItemtoView(nil, nil) end, "Event.UI.Input.Mouse.Cursor.Out")

-- ZZZZ  -----------------------------------------------------------------------------------------


      textOBJ:SetPoint("TOPLEFT",   lootCnt,    "TOPRIGHT", cD.borders.left, 0)

      -- setup Loot Item's Percentage counter
      prcntCnt  =  UI.CreateFrame("Text", "Percent_" .. itemName, lootFrame)
      prcntCnt:SetFont(cD.addon, cD.text.base_font_name)
      prcntCnt:SetFontSize(cD.text.base_font_size -2)
      prcntCnt:SetText(string.format("(%d", 0).."%)")
      prcntCnt:SetLayer(3)
      prcntCnt:SetPoint("TOPLEFT",  textOBJ,    "TOPRIGHT", cD.borders.left, 0)

      local tmp   =  {}
      tmp         =  {
                     inUse           =  true,
                     lootFrame       =  lootFrame,
                     typeIcon        =  typeIcon,
                     lootIcon        =  lootIcon,
                     lootCnt         =  lootCnt,
                     textOBJ         =  textOBJ,
                     prcntCnt        =  prcntCnt
                     }

      table.insert(cD.Stock, tmp)
   else
      --
      -- We recycle an old set of object, so we need just
      -- to put in new values
      --
      lootFrame      =  fromStock.lootFrame
      typeIcon       =  fromStock.typeIcon
      lootIcon       =  fromStock.lootIcon
      lootCnt        =  fromStock.lootCnt
      textOBJ        =  fromStock.textOBJ
      prcntCnt       =  fromStock.prcntCnt


--       lootFrame:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(itemZone, itemID) end, "Item Selected" )

      --
      -- Actually we draw Icons for just 2 itemtypes: Quests and Artifacts.
      --
      local categoryIcon  =  nil
      categoryIcon  =  cD.categoryIcon(itemCat, lootOBJ, itemDesc, itemName)
      if  categoryIcon ~= nil then
         typeIcon:SetTexture("Rift", categoryIcon)
         typeIcon:SetVisible(true)
      end

      -- setup Loot Item's Icon
      lootIcon:SetTexture("Rift", itemIcon)

      -- setup Loot Item's Counter
      lootCnt:SetText(string.format("%3d", txtCnt))

      --
      -- setup Loot Item's Text Color based on Loot Item Rarity
      --
      local objColor    =  cD.rarityColor(itemRarity)
      local lootText    =  itemName

      if objRarity == nil then objRarity   =  "common" end

      lootText =  string.sub(lootText, 1, 20)
      -- we pack Junk/Sellable Items
      if objRarity == "sellable" then
         cD.totJunkMoney = cD.totJunkMoney + itemValue
         lootText  =  "Junk "..cD.printJunkMoney(cD.totJunkMoney)
      end
      textOBJ:SetText(lootText, true)
      textOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
      textOBJ:EventAttach(Event.UI.Input.Mouse.Left.Click, function() cD.selectItemtoView(itemZone, itemID) end, "Item Selected" )

      -- setup Loot Item's Percentage counter
      prcntCnt:SetText(string.format("(%d", 0).."%)")

      --
      -- finally we set the whole container Frame visible but
      -- only in infoWindow is visible too.
      --
      if cD.window.infoOBJ:GetVisible() == true then lootFrame:SetVisible(true) end

   end

   return   textOBJ, lootFrame, lootCnt, prcntCnt
end

function  cD.resetLootWindow(manual)
   --
   -- Reset Indexes
   --
   cD.sLTids      =  {}
   cD.sLTcnts     =  {}
   cD.sLTprcnts   =  {}
   cD.sLTtextOBJs =  {}
   cD.sLTcntsOBJs =  {}
   cD.sLTfullOBJs =  {}
   cD.sLTprcntOBJs=  {}
   cD.sLTrarity   =  {}
   cD.sLTnames    =  {}
   cD.today       =  {  casts=0, }
   if manual then cD.time        =  {  hour=0, mins=0, secs=0 } end
   cD.infoOBJ     =  nil
   --
   -- Set all cD.Stock lootFrames to "invisible"
   -- and set all cD.Stock[].used = false
   --
   local idx, tbl = nil, {}
   for idx, tbl in pairs(cD.Stock) do
      tbl.inUse = false
      tbl.lootFrame:SetVisible(false)
   end
   --
   --
   -- Reset the "Junk" releted
   --
   cD.junkOBJ     =  nil
   cD.totJunkMoney=  0
   --
   -- Reset Last Session History
   --
   if manual then
      local zn = Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
      cD.lastZoneLootOBJs[zn] = nil
   end
   --
   -- list is empty, so nothing to show
   --
   if cD.window.lootOBJ ~= nil then cD.window.lootOBJ:SetVisible(false) end

   return
end

function fetchFromStock()
   local idx, tbl =  nil, {}
   local retval   =  nil

   for idx, tbl in pairs(cD.Stock) do
      if not tbl.inUse then
         retval = tbl
         -- set the frame as INUSE
         cD.Stock[idx].inUse     =  true

         -- stop rendering of old category icon that keeps re-emerging
         cD.Stock[idx].typeIcon:SetVisible(false)

         -- then we try to dereference it, somehow...
         cD.Stock[idx].typeIcon  =  nil

         -- finally we create a new icon and we reference in cD.Stock for future uses
         cD.Stock[idx].typeIcon  = UI.CreateFrame("Texture", "Type_Icon_fromStock_" .. idx, cD.Stock[idx].lootFrame)
         cD.Stock[idx].typeIcon:SetWidth(cD.text.base_font_size)
         cD.Stock[idx].typeIcon:SetHeight(cD.text.base_font_size)
         cD.Stock[idx].typeIcon:SetLayer(3)
         cD.Stock[idx].typeIcon:SetPoint("TOPLEFT",   cD.Stock[idx].lootFrame, "TOPLEFT", cD.borders.left, 0)
         break
      end
   end

   return retval
end

function cD.sortLootTable(parent)
   -- cD.sLTids         contains items IDs:              idx->itemID          => 1 = i00303030303, 2 = i00303030306, ...
   -- cD.sLTfullOBJs    contains full LootLine OBJects:  idx->fullLootFrame   => 1 = objx0a0a0a, 2 = objx0aba0c, ...
   -- cD.sLTrarity      contains ItemID's rarity:        idx->NumericRarity   => 1 = 4, 2 = 1, 3 = 2, ...

   -- reset all Pinned Point of Full loot Frames objs
   local cntPre   =  0
   for idx, obj in pairs(cD.sLTfullOBJs) do
      -- ClearAll() reset also: height, width, so we save Height and then Set it again
      local width    =  obj:GetWidth()
      local height   =  obj:GetHeight()

      obj:ClearAll()
      obj:SetHeight(height)

      -- we hide them while we re-assemble the list
      obj:SetVisible(false)

      cntPre   =  cntPre + 1
   end

   local t     =  cD.sLTrarity
   local keys  =  {}
   local idx   = nil
   for idx, _ in ipairs(t) do table.insert(keys, idx) end
   table.sort(keys, function(a,b) return cD.sLTrarity[a] > cD.sLTrarity[b] end)

   local FIRST    =  true
   local LASTOBJ  =  nil

   for idx, _ in ipairs(keys) do
      if FIRST then
         FIRST = false
         cD.sLTfullOBJs[keys[idx]]:SetPoint("TOPLEFT",    parent, "TOPLEFT",  0, cD.borders.top)
         cD.sLTfullOBJs[keys[idx]]:SetPoint("TOPRIGHT",   parent, "TOPRIGHT", 0, cD.borders.top)
         LASTOBJ = cD.sLTfullOBJs[keys[idx]]
         cD.sLTfullOBJs[keys[idx]]:SetVisible(true)
      else
         cD.sLTfullOBJs[keys[idx]]:SetPoint("TOPLEFT", LASTOBJ, "BOTTOMLEFT", 0, cD.borders.top)
         cD.sLTfullOBJs[keys[idx]]:SetVisible(true)
         LASTOBJ = cD.sLTfullOBJs[keys[idx]]
      end
   end

   --
   -- Resize container window, since now we sort the loottable we
   -- can't trust anymore the last in the array to really be the
   -- last frame, with the lowest X
   --
   local highestX =  0
   local idx      =  nil
   -- find the frame with the lowest bottom Y position
   for idx in pairs(cD.sLTfullOBJs) do if highestX < cD.sLTfullOBJs[idx]:GetBottom() then highestX = cD.sLTfullOBJs[idx]:GetBottom() end end
   cD.window.lootOBJ:SetHeight((highestX - cD.window.lootOBJ:GetTop() ) + (cD.borders.bottom *3))

   return
end
