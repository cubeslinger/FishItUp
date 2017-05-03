--
-- Addon       _fiu_gui_ItemViewer.lua
-- Author      marcob@marcob.org
-- StartDate   23/04/2017
-- StartDate   23/04/2017
--
local addon, cD = ...

-- local tWINWIDTH   =  355
local tWINWIDTH   =  300
local tWINHEIGHT  =  276
-- local TXTSIZE     =  45
local TXTSIZE     =  40
local ivNAMESIZE  =  20

local colors      =  {}
colors.black      =  {  r=0,    g=0,  b=0   }
colors.grey1      =  {  r=.1,   g=.1, b=.1  }
colors.grey2      =  {  r=.2,   g=.2, b=.2  }



function cD.createItemViewerWindow()

   -- ITEMVIEWER 
   --Global context (parent frame-thing).
   local context = UI.CreateContext("ItemViewer_context")

   local ivWindow    =  UI.CreateFrame("Frame", "ItemViewer", context)

   if cD.window.ivX == nil or cD.window.ivY == nil then
      -- first run, we position in the screen center
      ivWindow:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      ivWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.ivX or 0, cD.window.ivY or 0)
   end
   
   ivWindow:SetWidth(tWINWIDTH)
   ivWindow:SetHeight(tWINHEIGHT)
   ivWindow:SetLayer(-1)
   ivWindow:SetBackgroundColor(colors.black.r, colors.black.g, colors.black.b, .5)
   
   -- ITEMVIEWER TITLE BAR CONTAINER
   local titleIvFrame =  UI.CreateFrame("Frame", "External_ItemViewer_Frame", ivWindow)
   titleIvFrame:SetLayer(1)
   titleIvFrame:SetHeight(cD.text.base_font_size + 4)
--    titleIvFrame:SetBackgroundColor(colors.grey1.r, colors.grey1.g, colors.grey1.b, .6)   
   titleIvFrame:SetPoint("TOPLEFT",     ivWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleIvFrame:SetPoint("TOPRIGHT",    ivWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)   
   cD.sIVFrames["TITLEBARIVFRAME"]  =   titleIvFrame

   -- ITEMVIEWER TITLE BAR TITLE
   local titleIv =  UI.CreateFrame("Text", "ItemViewer_Title", titleIvFrame)
   titleIv:SetFontSize(cD.text.base_font_size)
   titleIv:SetText("FIU! Item Viewer")
   titleIv:SetFont(cD.addon, cD.text.base_font_name)
   titleIv:SetLayer(3)
   titleIv:SetPoint("TOPLEFT", cD.sIVFrames["TITLEBARIVFRAME"], "TOPLEFT", cD.borders.left, 0)
   cD.sIVFrames["TITLEBARIVCONTENTFRAME"]  =   titleIV


   -- ITEMVIEWER TITLE BAR Widgets: setup Icon for Iconize
   local titleIvMinIcon = UI.CreateFrame("Texture", "IV_Title_Icon_1", cD.sIVFrames["TITLEBARIVFRAME"])
   titleIvMinIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
   titleIvMinIcon:SetWidth(cD.text.base_font_size)
   titleIvMinIcon:SetHeight(cD.text.base_font_size)
   titleIvMinIcon:SetLayer(3)   
   titleIvMinIcon:SetPoint("TOPRIGHT",   cD.sIVFrames["TITLEBARIVFRAME"], "TOPRIGHT", -cD.borders.right, 0)
   titleIvMinIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.ivOBJ:SetVisible(not cD.window.ivOBJ:GetVisible()) end , "IV Iconize Pressed" )
   titleIvFrame:SetHeight(cD.text.base_font_size + 6)   

   -- ITEMVIEWER EXTERNAL CONTAINER FRAME
   local ivExtFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", ivWindow)   
   ivExtFrame:SetPoint("TOPLEFT",     cD.sIVFrames["TITLEBARIVFRAME"],  "BOTTOMLEFT",  cD.borders.left,   cD.borders.top)
   ivExtFrame:SetPoint("TOPRIGHT",    cD.sIVFrames["TITLEBARIVFRAME"],  "BOTTOMRIGHT", -cD.borders.right, cD.borders.top)
   ivExtFrame:SetPoint("BOTTOMLEFT",  ivWindow,                         "BOTTOMLEFT",  cD.borders.left,   - cD.borders.bottom)
   ivExtFrame:SetPoint("BOTTOMRIGHT", ivWindow,                         "BOTTOMRIGHT", -cD.borders.right, - cD.borders.bottom)
--    ivExtFrame:SetBackgroundColor(colors.grey2.r, colors.grey2.g, colors.grey2.b, .6)
   ivExtFrame:SetLayer(1)
   cD.sIVFrames["EXTERNALIVFRAME"]  =   ivExtFrame

   -- ITEMVIEWER MASK FRAME
   local ivMaskFrame = UI.CreateFrame("Mask", "ItemViewer_Mask_Frame", cD.sIVFrames["EXTERNALIVFRAME"])
   ivMaskFrame:SetAllPoints(cD.sIVFrames["EXTERNALIVFRAME"])
   cD.sIVFrames["IVMASKFRAME"]  = ivMaskFrame

   -- ITEMVIEWER CONTAINER FRAME
   local ivFrame =  UI.CreateFrame("Frame", "ItemViewer_frame", cD.sIVFrames["IVMASKFRAME"])
   ivFrame:SetAllPoints(cD.sIVFrames["IVMASKFRAME"])
   ivFrame:SetLayer(1)
   cD.sIVFrames["IVFRAME"]  =   ivFrame

   
   -- Item's Icon
   local itemIcon = UI.CreateFrame("Texture", "ItemViewer_Item_Icon", cD.sIVFrames["IVFRAME"])
   itemIcon:SetTexture("Rift", "")
--    itemIcon:SetWidth(cD.text.base_font_size+4)
--    itemIcon:SetHeight(cD.text.base_font_size+4)
   itemIcon:SetPoint("TOPLEFT",   cD.sIVFrames["IVFRAME"], "TOPLEFT", cD.borders.left, cD.borders.top)
   itemIcon:SetLayer(3)
   cD.ivOBJ["ITEMICON"] =  itemIcon
   
   -- Item's Name
   local nameOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_Name", cD.sIVFrames["IVFRAME"])
   nameOBJ:SetFont(cD.addon, cD.text.base_font_name)
   nameOBJ:SetFontSize(cD.text.base_font_size)
   nameOBJ:SetHeight(cD.text.base_font_size + 4)
   nameOBJ:SetText("")
   nameOBJ:SetLayer(3)
   nameOBJ:SetPoint("TOPLEFT",   itemIcon,    "TOPRIGHT", cD.borders.left, 0)   
   cD.ivOBJ["ITEMNAME"] =  nameOBJ
   
   -- Item's Counter
   local itemCnt  =  UI.CreateFrame("Text", "ItemViewer_Item_Cnt_", cD.sIVFrames["IVFRAME"])
   local objColor =  cD.rarityColor("quest")
   itemCnt:SetFont(cD.addon, cD.text.base_font_name)
   itemCnt:SetFontSize(cD.text.base_font_size)
   itemCnt:SetFontColor(objColor.r, objColor.g, objColor.b)
   itemCnt:SetText(string.format("%5d", 0), true)
--    itemCnt:SetWidth(itemCnt:GetWidth())
   itemCnt:SetLayer(3)
   itemCnt:SetPoint("TOPRIGHT",   cD.sIVFrames["IVFRAME"], "TOPRIGHT", -cD.borders.left, cD.borders.top)   
   cD.ivOBJ["ITEMCOUNTER"] =  itemCnt   
   
   -- Item's Type Icon  
   local typeIcon = UI.CreateFrame("Texture", "Item_Type_Icon", cD.sIVFrames["IVFRAME"])
   typeIcon:SetWidth(cD.text.base_font_size  + 6)
   typeIcon:SetHeight(cD.text.base_font_size + 6)
   typeIcon:SetPoint("BOTTOMLEFT",   itemIcon, "BOTTOMRIGHT", cD.borders.left, 0)
   typeIcon:SetLayer(3)
   cD.ivOBJ["TYPEICON"] =  typeIcon
   
   -- Item's Type Name
   local typeOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_Type", cD.sIVFrames["IVFRAME"])
   typeOBJ:SetFont(cD.addon, cD.text.base_font_name)
   typeOBJ:SetFontSize(cD.text.base_font_size -2)
   typeOBJ:SetText("", true)
   typeOBJ:SetLayer(3)
   typeOBJ:SetPoint("BOTTOMLEFT",   typeIcon,    "BOTTOMRIGHT", cD.borders.left, 0)   
   cD.ivOBJ["ITEMTYPE"] =  typeOBJ
   
--    -- Item's Value
--    local valueOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_Value", cD.sIVFrames["IVFRAME"])
--    valueOBJ:SetFont(cD.addon, cD.text.base_font_name)
--    valueOBJ:SetFontSize(cD.text.base_font_size)
-- --    valueOBJ:SetHeight(cD.text.base_font_size)
--    valueOBJ:SetText("", true)
--    valueOBJ:SetLayer(3)
--    valueOBJ:SetPoint("BOTTOMLEFT",   typeOBJ,    "BOTTOMRIGHT", cD.borders.left, 0)   
--    cD.ivOBJ["ITEMVALUE"] =  valueOBJ
   
   -- Item's Total Value
   local totValueOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_Value", cD.sIVFrames["IVFRAME"])
   totValueOBJ:SetFont(cD.addon, cD.text.base_font_name)
   totValueOBJ:SetFontSize(cD.text.base_font_size)
--    totValueOBJ:SetHeight(cD.text.base_font_size)
   totValueOBJ:SetText("")
   totValueOBJ:SetLayer(3)
   totValueOBJ:SetPoint("TOPRIGHT",   itemCnt,    "BOTTOMRIGHT", 0, cD.borders.top)   
   cD.ivOBJ["ITEMTOTVALUE"] =  totValueOBJ
   
   
   -- Item's Description
   local descOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_desc", cD.sIVFrames["IVFRAME"])
   local objColor =  cD.rarityColor("common")
   descOBJ:SetFont(cD.addon, cD.text.base_font_name)
   descOBJ:SetFontSize(cD.text.base_font_size -2)
--    descOBJ:SetHeight(cD.text.base_font_size)
   descOBJ:SetText("")
   descOBJ:SetLayer(3)
   descOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   descOBJ:SetPoint("TOPLEFT",   itemIcon,    "BOTTOMLEFT", 0, cD.borders.top)
   descOBJ:SetPoint("RIGHT",     itemCnt,     "RIGHT")
   cD.ivOBJ["ITEMDESC"] =  descOBJ
   
   -- Item's Flavor
   local flavOBJ     =  UI.CreateFrame("Text", "ItemViewer_Item_flav", cD.sIVFrames["IVFRAME"])
   local objColor =  cD.rarityColor("common")
   flavOBJ:SetFont(cD.addon, cD.text.base_font_name)
   flavOBJ:SetFontSize(cD.text.base_font_size -2)
--    flavOBJ:SetHeight(cD.text.base_font_size)
   flavOBJ:SetText("")
   flavOBJ:SetLayer(3)
   flavOBJ:SetFontColor(objColor.r, objColor.g, objColor.b)
   flavOBJ:SetPoint("TOPLEFT",   descOBJ,    "BOTTOMLEFT",  0, cD.borders.top)
   flavOBJ:SetPoint("TOPRIGHT",  descOBJ,    "BOTTOMRIGHT", 0, cD.borders.top)
   cD.ivOBJ["ITEMFLAV"] =  flavOBJ
   
--    print("IV Window Created")
   
   -- Enable Dragging
   Library.LibDraggable.draggify(ivWindow, cD.updateGuiCoordinates)   
   
   return ivWindow
   
end

local function populateItemViewer(zID, t) 
     
   -- cD.ivOBJ["ITEMICON"]
   cD.ivOBJ["ITEMICON"]:SetTexture("Rift", t.icon)
   
   -- cD.ivOBJ["ITEMNAME"]
   local txtColor =  cD.rarityColor(t.rarity)
   cD.ivOBJ["ITEMNAME"]:SetFontColor(txtColor.r, txtColor.g, txtColor.b)
   cD.ivOBJ["ITEMNAME"]:SetHeight(cD.text.base_font_size + 4)
   cD.ivOBJ["ITEMNAME"]:SetText(t.name:sub(1,ivNAMESIZE))
   
   -- cD.ivOBJ["TYPEICON"]
   local categoryIcon  =  cD.categoryIcon(t.category, t.id, t.description, t.name)
   if categoryIcon then
      cD.ivOBJ["TYPEICON"]:SetTexture("Rift", categoryIcon)
      cD.ivOBJ["TYPEICON"]:SetVisible(true)
   else
      cD.ivOBJ["TYPEICON"]:SetVisible(false)
   end
   
   -- cD.ivOBJ["ITEMTYPE"]
   local cat = t.category
   cat = cat:gsub("crafting material ", "")
   cD.ivOBJ["ITEMTYPE"]:SetText("<i>(" .. cat .. ")</i>", true)   
   
--    -- cD.ivOBJ["ITEMVALUE"]
--    cD.ivOBJ["ITEMVALUE"]:SetText(cD.printJunkMoney(t.value), true)
   
--    -- cD.ivOBJ["ITEMTOTVALUE"] 
--    local cnt = cD.getCharScore(zID, t.id)
--    local mfj = t.value * cnt
--    cD.ivOBJ["ITEMTOTVALUE"]:SetText(cD.printJunkMoney(mfj), true)

   -- cD.ivOBJ["ITEMTOTVALUE"] 
   local cnt = cD.getCharScore(zID, t.id)
   local mfj = t.value * cnt
   cD.ivOBJ["ITEMTOTVALUE"]:SetText(cD.printJunkMoney(t.value) .. "/" .. cD.printJunkMoney(mfj), true)
   
   -- cD.ivOBJ["ITEMCOUNTER"]
   local cnt = cD.getCharScore(zID, t.id)
   cD.ivOBJ["ITEMCOUNTER"]:SetText(string.format("%5d", cnt), true)
  
   -- cD.ivOBJ["ITEMDESC"]
   if t.description then
      local objColor =  cD.rarityColor("quest")
      cD.ivOBJ["ITEMDESC"]:SetFontColor(objColor.r, objColor.g, objColor.b)
      cD.ivOBJ["ITEMDESC"]:SetText(cD.multiLineString(t.description, TXTSIZE),true)
   else
      cD.ivOBJ["ITEMDESC"]:SetText("",true)
   end

   -- cD.ivOBJ["ITEMFLAV"]   
   if t.flavor then
      local objColor =  cD.rarityColor("common")
      cD.ivOBJ["ITEMFLAV"]:SetFontColor(objColor.r, objColor.g, objColor.b)
      cD.ivOBJ["ITEMFLAV"]:SetText("<i>" .. cD.multiLineString(t.flavor, TXTSIZE) .. "</i>",true)
   else
      cD.ivOBJ["ITEMFLAV"]:SetText("",true)
   end
   
   return
   
end


function  cD.selectItemtoView(zID, itemID)
   
--    print(string.format("cD.selectItemtoView! [%s] [%s]", zID, itemID))
   
   local parent   =  nil
   local cnt      =  0

   for iobj, t in pairs(cD.itemCache) do
      if iobj == itemID then 
         populateItemViewer(zID, t) 
         break
      end
   end   
   
   if not cD.window.ivOBJ:GetVisible() then cD.window.ivOBJ:SetVisible(true) end
   
   cD.window.ivOBJ:SetHeight((cD.ivOBJ["ITEMFLAV"]:GetBottom() + cD.borders.bottom + cD.borders.bottom) - cD.window.ivOBJ:GetTop() )
   
   return
end

