--
-- Addon       _fiu_gui_Cache.lua
-- Version     0.1
-- Author      marcob@marcob.org
-- StartDate   04/04/2017
-- StartDate   04/04/2017
--

local addon, cD = ...

local tWINWIDTH      =  450
local tWINHEIGTH     =  200
local znListWIDTH    =  150
local itemsSBWIDTH   =  8

local function resetZoneItems()
   print("resetZoneItems: STILL DO TO")

   return
end

local function resetZoneItemsList()
   print("resetZoneItemsList: STILL DO TO")
end

local function createZoneItemLine(parent, t)

   local first    = true
   local lastobj  =  nil

   if parent == nil then
      parent = cD.sCACFrames["CACHEITEMSFRAME"]
   else
      first = false
   end

   print("Cliked!")

   local zil, zilName, zilDesc, zilCat = nil, nil, nil, nil

   zil =  UI.CreateFrame("Frame", "Zone_item_Frame", cD.sCACFrames["CACHEITEMSFRAME"])
   if first then
      first = false
      zil:SetPoint("TOPLEFT",  cD.sCACFrames["CACHEITEMSFRAME"], "TOPLEFT",  0, 1)
      zil:SetPoint("TOPRIGHT", cD.sCACFrames["CACHEITEMSFRAME"], "TOPRIGHT", 0, 1)
   else
      zil:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT",  0, 2)
      zil:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, 2)
   end
   zil:SetLayer(1)

   -- setup Loot Item's Icon
   zilIcon =  UI.CreateFrame("Texture", "Item_Icon_" .. t.name, zil)
   zilIcon:SetTexture("Rift", t.icon)
   zilIcon:SetHeight(zilIcon:GetHeight())
   zilIcon:SetWidth(zilIcon:GetWidth())
   zilIcon:SetPoint("TOPLEFT",      zil, "TOPLEFT",      cD.borders.left, 0)
--    zilIcon:SetPoint("BOTTOMLEFT",   zil, "BOTTOMLEFT",   cD.borders.left, 0)
   zilIcon:SetLayer(3)

--    { id=itemID, name=itemName, rarity=itemRarity, description=itemDesc, category=itemCategory, icon=itemIcon, value=itemValue, zone=itemZone }
   zilName = UI.CreateFrame("Text", "Item_name", zil)
   zilName:SetLayer(3)
   zilName:SetFont(cD.addon, cD.text.base_font_name)
   zilName:SetFontSize(cD.text.base_font_size)
   local txtColor =  cD.rarityColor(t.rarity)
   zilName:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
   zilName:SetBackgroundColor(.2, .2, .2, .5)
   zilName:SetText(t.name)
   zilName:SetPoint("TOPLEFT",  zilIcon, "TOPRIGHT",  cD.borders.left, 0)

   zilCat = UI.CreateFrame("Text", "Item_name", zil)
   zilCat:SetLayer(3)
   zilCat:SetFont(cD.addon, cD.text.base_font_name)
   zilCat:SetFontSize(cD.text.base_font_size -2 )
   local txtColor =  cD.rarityColor("common")
   zilCat:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
   zilCat:SetBackgroundColor(.2, .2, .2, .5)
   zilCat:SetText("("..t.category..")")
   zilCat:SetPoint("BOTTOMLEFT",  zilIcon, "BOTTOMRIGHT", cD.borders.left, 0)
--    zilName:SetPoint("RIGHT", zil, "RIGHT",  -cD.borders.right, 0)

   lastobj  =  zilCat

   if t.description ~= nil then
      zilDesc = UI.CreateFrame("Text", "Item_name", zil)
      zilDesc:SetLayer(3)
      zilDesc:SetFont(cD.addon, cD.text.base_font_name)
      zilDesc:SetFontSize(cD.text.base_font_size -2)
      local txtColor =  cD.rarityColor("t.rarity")
      zilDesc:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
      zilDesc:SetBackgroundColor(.2, .2, .2, .5)
      zilDesc:SetText(t.description)
      zilDesc:SetPoint("TOPLEFT",  zilIcon, "BOTTOMLEFT", 0, 2)
      lastobj  =  zilDesc
   end

   -- HEADER   -- GRPAHIC SEPARATOR CONTAINER Header
   local zilCont1  =  UI.CreateFrame("Text", "item_list_bottom_separator_container", zil)
   zilCont1:SetHeight(cD.text.base_font_size)
   zilCont1:SetLayer(1)
   zilCont1:SetPoint("TOPLEFT",  lastobj, "BOTTOMLEFT",  cD.borders.left,  cD.borders.top)
   zilCont1:SetPoint("TOPRIGHT", lastobj, "BOTTOMRIGHT", 0, cD.borders.top)

   -- HEADER GRAPHIC SEPARATOR
   local zilGSep1 = UI.CreateFrame("Texture", "item_list_bottom_separator", zil)
   zilGSep1:SetTexture("Rift", "line_window_break.png.dds")
   zilGSep1:SetHeight(cD.text.base_font_size)
   zilGSep1:SetWidth(zilCont1:GetWidth())
   zilGSep1:SetLayer(1)
   zilGSep1:SetPoint("CENTER", zilCont1, "CENTER")

   if zilDesc ~= nil then
      zil:SetHeight((zil:GetHeight() + zilDesc:GetHeight() + zilCont1:GetHeight()) + 2)
   else
      zil:SetHeight(zil:GetHeight() + zilCont1:GetHeight() + 2)
   end


   return zil

end

local function populateZoneItemsList(znID, zoneName)

   local parent   = nil

   resetZoneItemsList()

   for iobj, t in pairs(cD.itemCache) do

      if t.zone   == znID  then

         local z = createZoneItemLine(parent, t)
         parent = z

      end
   end

   return
end

local function createZoneLine(parent, znID, zoneName)
   print("zoneName ["..zoneName.."]")

--    parent = parent or cD.sCACFrames["ZONECACHEFRAME"]

   local znLine =  UI.CreateFrame("Text", "Zone_Line", parent or cD.sCACFrames["ZONECACHEFRAME"])
   znLine:SetLayer(3)
   znLine:SetFont(cD.addon, cD.text.base_font_name)
   znLine:SetFontSize(cD.text.base_font_size)
   local txtColor =  cD.rarityColor("common")
   znLine:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
   znLine:SetBackgroundColor(.2, .2, .2, .5)
   znLine:SetText(zoneName)
   znLine:EventAttach(Event.UI.Input.Mouse.Left.Click, function() populateZoneItemsList(znID, zoneName) end, "Zone Selected" )

   if parent == nil then
      znLine:SetPoint("TOPLEFT",  cD.sCACFrames["ZONECACHEFRAME"], "TOPLEFT",  1,  1)
      znLine:SetPoint("TOPRIGHT", cD.sCACFrames["ZONECACHEFRAME"], "TOPRIGHT", -1, 1)
   else
      znLine:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT")
      znLine:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT")
   end
   return znLine
end

local function populateZoneList()

   local iobj, t     =  nil, {}
   local zones       =  {}
   local znID, znName=  nil, nil
   local parent      =  nil
   local doneZones   =  {}

   for iobj, t in pairs(cD.itemCache) do
      zones[t.zone] =  Inspect.Zone.Detail(t.zone).name

      if doneZones[t.zone] == nil then
         print("zn load ["..t.zone.."]["..zones[t.zone].."]")
         parent   =  createZoneLine(parent, t.zone, zones[t.zone])
         doneZones[t.zone] = 1
      end
   end

--    cD.sCACFrames["ZONECACHEFRAME"]:SetHeight(lastParent:GetBottom() - cD.sCACFrames["ZONECACHEFRAME"]:GetTop())

   return
end

function cD.createCacheWindow()

   cD.sCACFrames   =  {}

   --Global context (parent frame-thing).
   local context     =  UI.CreateContext("Cache_context")
   local cacheWindow =  UI.CreateFrame("Frame", "Cache", context)

   if cD.window.cacheX == nil or cD.window.cacheY == nil then
      -- first run, we position in the screen center
      cacheWindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      cacheWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.cacheX or 0, cD.window.cacheY or 0)
   end

   cacheWindow:SetWidth(tWINWIDTH)
   cacheWindow:SetHeight(tWINHEIGTH)
   cacheWindow:SetLayer(-1)
   cacheWindow:SetBackgroundColor(0, 0, 0, .5)

   -- TITLE BAR CONTAINER
   local titleCacheFrame =  UI.CreateFrame("Frame", "External_Cache_Frame", cacheWindow)
   titleCacheFrame:SetPoint("TOPLEFT",     cacheWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleCacheFrame:SetPoint("TOPRIGHT",    cacheWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleCacheFrame:SetBackgroundColor(.1, .1, .1, .7)
   titleCacheFrame:SetLayer(1)
   titleCacheFrame:SetHeight(cD.text.base_font_size + 4)
   -- idx = 1
   cD.sCACFrames["TITLEBARCACHEFRAME"]  =   titleCacheFrame

   -- TITLE BAR TITLE
   local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleCacheFrame)
   titleFIU:SetFontSize(cD.text.base_font_size)
   titleFIU:SetText("FIU! Cache Viewer")
   titleFIU:SetFont(cD.addon, cD.text.base_font_name)
   titleFIU:SetLayer(3)
   titleFIU:SetPoint("TOPLEFT", cD.sCACFrames["TITLEBARCACHEFRAME"], "TOPLEFT", cD.borders.left, 0)
   -- idx = 2
   cD.sCACFrames["TITLEBARCONTENTFRAME"]  =   titleFIU


   -- TITLE BAR Widgets: setup Icon for Iconize
   local minimizeIcon = UI.CreateFrame("Texture", "Title_Icon_1", cD.sCACFrames["TITLEBARCACHEFRAME"])
   minimizeIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
   minimizeIcon:SetWidth(cD.text.base_font_size)
   minimizeIcon:SetHeight(cD.text.base_font_size)
   minimizeIcon:SetPoint("TOPRIGHT",   cD.sCACFrames["TITLEBARCACHEFRAME"], "TOPRIGHT", -cD.borders.right, 0)
   minimizeIcon:SetLayer(3)
   minimizeIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.cacheOBJ:SetVisible(not cD.window.cacheOBJ:GetVisible()) end , "Iconize Cache Pressed" )

   titleCacheFrame:SetHeight(cD.text.base_font_size + 6)

   --[[  ZONE CHOOSER ]]-- [[BEGIN]]--
      -- CACHE ZONE LIST MASK FRAME
      local zoneMaskFrame = UI.CreateFrame("Mask", "Cache_Zone_Mask_Frame", cacheWindow)
      zoneMaskFrame:SetPoint("TOPLEFT",     cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMLEFT",  cD.borders.left,    1)
      zoneMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMLEFT",  cD.borders.left + znListWIDTH,    1)
      zoneMaskFrame:SetPoint("BOTTOMLEFT",  cacheWindow, "BOTTOMLEFT",  cD.borders.right,  -cD.borders.bottom)
      cD.sCACFrames["ZONECACHEMASKFRAME"]  = zoneMaskFrame

      -- CACHE ZONE LIST CONTAINER FRAME
      local zoneCacheFrame =  UI.CreateFrame("Frame", "Cache_Zone_frame", cD.sCACFrames["ZONECACHEMASKFRAME"])
      zoneCacheFrame:SetAllPoints(cD.sCACFrames["ZONECACHEMASKFRAME"])
      zoneCacheFrame:SetLayer(1)
      zoneCacheFrame:SetBackgroundColor(.3, .3, .3, .5)
      cD.sCACFrames["ZONECACHEFRAME"]  =   zoneCacheFrame
   --[[  ZONE CHOOSER ]]-- [[END]]--

   --[[  ITEM VIEWER ]]-- [[BEGIN]]--

   local itemsExtFrame = UI.CreateFrame("Frame", "Cache_Items_Excternal_frame", cacheWindow)
   itemsExtFrame:SetPoint("TOPLEFT",     cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMLEFT",  cD.borders.left + znListWIDTH + 1,    1)
   itemsExtFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMRIGHT", -(cD.borders.right), 1)
   itemsExtFrame:SetPoint("BOTTOMRIGHT", cacheWindow, "BOTTOMRIGHT", -cD.borders.right, -cD.borders.bottom)
   cD.sCACFrames["CACHEITEMSEXTFRAME"]  = itemsExtFrame


      -- CACHE ZONE ITEMS MASK FRAME
      local itemsMaskFrame = UI.CreateFrame("Mask", "Cache_Items_Mask_Frame", itemsExtFrame)
      itemsMaskFrame:SetPoint("TOPLEFT",     cD.sCACFrames["CACHEITEMSEXTFRAME"], "TOPLEFT")
      itemsMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["CACHEITEMSEXTFRAME"], "TOPRIGHT",    -(cD.borders.right + itemsSBWIDTH), 0)
      itemsMaskFrame:SetPoint("BOTTOMRIGHT", cD.sCACFrames["CACHEITEMSEXTFRAME"], "BOTTOMRIGHT", -(cD.borders.right + itemsSBWIDTH), 0)
      cD.sCACFrames["CACHEITEMSMASKFRAME"]  = itemsMaskFrame

      -- CACHE ZONE ITEMS CONTAINER FRAME
      local cacheFrame =  UI.CreateFrame("Frame", "Cache_Items_frame", cD.sCACFrames["CACHEITEMSMASKFRAME"])
      cacheFrame:SetAllPoints(cD.sCACFrames["CACHEITEMSMASKFRAME"])
      cacheFrame:SetPoint("TOPLEFT", itemsMaskFrame, "TOPLEFT")
      cacheFrame:SetBackgroundColor(0, 0, 0, .5)   -- GREEN
      cD.sCACFrames["CACHEITEMSFRAME"]  =   cacheFrame


   --[[  ITEM VIEWER ]]-- [[END]]--
   local cfScroll = UI.CreateFrame("RiftScrollbar","item_list_scrollbar", cD.sCACFrames["CACHEITEMSEXTFRAME"])
   cfScroll:SetVisible(true)
   cfScroll:SetEnabled(true)
   cfScroll:SetLayer(1)
   cfScroll:SetWidth(itemsSBWIDTH)
   cfScroll:SetOrientation("vertical")
   cfScroll:SetPoint("TOPLEFT",     cD.sCACFrames["CACHEITEMSEXTFRAME"],"TOPRIGHT")
   cfScroll:SetPoint("BOTTOMLEFT",  cD.sCACFrames["CACHEITEMSFRAME"],   "BOTTOMRIGHT")
   cfScroll:EventAttach(   Event.UI.Scrollbar.Change,
                           function()
                              cD.sCACFrames["CACHEITEMSFRAME"]:SetPoint("TOPLEFT", cD.sCACFrames["CACHEITEMSMASKFRAME"], "TOPLEFT", 0, -math.floor(cfScroll:GetPosition()) )
                           end,
                           "Event.UI.Scrollbar.Change")


   -- Enable Dragging
   Library.LibDraggable.draggify(cacheWindow, cD.updateGuiCoordinates)

   populateZoneList()

   return cacheWindow

end

