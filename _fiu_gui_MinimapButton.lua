--
-- Addon       _fiu_gui_TotAndcache.lua
-- Author      marcob@marcob.org
-- StartDate   10/05/2017
--

local addon, cD = ...

function cD.createMiniMapButton()

   --Global context (parent frame-thing).
         mmBtnContext = UI.CreateContext("button_context")

   -- MiniMapButton Icon
   mmButton = UI.CreateFrame("Texture", "mmBtnIcon", mmBtnContext)
   mmButton:SetTexture("Rift", "Fish_icon.png.dds")
   mmButton:SetLayer(1)
   --    mmButton:SetWidth(16)
   --    mmButton:SetHeight(16)

   --    resetButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.resetInfoWindow() cD.resetLootWindow(true) end, "Reset Button Pressed" )
   mmButton:EventAttach( Event.UI.Input.Mouse.Left.Click, function() cD.doThings(params) end, "Reset Button Pressed" )

   if cD.window.mmBtnX == nil or cD.window.mmBtnY == nil then
      -- first run, we position in the screen center
      mmButton:SetPoint("CENTER", UIParent, "CENTER")
   else
      -- we have coordinates
      mmButton:SetPoint("TOPLEFT", UIParent, "TOPLEFT", cD.window.mmBtnX, cD.window.mmBtnY)
   end

   -- Enable Dragging
   Library.LibDraggable.draggify(mmButton, cD.updateGuiCoordinates)

   cD.window.mmBtnOBJ   =  mmButton

   return mmButton
end
