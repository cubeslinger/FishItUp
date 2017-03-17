--
-- Addon       _fiu_gui_Totals.lua
-- Version     0.3
-- Author      marcob@marcob.org
-- StartDate   08/03/2017
-- StartDate   09/03/2017
--

local addon, cD = ...

local TITLEBARTOTALSFRAME     =  1
local TITLEBARTCONTENTFRAME   =  2
local EXTERNALTOTALSFRAME     =  3
local TOTALSMASKFRAME         =  4
local TOTALSFRAME             =  5

local tFONTSIZE               =  11
local tWINWIDTH               =  405
local tMAXSTRINGSIZE          =  30
local tMAXLABELSIZE           =  200

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

--    totalsWindow:SetWidth(cD.window.width)
   totalsWindow:SetWidth(tWINWIDTH)
   totalsWindow:SetLayer(-1)
   totalsWindow:SetBackgroundColor(0, 0, 0, .5)

   -- TITLE BAR CONTAINER
   local titleTotalsFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   titleTotalsFrame:SetPoint("TOPLEFT",     totalsWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleTotalsFrame:SetPoint("TOPRIGHT",    totalsWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleTotalsFrame:SetBackgroundColor(.1, .1, .1, .7)
   titleTotalsFrame:SetLayer(1)
   titleTotalsFrame:SetHeight(tFONTSIZE + 4)
   cD.sTOFrames[TITLEBARTOTALSFRAME]  =   titleTotalsFrame

      -- TITLE BAR TITLE
      local titleFIU =  UI.CreateFrame("Text", "FIU_Title", titleTotalsFrame)
      titleFIU:SetFontSize(tFONTSIZE)
      titleFIU:SetText("FIU! Lifetime Totals")
      titleFIU:SetFont(cD.addon, "fonts/unispace.ttf")
      titleFIU:SetLayer(3)
      titleFIU:SetPoint("TOPLEFT", cD.sTOFrames[TITLEBARTOTALSFRAME], "TOPLEFT", cD.borders.left, 1)
      cD.sTOFrames[TITLEBARTCONTENTFRAME]  =   titleFIU

      -- TITLE BAR Widgets: setup Icon Frame
      titleIcon1  =  UI.CreateFrame("Texture", "Title_Icon_1_Frame", cD.sTOFrames[TITLEBARTOTALSFRAME])
      titleIcon1:SetWidth(tFONTSIZE)
      titleIcon1:SetHeight(tFONTSIZE)
      titleIcon1:SetLayer(2)
      titleIcon1:SetBackgroundColor(0, 0, 0, .5)
      titleIcon1:SetPoint("TOPRIGHT",   cD.sTOFrames[TITLEBARTOTALSFRAME], "TOPRIGHT", -cD.borders.right, 0)

      -- TITLE BAR Widgets: setup Icon
      lootIcon = UI.CreateFrame("Texture", "Title_Icon_1", titleIcon1)
      lootIcon:SetTexture("Rift", "arrow_dropdown.png.dds")
      lootIcon:SetWidth(tFONTSIZE)
      lootIcon:SetHeight(tFONTSIZE)
      lootIcon:SetPoint("CENTER",    titleIcon1, "CENTER")
      lootIcon:SetLayer(3)
      lootIcon:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.window.totalsObj:SetVisible(not cD.window.totalsObj:GetVisible()) end , "Iconize Totals Pressed" )

--    titleTotalsFrame:SetHeight(tFONTSIZE)

   -- EXTERNAL TOTALS CONTAINER FRAME
   local externaTotalsFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   externaTotalsFrame:SetPoint("TOPLEFT",     cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMLEFT",  cD.borders.left,    cD.borders.top)
   externaTotalsFrame:SetPoint("TOPRIGHT",    cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMRIGHT", - cD.borders.right, cD.borders.top)
   externaTotalsFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                      "BOTTOMLEFT",  cD.borders.left,    - cD.borders.bottom)
   externaTotalsFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                      "BOTTOMRIGHT", - cD.borders.right, - cD.borders.bottom)
   externaTotalsFrame:SetBackgroundColor(.2, .2, .2, .5)
   externaTotalsFrame:SetLayer(1)
   cD.sTOFrames[EXTERNALTOTALSFRAME]  =   externaTotalsFrame

      -- MASK FRAME
      local maskFrame = UI.CreateFrame("Mask", "Totals_Mask_Frame", cD.sTOFrames[EXTERNALTOTALSFRAME])
      maskFrame:SetAllPoints(cD.sTOFrames[EXTERNALTOTALSFRAME])
      cD.sTOFrames[TOTALSMASKFRAME]  = maskFrame
      --    maskFrame:SetBackgroundColor(1, 0, 0, .3)

      -- TOTALS CONTAINER FRAME
      local totalsFrame =  UI.CreateFrame("Frame", "loot_frame", cD.sTOFrames[TOTALSMASKFRAME])
      totalsFrame:SetAllPoints(cD.sTOFrames[TOTALSMASKFRAME])
      totalsFrame:SetLayer(1)
      cD.sTOFrames[TOTALSFRAME]  =   totalsFrame

   -- Enable Dragging
   Library.LibDraggable.draggify(totalsWindow, cD.updateGuiCoordinates)

   return totalsWindow

end


function cD.createTotalsLine(parent, zoneName, zoneTotals)

   if parent == nil then parent = cD.sTOFrames[TOTALSFRAME] end

   local totalsFrame =  nil
   local znOBJ       =  nil
   local idx         =  nil
   local parentOBJ   =  nil
   local totOBJs  =  {}


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
   znOBJ     =  UI.CreateFrame("Text", "Totals_" ..zoneName, totalsFrame)
   local zn = string.sub(zoneName, 1, tMAXSTRINGSIZE)
   znOBJ:SetWidth(150)
   znOBJ:SetLayer(3)
   znOBJ:SetFontSize(tFONTSIZE)
   znOBJ:SetFont(cD.addon, "fonts/unispace.ttf")
   znOBJ:SetText(zn)
   znOBJ:SetPoint("TOPLEFT",   totalsFrame, "TOPLEFT", cD.borders.left, 2)

   local parentOBJ   =  znOBJ

   for idx, _ in pairs(zoneTotals) do
      -- setup Totals Item's Counter
      local totalsCnt  =  UI.CreateFrame("Text", "Totals_Cnt_" .. idx, totalsFrame)
      totalsCnt:SetFont(cD.addon, "fonts/unispace.ttf")
      totalsCnt:SetFontSize(tFONTSIZE)

      totalsCnt:SetText(string.format("%3d", zoneTotals[idx]))
      totalsCnt:SetLayer(3)
      totalsCnt:SetFontColor(txtColors[idx].r, txtColors[idx].g, txtColors[idx].b)
      totalsCnt:SetPoint("TOPLEFT",   parentOBJ, "TOPRIGHT", cD.borders.left, 0)
      parentOBJ   =  totalsCnt
      table.insert(totOBJs, totalsCnt)
   end

   totalsFrame:SetHeight(znOBJ:GetHeight() + 1)

   return totalsFrame, znOBJ, totOBJs
end

function cD.initTotalsWindow()

   local zn, tbl     =  nil, {}
   local parentOBJ   =  cD.sTOFrames[TOTALSFRAME]

   for zn, tbl in pairs(cD.zoneTotalCnts) do

      local znName   =  Inspect.Zone.Detail(zn).name
      local znID     =  Inspect.Zone.Detail(zn).id
      local totalsFrame, znOBJ, totOBJs = cD.createTotalsLine(parentOBJ, znName, tbl)

      table.insert(cD.sTOzoneIDs,   zn)
      table.insert(cD.sTOFrame,     totalsFrame)
      table.insert(cD.sTOznObjs,    znOBJ)
      cD.sTOcntObjs[znID] = totOBJs

      parentOBJ   =  totalsFrame
   end

   local H = cD.sTOFrames[TITLEBARTOTALSFRAME]:GetBottom() + cD.borders.bottom
   if cD.sTOznObjs ~= nil and next(cD.sTOznObjs) then H = cD.sTOznObjs[table.getn(cD.sTOznObjs)]:GetBottom() end
   cD.window.totalsObj:SetHeight((H - cD.sTOFrames[TITLEBARTOTALSFRAME]:GetTop()) + cD.borders.top + cD.borders.bottom)

   return
end
