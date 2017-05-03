--
-- Addon       _fiu_inventory.lua
-- Author      marcob@marcob.org
-- StartDate   02/05/2017
--

-- From: ImhoBags -> Dispatcher.lua
--
-- local function mergetables(l, r)
--    for k, v in pairs(r) do l[k] = v end
--    return l
-- end

-- local list = {
--    all         = function() Inspect.Item.List() end,
--    bank        = function() return mergetables(Inspect.Item.List(Utility.Item.Slot.Bank()), Inspect.Item.List(Utility.Item.Slot.Vault())) end,
--    equipment   = function() return Inspect.Item.List(Utility.Item.Slot.Equipment()) end,
--    guild       = function() return Inspect.Item.List(Utility.Item.Slot.Guild()) end,
--  * inventory   = function() return Inspect.Item.List(Utility.Item.Slot.Inventory()) end,
--  * quest       = function() return Inspect.Item.List(Utility.Item.Slot.Quest()) end,
--    wardrobe    = function() return Inspect.Item.List(Utility.Item.Slot.Wardrobe()) end,
-- }
local addon, cD = ...

function cD.scanInventories()

   local itemBase =  {}

   -- scan Inventory Bags
   local invBags  =  Inspect.Item.List(Utility.Item.Slot.Inventory())
   for slotId, itemId in pairs(invBags) do
      if itemId then
--          print(string.format("++x[%s] y[%s]", slotId, itemId))
         local item  = Inspect.Item.Detail(itemId)
         itemName    = item.name
         itemStack	= item.stack
--          print(string.format("  slotId[%s] itemName[%s] itemStack[%s]", slotId, itemName, itemStack))

         if itemBase[itemName] then
            itemBase[itemName]   =  itemBase[itemName] + item.stack
         else
            itemBase[itemName]   =  item.stack
         end
      end
   end

--    print("-===============================================================-")

   -- scan Questlog Bag
   local invBags  =  Inspect.Item.List(Utility.Item.Slot.Quest())
   for slotId, itemId in pairs(invBags) do
      if itemId then
--          print(string.format("++x[%s] y[%s]", slotId, itemId))
         local item  = Inspect.Item.Detail(itemId)
         itemName    = item.name
         itemStack	= item.stack
--          print(string.format("  slotId[%s] itemName[%s] itemStack[%s]", slotId, itemName, itemStack))

         if itemBase[itemName] then
            itemBase[itemName]   =  itemBase[itemName] + item.stack
         else
            itemBase[itemName]   =  item.stack
         end
      end
   end


   return itemBase
end
