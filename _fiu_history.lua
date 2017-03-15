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

local function split(text, delim)
   -- returns an array of fields based on text and delimiter (one character only)
   local result = {}
   local magic = "().%+-*?[]^$"

   if delim == nil then
      delim = "%s"
   elseif string.find(delim, magic, 1, true) then
      -- escape magic
      delim = "%"..delim
   end

   local pattern = "[^"..delim.."]+"
   for w in string.gmatch(text, pattern) do
      table.insert(result, w)
   end
   return result
end

local function getToday()
   local adate = os.date()
   local dateFields = split(adate, " ")
   local aToday = split(dateFields[1], "/")

   return(string.format("20%02d%02d%02d", aToday[3], aToday[2], aToday[1]))
end

function cD.addToTodayHistory(zoneOBJ, lootArray, lootCnts)
   local today =  getToday()
--    print(string.format("Today [%s] zoneOBJ [%s] lootArraySize [%s]", today, zoneOBJ, #lootArray))

   if cD.history[today] then
      table.insert(cD.history[today], { [zoneOBJ] = { lootArray, lootCnts } })
   else
      cD.history[today] =  { [zoneOBJ] = { lootArray, lootCnts } }
   end

   return
end


function cD.updateHistory(zoneOBJ, itemOBJ, lootCount)
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
   local rarity   =  Inspect.Item.Detail(itemOBJ).rarity
   local zoneID   =  Inspect.Zone.Detail(zoneOBJ).id
   local newZone  =  false
   local idx      =  nil
   local val      =  nil

   if rarity   == nil   then  rarity   =  "common" end
   -- Legend
   -- sellable=1, common=2, uncommon=3, rare=4, epic=5, quest=6, relic=7
   --
   if cD.zoneTotalCnts == nil or cD.zoneTotalCnts[zoneID] == nil then
      --                              1        2        3       4    5      6     7
      --                          sellable, common, uncommon, rare, epic, quest, relic
      cD.zoneTotalCnts[zoneID] = {0, 0, 0, 0, 0, 0, 0 }
      newZone  =  true
   end

   if        rarity == "sellable"  then   cD.zoneTotalCnts[zoneID][1]	=  cD.zoneTotalCnts[zoneID][1]	+  1  idx =  1  -- idx = 1
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
--       print(string.format("0 - parent is [%s]", parent))
      if parent == nil then parent = cD.sTOFrames[TOTALSFRAME] end
--       print(string.format("1 - parent is [%s]", parent))
      local totalsFrame, znOBJ, totOBJs= cD.createTotalsLine(cD.sTOFrame[table.getn(cD.sTOFrame)], Inspect.Zone.Detail(zoneOBJ).name, cD.zoneTotalCnts[zoneID])

      table.insert(cD.sTOzoneIDs,   zoneID)
      table.insert(cD.sTOFrame,     totalsFrame)
      table.insert(cD.sTOznObjs,    znOBJ)
      cD.sTOcntObjs[zoneID] = totOBJs

      cD.window.totalsObj:SetHeight((cD.sTOznObjs[table.getn(cD.sTOznObjs)]:GetBottom() - cD.sTOFrames[TITLEBARTOTALSFRAME]:GetTop()) + cD.borders.top + cD.borders.bottom)
   else
      local cnt = string.format("%3d", cD.zoneTotalCnts[zoneID][idx])
      cD.sTOcntObjs[zoneID][idx]:SetText(cnt)
   end

   newZone  =  false

   return
end
