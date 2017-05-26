--
-- Addon       _fiu_gui_Info2.lua
-- Author      marcob@marcob.org
-- StartDate   18/05/2017
--

local addon, cD = ...

cD.ttFrames =  {}

local tts   =  {}
tts.titlebar=  "Right Mouse Button + Drag to move"
tts.minimize=  "Hide"
tts.totwin  =  "Show Total's Window"
tts.lootwin =  "Show/Hide session loot details"
tts.reset   =  "Reset Session Totals"
tts.minimap =  "Show/Hide FishItUp!"

local colors=  {	black    =  {  r=0,    g=0,  b=0   },
                  grey1    =  {  r=.1,   g=.1, b=.1  },
                  grey2    =  {  r=.2,   g=.2, b=.2  }
               }

local tWINWIDTH   =  150
local TXTSIZE     =  18


local function _newTT()

   --Global context (parent frame-thing).
   local ttContext = UI.CreateContext("Tooltip_context")
   ttContext:SetStrata("topmost")

   local ttWindow    =  UI.CreateFrame("Frame", "ToolTip", ttContext)
   ttWindow:SetWidth(tWINWIDTH)
   ttWindow:SetLayer(8)
   ttWindow:SetBackgroundColor(colors.black.r, colors.black.g, colors.black.b, .8)
   cD.ttFrames.ttWindow =  ttWindow

   -- TT CONTAINER FRAME
   local ttFrame =  UI.CreateFrame("Frame", "ItemViewer_frame", cD.ttFrames.ttWindow)
   ttFrame:SetLayer(9)
   ttFrame:SetPoint("TOPLEFT",      ttWindow,    "TOPLEFT",       cD.borders.left,     cD.borders.top)
   ttFrame:SetPoint("TOPRIGHT",     ttWindow,    "TOPRIGHT",     -cD.borders.right,    cD.borders.top)
   ttFrame:SetPoint("BOTTOMLEFT",   ttWindow,    "BOTTOMLEFT",    cD.borders.right,   -cD.borders.bottom)
   ttFrame:SetPoint("BOTTOMRIGHT",  ttWindow,    "BOTTOMRIGHT",  -cD.borders.right,   -cD.borders.bottom)
   cD.ttFrames.ttFrame  =	ttFrame

   -- TT Text Field
   local ttText     =  UI.CreateFrame("Text", "TT_text_frame", cD.ttFrames.ttFrame)
   local objColor =  cD.rarityColor("common")
   ttText:SetFont(cD.addon, cD.text.base_font_name)
   ttText:SetFontSize(cD.text.base_font_size -2)
   ttText:SetText("", true)
   ttText:SetLayer(10)
   ttText:SetFontColor(1, 1, 1)
   ttText:SetAllPoints(cD.ttFrames.ttFrame)
   cD.ttFrames.textFrame   =  ttText

   return ttWindow

end

local function showTT(o, tt)

   if o and tt and tts[tt] then

      -- update tooltip
      cD.ttFrames.textFrame:SetText("")
      cD.ttFrames.textFrame:SetText(cD.multiLineString(tts[tt], TXTSIZE), true)

      -- resize tooltip
      cD.window.ttOBJ:SetVisible(true)
      cD.window.ttOBJ:SetHeight((cD.ttFrames.textFrame:GetBottom() - cD.ttFrames.textFrame:GetTop()) + cD.borders.top + cD.borders.bottom)

      -- re-position tooltip
      local mouseData   =   Inspect.Mouse()
      cD.window.ttOBJ:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouseData.x + 10, mouseData.y + 10)
   else
      cD.window.ttOBJ:SetVisible(false)
   end

   return
end

function cD.attachTT(o, tt)

   if o and tt then

      if not cD.window.ttOBJ then cD.window.ttOBJ   =  _newTT() cD.window.ttOBJ:SetVisible(false)  end

      -- Mouse Hover IN    => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.In,   function() showTT(o, tt)      end, "Event.UI.Input.Mouse.Cursor.In_"  .. o:GetName())
      -- Mouse Hover OUT   => show tooltip
      o:EventAttach(Event.UI.Input.Mouse.Cursor.Out,  function() showTT(nil, nil)   end, "Event.UI.Input.Mouse.Cursor.Out_" .. o:GetName())
   end

   return
end
