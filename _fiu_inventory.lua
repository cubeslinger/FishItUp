--
-- Addon       _fiu_inventory.lua
-- Author      marcob@marcob.org
-- StartDate   02/05/2017
--

local addon, cD = ...

function cD.scanInventories()

   local itemBase =  {}

   -- scan Inventory Bags
   local invBags  =  Inspect.Item.List(Utility.Item.Slot.Inventory())
   for slotId, itemId in pairs(invBags) do
      if itemId then
         local item  = Inspect.Item.Detail(itemId)
         itemName    = item.name
         itemStack	= item.stack

         if itemBase[itemName] then
            itemBase[itemName]   =  itemBase[itemName] + (item.stack or 1)
         else
            itemBase[itemName]   =  (item.stack or 1)
         end
      end
   end

   -- scan Questlog Bag
   local invBags  =  Inspect.Item.List(Utility.Item.Slot.Quest())
   for slotId, itemId in pairs(invBags) do
      if itemId then
         local item  = Inspect.Item.Detail(itemId)
         itemName    = item.name
         itemStack	= item.stack

         if itemBase[itemName] then
            itemBase[itemName]   =  itemBase[itemName] + (item.stack or 1)
         else
            itemBase[itemName]   =  (item.stack or 1)
         end
      end
   end


   return itemBase
end
