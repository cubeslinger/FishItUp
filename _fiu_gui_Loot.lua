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
local tLOOTNAMESIZE     =  180

function cD.createLootWindow()

   --Global context (parent frame-thing).
   local context = UI.CreateContext("Loot_context")

   local lootWindow    =  UI.CreateFrame("Frame", "Loot", context)

   if cD.window.lootX == nil or cD.window.lootY == nil then
      -- first run, we position in the screen center
      lootWindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      lootWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.lootX or 0, cD.window.lootY or 0)
   end

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
   --    maskFrame:SetBackgroundColor(1, 0, 0, .3)

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


   if fromHistory == nil then fromHistory = false end
   if fromHistory == true then
      itemID      =  cD.itemCache[lootOBJ].id
      itemName    =  cD.itemCache[lootOBJ].name
      itemRarity  =  cD.itemCache[lootOBJ].rarity
      itemDesc    =  cD.itemCache[lootOBJ].description
      itemCat     =  cD.itemCache[lootOBJ].category
      itemIcon    =  cD.itemCache[lootOBJ].icon
   else
      itemID      =  Inspect.Item.Detail(lootOBJ).id
      itemName    =  Inspect.Item.Detail(lootOBJ).name
      itemRarity  =  Inspect.Item.Detail(lootOBJ).rarity
      itemDesc    =  Inspect.Item.Detail(lootOBJ).description
      itemCat     =  Inspect.Item.Detail(lootOBJ).category
      itemIcon    =  Inspect.Item.Detail(lootOBJ).icon
   end


   local fromStock = fetchFromStock()

   if fromStock   == nil   then
      -- setup Loot Item's containing Frame
      lootFrame =  UI.CreateFrame("Frame", "Loot_line_Container", parent)
      lootFrame:SetHeight(cD.text.base_font_size)
      lootFrame:SetLayer(1)

      -- attach to the last object present in loot table
      if table.getn(cD.sLTids) > 0 then
         lootFrame:SetPoint("TOPLEFT", cD.sLTfullObjs[table.getn(cD.sLTids)], "BOTTOMLEFT", 0, cD.borders.top)
      else
         lootFrame:SetPoint("TOPLEFT",    parent, "TOPLEFT",  0, cD.borders.top)
         lootFrame:SetPoint("TOPRIGHT",   parent, "TOPRIGHT", 0, cD.borders.top)
      end

      -- setup Loot Item's Type Icon Frame
      typeIconFrame = UI.CreateFrame("Texture", "Type_Icon_Frame" .. itemName, lootFrame)
      typeIconFrame:SetHeight(cD.text.base_font_size)
      typeIconFrame:SetWidth(cD.text.base_font_size)
      typeIconFrame:SetLayer(2)
      typeIconFrame:SetPoint("TOPLEFT",   lootFrame, "TOPLEFT", cD.borders.left, 0)

      --
      -- Actually we draw Icons for just 2 itemtypes: Exchangeabel Fishes and Artifacts.
      --
      local categoryIcon  =  nil
      categoryIcon  =  cD.categoryIcon(itemCat, lootOBJ, itemDesc)

      -- setup Loot Item's Type Icon
      typeIcon = UI.CreateFrame("Texture", "Type_Icon_" .. itemName, typeIconFrame)
      if  categoryIcon ~= nil then typeIcon:SetTexture("Rift", categoryIcon) end
      typeIcon:SetWidth(cD.text.base_font_size)
      typeIcon:SetHeight(cD.text.base_font_size)
      typeIcon:SetPoint("CENTER",    typeIconFrame, "CENTER")
      typeIcon:SetLayer(3)

      -- setup Loot Item's Icon Frame
      lootIconFrame = UI.CreateFrame("Texture", "Loot_Icon_Frame" .. itemName, lootFrame)
      lootIconFrame:SetHeight(cD.text.base_font_size)
      lootIconFrame:SetWidth(cD.text.base_font_size)
      lootIconFrame:SetLayer(2)
      lootIconFrame:SetBackgroundColor(0, 0, 0, .5)
      lootIconFrame:SetPoint("TOPLEFT",   typeIconFrame, "TOPRIGHT", cD.borders.left, 0)

      -- setup Loot Item's Icon
      lootIcon = UI.CreateFrame("Texture", "Loot_Icon_" .. itemName, lootIconFrame)
      lootIcon:SetTexture("Rift", itemIcon)
      lootIcon:SetWidth(cD.text.base_font_size - 1)
      lootIcon:SetHeight(cD.text.base_font_size - 1)
      lootIcon:SetPoint("CENTER",    lootIconFrame, "CENTER")
      lootIcon:SetLayer(3)

      -- setup Loot Item's Counter
      lootCnt  =  UI.CreateFrame("Text", "Loot_Cnt_" .. itemName, lootFrame)
      lootCnt:SetFont(cD.addon, "fonts/unispace.ttf")
      lootCnt:SetFontSize(cD.text.base_font_size -2 )
      lootCnt:SetText(string.format("%3d", txtCnt))
      lootCnt:SetLayer(3)
      lootCnt:SetPoint("TOPLEFT",   lootIconFrame, "TOPRIGHT", cD.borders.left, 0)
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
      textOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
      lootText =  string.sub(lootText, 1, 20)
      textOBJ:SetFontSize(cD.text.base_font_size -2 )
      textOBJ:SetHeight(cD.text.base_font_size)
      textOBJ:SetWidth(tLOOTNAMESIZE)
      -- we pack Junk/Sellable Items
      if objRarity == "sellable" then lootText  =  "Sellable (Junk)" end
      textOBJ:SetText(lootText)
      textOBJ:SetLayer(3)
      textOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
      textOBJ:SetPoint("TOPLEFT",   lootCnt,    "TOPRIGHT")

      -- setup Loot Item's Percentage counter
      prcntCnt  =  UI.CreateFrame("Text", "Percent_" .. itemName, lootFrame)
      textOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
      prcntCnt:SetFontSize(cD.text.base_font_size -2 )
      prcntCnt:SetText(string.format("(%2d", 0).."%)")
      prcntCnt:SetLayer(3)
      prcntCnt:SetPoint("TOPLEFT",  textOBJ,    "TOPRIGHT", cD.borders.left, 0)

      local tmp   =  {}
      tmp         =  {  inUse           =  true,
         lootFrame       =  lootFrame,
         typeIconFrame   =  typeIconFrame,
         typeIcon        =  typeIcon,
         lootIconFrame   =  lootIconFrame,
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
      typeIconFrame  =  fromStock.typeIconFrame
      typeIcon       =  fromStock.typeIcon
      lootIconFrame  =  fromStock.lootIconFrame
      lootIcon       =  fromStock.lootIcon
      lootCnt        =  fromStock.lootCnt
      textOBJ        =  fromStock.textOBJ
      prcntCnt       =  fromStock.prcntCnt

      --
      -- Actually we draw Icons for just 2 itemtypes: Quests and Artifacts.
      --
      local categoryIcon  =  nil
      categoryIcon  =  cD.categoryIcon(itemCat, lootOBJ, itemDesc)
      if  categoryIcon ~= nil then  typeIcon:SetTexture("Rift", categoryIcon) end

      -- setup Loot Item's Icon
      lootIcon:SetTexture("Rift", Inspect.Item.Detail(lootOBJ).icon)

      -- setup Loot Item's Counter
      lootCnt:SetText(string.format("%3d", txtCnt))

      --
      -- setup Loot Item's Text Color based on Loot Item Rarity
      --
            local objRarity   =  Inspect.Item.Detail(lootOBJ).rarity
      local objColor    =  cD.rarityColor(objRarity)
      local lootText    =  Inspect.Item.Detail(lootOBJ).name

      if objRarity == nil then objRarity   =  "common" end

      lootText =  string.sub(lootText, 1, 20)
      -- we pack Junk/Sellable Items
      if objRarity == "sellable" then lootText  =  "Sellable (Junk)" end
      textOBJ:SetText(lootText)
      textOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)

      -- setup Loot Item's Percentage counter
      prcntCnt:SetText(string.format("(%2d)", 0).."%")

      --
            -- finally we set the whole container Frame visible
      --
            lootFrame:SetVisible(true)

   end

   return   textOBJ, lootFrame, lootCnt, prcntCnt
end

function  cD.resetLootWindow()
   --
   -- Reset Indexes
   --
   cD.sLTids      =  {}
   cD.sLTcnts     =  {}
   cD.sLTprcnts   =  {}
   cD.sLTtextObjs =  {}
   cD.sLTcntsObjs =  {}
   cD.sLTfullObjs =  {}
   cD.sLTprcntObjs=  {}
   cD.sLTrarity   =  {}
   cD.today       =  {  casts=0, }
   cD.time        =  {  hour=0, mins=0, secs=0 }
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
   -- Reset the "Junk" pointer
   --
   cD.junkOBJ     =  nil
   --
   -- Reset Last Session History
   --
   local zn = Inspect.Zone.Detail(Inspect.Unit.Detail("player").zone).id
   cD.lastZoneLootObjs[zn] = nil

   return
end

function fetchFromStock()
   local idx, tbl =  nil, {}
   local retval   =  nil

   for idx, tbl in pairs(cD.Stock) do
      if not tbl.inUse then
         retval = tbl
         cD.Stock[idx].inUse  =  true
         break
      end
   end

   return retval
end

function cD.sortLootTable(parent)
   -- cD.sLTids         contains items IDs:              idx->itemID          => 1 = i00303030303, 2 = i00303030306, ...
   -- cD.sLTfullObjs    contains full LootLine Objects:  idx->fullLootFrame   => 1 = objx0a0a0a, 2 = objx0aba0c, ...
   -- cD.sLTrarity      contains ItemID's rarity:        idx->NumercRarity    => 1 = 4, 2 = 1, 3 = 2, ...

   -- reset all Pinned Point of Full loot Frames objs
   local cntPre   =  0
   for idx, obj in pairs(cD.sLTfullObjs) do
      -- ClearAll() reset also: height, width, so we save Height and then Set it again
      local width    =  obj:GetWidth()
      local height   =  obj:GetHeight()

      obj:ClearAll()
      obj:SetHeight(height)

      cntPre   =  cntPre + 1
   end

   local t     =  cD.sLTrarity
   local keys  =  {}
   local idx, value = nil, nil
   for idx, value in ipairs(t) do table.insert(keys, idx) end
   table.sort(keys, function(a,b) return cD.sLTrarity[a] > cD.sLTrarity[b] end)

   local FIRST    =  true
   local LASTOBJ  =  nil
   local cntPost  =  0

   for idx, value in ipairs(keys) do
      if FIRST then
         FIRST = false
         cD.sLTfullObjs[keys[idx]]:SetPoint("TOPLEFT",    parent, "TOPLEFT",  0, cD.borders.top)
         cD.sLTfullObjs[keys[idx]]:SetPoint("TOPRIGHT",   parent, "TOPRIGHT", 0, cD.borders.top)
         LASTOBJ = cD.sLTfullObjs[keys[idx]]
      else
         cD.sLTfullObjs[keys[idx]]:SetPoint("TOPLEFT", LASTOBJ, "BOTTOMLEFT", 0, cD.borders.top)
         LASTOBJ = cD.sLTfullObjs[keys[idx]]
      end

      cntPost = cntPost + 1

      --
      -- Resize container window, since now we sort the loottable we
      -- can't trust anymore the last in the array to really be the
      -- last frame, with the lowest X
      --
      local highestX =  0
      local idx      =  nil
      -- find the frame with the lowest bottom Y position
      for idx in pairs(cD.sLTfullObjs) do if highestX < cD.sLTfullObjs[idx]:GetBottom() then highestX = cD.sLTfullObjs[idx]:GetBottom() end end
      cD.window.lootObj:SetHeight((highestX - cD.window.lootObj:GetTop() ) + (cD.borders.bottom *3))


   end

--    print(string.format("Cleared [%s] re-assigned [%s]", cntPre, cntPost))

   return
end