--
-- Addon       _fiu_gui_Cache.lua
-- Version     0.1
-- Author      marcob@marcob.org
-- StartDate   04/04/2017
-- StartDate   04/04/2017
--

local addon, cD = ...

local tWINWIDTH               =  350
local tWINHEIGTH              =  200
local znListWIDTH             =  150

local function resetZoneItems()
   print("resetZoneItems: STILL DO TO")
   
   return
end

local function createZoneItemLine(znID, zoneName)
   
   print("Cliked!")
   
   local iobj, zil, t = nil, nil, {}
   
   for iobj, t in pairs(cD.itemCache) do
      
      if t.zone   == znID  then
         
         for x, y in pairs(t) do
            print(string.format("x[%s] y[%s]", x, y))
         end         
         
         print("GotZone!")

         zil =  UI.CreateFrame("Frame", "Zone_item_Frame", cD.sCACFrames["CACHEITEMSFRAME"])
            
         zil:SetLayer(1)
         zil:SetPoint("TOPLEFT",  cD.sCACFrames["CACHEITEMSFRAME"], "TOPLEFT",  0, 1)
         zil:SetPoint("TOPRIGHT", cD.sCACFrames["CACHEITEMSFRAME"], "TOPRIGHT", 0, 1)

         -- setup Loot Item's Icon
         zilIcon =  UI.CreateFrame("Texture", "Item_Icon_" .. t.name, zil)
         zilIcon:SetTexture("Rift", t.icon)
         zilIcon:SetPoint("TOPLEFT",      zil, "TOPLEFT",      cD.borders.left, 0)
         zilIcon:SetPoint("BOTTOMLEFT",   zil, "BOTTOMLEFT",   cD.borders.left, 0)
         zilIcon:SetLayer(3)
         
         zil:SetWidth(zilIcon:GetWidth())
         zil:SetHeight(zilIcon:GetHeight())
      end
   end
   
   return zil

end


-- local function populateSelectedZone(znID, znName)
-- 
--    resetZoneItems()
-- 
--    local iobj, t  =  nil, {}
--    local first    =  true
--    local parent   =  cD.sCACFrames["CACHEITEMSFRAME"] 
-- 
--    for iobj, t in pairs(cD.itemCache) do
--       if t.zone   == znID  then
--          print("Creating itemLine for ["..t.zone.."]")
-- --          local znItemLine  =  createZoneItemLine(t)
--             
--          local znLineFrame =  UI.CreateFrame("Frame", "Zone_Line_Frame", parent)
--          znLineFrame:SetLayer(2)
--          znLineFrame:SetBackgroundColor(1, 0, 0, .5)
-- --          if parent == nil then
--          if first then             
--             first    =  false
--             znLineFrame:SetPoint("TOPLEFT",  parent, "TOPLEFT",  1,  1)
--             znLineFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -1, 1)
--          else
--             znLineFrame:SetPoint("TOPLEFT",  parent, "BOTTOMLEFT",  1, 1)
--             znLineFrame:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", -1, 1)
--          end            
--          
--          local znLine =  UI.CreateFrame("Text", "Zone_Line", znLineFrame)
--          znLine:SetAllPoints(znLineFrame)
--          znLine:SetLayer(3)
--          znLine:SetFont(cD.addon, cD.text.base_font_name)
--          znLine:SetFontSize(cD.text.base_font_size)
--          znLine:SetText(znName)
--          local txtColor =  cD.rarityColor("common")
--          znLine:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
--          znLine:SetBackgroundColor(0, 1, 0, .5)
-- 
--          znLineFrame:SetHeight(znLine:GetHeight() + 4)
--       end
--    end
-- 
-- end

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
--    znLine:EventAttach(Event.UI.Input.Mouse.Left.Click, function() populateSelectedZone(znID, zoneName) end, "Zone Selected" )
   znLine:EventAttach(Event.UI.Input.Mouse.Left.Click, function() createZoneItemLine(znID, zoneName) end, "Zone Selected" )
   
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

   for iobj, t in pairs(cD.itemCache) do
      zones[t.zone] =  Inspect.Zone.Detail(t.zone).name
      print("zn load ["..t.zone.."]["..zones[t.zone].."]")
      parent   =  createZoneLine(parent, t.zone, zones[t.zone])
      for x, y in pairs(parent) do
         print(string.format("x[%s] y[%s]", x, y))
         for a,b in pairs(y) do 
            print(string.format("a[%s] b[%s]", a, b))
         end
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
      -- CACHE ZONE ITEMS MASK FRAME
      local itemsMaskFrame = UI.CreateFrame("Mask", "Cache_Items_Mask_Frame", cacheWindow)
      itemsMaskFrame:SetPoint("TOPLEFT",     cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMLEFT",     cD.borders.left + znListWIDTH + 1,    1)
      itemsMaskFrame:SetPoint("TOPRIGHT",    cD.sCACFrames["TITLEBARCACHEFRAME"], "BOTTOMRIGHT",    -cD.borders.right, 1)
      itemsMaskFrame:SetPoint("BOTTOMRIGHT", cacheWindow, "BOTTOMRIGHT", -cD.borders.right, -cD.borders.bottom)
      cD.sCACFrames["CACHEITEMSMASKFRAME"]  = itemsMaskFrame

      -- CACHE ZONE ITEMS CONTAINER FRAME
      local cacheFrame =  UI.CreateFrame("Frame", "Cache_Items_frame", cD.sCACFrames["CACHEITEMSMASKFRAME"])
      cacheFrame:SetAllPoints(cD.sCACFrames["CACHEITEMSMASKFRAME"])
      cacheFrame:SetLayer(1)
      cacheFrame:SetBackgroundColor(0, 0, 0, .5)   -- GREEN
      cD.sCACFrames["CACHEITEMSFRAME"]  =   cacheFrame
   --[[  ITEM VIEWER ]]-- [[END]]--

   -- Enable Dragging
   Library.LibDraggable.draggify(cacheWindow, cD.updateGuiCoordinates)

   populateZoneList()

   return cacheWindow

end

