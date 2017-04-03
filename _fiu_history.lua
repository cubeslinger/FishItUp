--
-- Addon       _fiu_history.lua
-- Version     0.5
-- Author      marcob@marcob.org
-- StartDate   03/03/2017
-- StartDate   10/03/2017
--

local addon, cD = ...

local TITLEBARTOTALSFRAME     =  1
local TOTALSFRAME             =  5

function cD.updateHistory(zoneOBJ, zID, itemOBJ, lootCount, itemRarity, itemValue)

   if itemValue == nil  then itemValue = 0 end

   --
   -- cD.lastZoneLootObjs
   --
   if cD.lastZoneLootObjs[zoneOBJ] ==  nil   then
      cD.lastZoneLootObjs[zoneOBJ]  =  { [itemOBJ] = lootCount }
   else
      if cD.lastZoneLootObjs[zoneOBJ][itemOBJ] ==  nil   then
         cD.lastZoneLootObjs[zoneOBJ][itemOBJ]  =  lootCount
      else
         cD.lastZoneLootObjs[zoneOBJ][itemOBJ]  =  cD.lastZoneLootObjs[zoneOBJ][itemOBJ] + lootCount
      end
   end

   --
   -- cD.zoneTotalCnts
   --
   local rarity   =  itemRarity
   local zoneID   =  zID
   local newZone  =  false
   local idx      =  nil
   local val      =  nil

   if rarity   == nil   then  rarity   =  "common" end
   -- Legend
   -- sellable=1, common=2, uncommon=3, rare=4, epic=5, quest=6, relic=7, MoneyfromJunk=8
   --
   if cD.zoneTotalCnts == nil or cD.zoneTotalCnts[zoneID] == nil then
      --                              1        2        3       4    5      6     7          8
      --                          sellable, common, uncommon, rare, epic, quest, relic, MoneyfromJunk
      cD.zoneTotalCnts[zoneID] = {0, 0, 0, 0, 0, 0, 0, 0 }
      newZone  =  true
   end

   if        rarity == "sellable"   then
                                       cD.zoneTotalCnts[zoneID][1]	=  cD.zoneTotalCnts[zoneID][1]	+  1
                                       idx =  1  -- idx = 1
                                       if cD.zoneTotalCnts[zoneID][8] == nil   then                                      -- idx = 8  junk money, not a real category
                                          cD.zoneTotalCnts[zoneID][8] = itemValue
                                       else
                                          cD.zoneTotalCnts[zoneID][8]	=  cD.zoneTotalCnts[zoneID][8]	+  itemValue
                                       end
      elseif rarity == "common"    then   cD.zoneTotalCnts[zoneID][2]   =  cD.zoneTotalCnts[zoneID][2]   +  1  idx =  2  -- idx = 2
      elseif rarity == "uncommon"  then   cD.zoneTotalCnts[zoneID][3]   =  cD.zoneTotalCnts[zoneID][3]	+  1  idx =  3  -- idx = 3
      elseif rarity == "rare"      then   cD.zoneTotalCnts[zoneID][4]   =  cD.zoneTotalCnts[zoneID][4]   +  1  idx =  4  -- idx = 4
      elseif rarity == "epic"      then   cD.zoneTotalCnts[zoneID][5]   =  cD.zoneTotalCnts[zoneID][5]   +  1  idx =  5  -- idx = 5
      elseif rarity == "quest"     then   cD.zoneTotalCnts[zoneID][6]   =  cD.zoneTotalCnts[zoneID][6]   +  1  idx =  6  -- idx = 6
      elseif rarity == "relic"     then   cD.zoneTotalCnts[zoneID][7]	=  cD.zoneTotalCnts[zoneID][7]	+	1  idx =  7  -- idx = 7
   end

   --
   -- update Totals Window Counters
   --
   if newZone  then
      local parent = cD.sTOFrame[table.getn(cD.sTOFrame)]
      if parent == nil then parent = cD.sTOFrames[TOTALSFRAME] end
      local totalsFrame, znOBJ, totOBJs   = cD.createTotalsLine(cD.sTOFrame[table.getn(cD.sTOFrame)], Inspect.Zone.Detail(zoneOBJ).name, cD.zoneTotalCnts[zoneID])

      table.insert(cD.sTOzoneIDs,   zoneID)
      table.insert(cD.sTOFrame,     totalsFrame)
      table.insert(cD.sTOznObjs,    znOBJ)
      cD.sTOcntObjs[zoneID] = totOBJs

      cD.window.totalsObj:SetHeight((cD.sTOznObjs[table.getn(cD.sTOznObjs)]:GetBottom() - cD.sTOFrames[TITLEBARTOTALSFRAME]:GetTop()) + cD.borders.top + cD.borders.bottom)
   else
      local cnt = string.format("%3d", cD.zoneTotalCnts[zoneID][idx])
      cD.sTOcntObjs[zoneID][idx]:SetText(cnt)
   end


   -- adjust MfJ (Money from Junk) counter
   local j = cD.zoneTotalCnts[zoneID][8] or 0
   cD.sTOcntObjs[zoneID][#cD.sTOcntObjs[zoneID] - 1]:SetText(string.format("%5s", cD.printJunkMoney(j)), true)

   -- adjust Whole Zone Total
   local total =  0
   local i     =  nil
   for i=1, 7 do total = total + cD.zoneTotalCnts[zoneID][i] end
--    print(string.format("Total [%s]", total))
   cD.sTOcntObjs[zoneID][#cD.sTOcntObjs[zoneID]]:SetText(string.format("%5d", total))




   newZone  =  false

   return
end
