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

-- local cD.text.base_font_size               =  11
local tWINWIDTH               =  504
local tMAXSTRINGSIZE          =  30
local tMAXLABELSIZE           =  200

local function reverseTable(t)
   local reversedTable = {}
   local itemCount = #t
   for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
   end
   return reversedTable
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
   totalsWindow:SetLayer(-1)
   totalsWindow:SetBackgroundColor(0, 0, 0, .5)

   -- TITLE BAR CONTAINER
   local titleTotalsFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
   titleTotalsFrame:SetPoint("TOPLEFT",     totalsWindow, "TOPLEFT",     cD.borders.left,    cD.borders.top)
   titleTotalsFrame:SetPoint("TOPRIGHT",    totalsWindow, "TOPRIGHT",    - cD.borders.right, cD.borders.top)
   titleTotalsFrame:SetBackgroundColor(.1, .1, .1, .7)
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
   local externaTotalsFrame =  UI.CreateFrame("Frame", "External_Totals_Frame", totalsWindow)
--    externaTotalsFrame:SetPoint("TOPLEFT",     cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMLEFT",  cD.borders.left,    cD.borders.top)
--    externaTotalsFrame:SetPoint("TOPRIGHT",    cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMRIGHT", - cD.borders.right, cD.borders.top)
   externaTotalsFrame:SetPoint("TOPLEFT",     cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMLEFT",  cD.borders.left,    1)
   externaTotalsFrame:SetPoint("TOPRIGHT",    cD.sTOFrames[TITLEBARTOTALSFRAME], "BOTTOMRIGHT", - cD.borders.right, 1)

   externaTotalsFrame:SetPoint("BOTTOMLEFT",  totalsWindow,                      "BOTTOMLEFT",  cD.borders.left,    - cD.borders.bottom)
   externaTotalsFrame:SetPoint("BOTTOMRIGHT", totalsWindow,                      "BOTTOMRIGHT", - cD.borders.right, - cD.borders.bottom)
   externaTotalsFrame:SetBackgroundColor(.2, .2, .2, .5)
   externaTotalsFrame:SetLayer(1)
   cD.sTOFrames[EXTERNALTOTALSFRAME]  =   externaTotalsFrame

      -- MASK FRAME
      local maskFrame = UI.CreateFrame("Mask", "Totals_Mask_Frame", cD.sTOFrames[EXTERNALTOTALSFRAME])
      maskFrame:SetAllPoints(cD.sTOFrames[EXTERNALTOTALSFRAME])
      cD.sTOFrames[TOTALSMASKFRAME]  = maskFrame

      -- TOTALS CONTAINER FRAME
      local totalsFrame =  UI.CreateFrame("Frame", "loot_frame", cD.sTOFrames[TOTALSMASKFRAME])
      totalsFrame:SetAllPoints(cD.sTOFrames[TOTALSMASKFRAME])
      totalsFrame:SetLayer(1)
      cD.sTOFrames[TOTALSFRAME]  =   totalsFrame

   -- Enable Dragging
   Library.LibDraggable.draggify(totalsWindow, cD.updateGuiCoordinates)

   return totalsWindow

end


function cD.createTotalsLine(parent, zoneName, zoneTotals, isLegend)

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
   znOBJ     =  UI.CreateFrame("Text", "Totals_" ..zoneName, totalsFrame)
   local zn = string.sub(zoneName, 1, tMAXSTRINGSIZE)
   znOBJ:SetWidth(150)
   znOBJ:SetLayer(3)
   znOBJ:SetFontSize(cD.text.base_font_size)
   znOBJ:SetFont(cD.addon, cD.text.base_font_name)
   znOBJ:SetText(zn)
   znOBJ:SetPoint("TOPLEFT",   totalsFrame, "TOPLEFT", cD.borders.left, 2)

   local parentOBJ   =  znOBJ
   local total       =  0
--    for idx, _ in pairs(zoneTotals) do
   for idx=1, 7 do
      -- setup Totals Item's Counter
      local totalsCnt  =  UI.CreateFrame("Text", "Totals_Cnt_" .. idx, totalsFrame)
      totalsCnt:SetFont(cD.addon, cD.text.base_font_name)
      totalsCnt:SetFontSize(cD.text.base_font_size)
      totalsCnt:SetLayer(3)

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
   mfjTotal:SetLayer(3)
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
   totalsTotal:SetLayer(3)
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
   local legendFrame, legendZnOBJ, legendTotOBJs = cD.createTotalsLine(parentOBJ, legendZnName, legendTbl, true)

   table.insert(cD.sTOzoneIDs,   legendZnName)
   table.insert(cD.sTOFrame,     legendFrame)
   table.insert(cD.sTOznOBJs,    legendZnOBJ)

   cD.sTOcntOBJs[legendZnName] = legendTotOBJs
   parentOBJ   =  legendFrame
   -- Inject Legend into Table 1st row - end


   for zn, tbl in pairs(cD.zoneTotalCnts) do

      local znName   =  Inspect.Zone.Detail(zn).name
      local znID     =  Inspect.Zone.Detail(zn).id
      local totalsFrame, znOBJ, totOBJs = cD.createTotalsLine(parentOBJ, znName, tbl)

      table.insert(cD.sTOzoneIDs,   zn)
      table.insert(cD.sTOFrame,     totalsFrame)
      table.insert(cD.sTOznOBJs,    znOBJ)
      cD.sTOcntOBJs[znID] = totOBJs

      parentOBJ   =  totalsFrame
   end

   local H = cD.sTOFrames[TITLEBARTOTALSFRAME]:GetBottom() + cD.borders.bottom
   if cD.sTOznOBJs ~= nil and next(cD.sTOznOBJs) then H = cD.sTOznOBJs[table.getn(cD.sTOznOBJs)]:GetBottom() end
   cD.window.totalsOBJ:SetHeight((H - cD.sTOFrames[TITLEBARTOTALSFRAME]:GetTop()) + cD.borders.top + cD.borders.bottom)

   return
end
