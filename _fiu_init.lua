--
-- Addon       _fiu_init.lua
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
--

local addon, cD = ...

function cD.getItemNumericRarity(r)
   local rarity   =  {}
   if r == nil then r = "common" end

   rarity["sellable"]   =  1
   rarity["common"]     =  2
   rarity["uncommon"]   =  3
   rarity["rare"]       =  4
   rarity["epic"]       =  5
   rarity["quest"]      =  6
   rarity["relic"]      =  7

   return rarity[r]
end

cD.window   =  {  width    =  300,  height   =  60,
                  infoOBJ  =  nil,  infoX    =  nil,  infoY    =  nil,  -- Info Window & objs
                  buttonOBJ=  nil,  buttonX  =  nil,  buttonY  =  nil,  -- FishingPole Window & objs
                  lootOBJ  =  nil,  lootX    =  nil,  lootY    =  nil,  -- Loot Window & objs
                  totalsOBJ=  nil,  totalsX  =  nil,  totalsY  =  nil,  -- Totals Window & objs
                  cacheOBJ =  nil,  cacheX   =  nil,  cacheY   =  nil,  -- Cache Window & objs
                  ivOBJ    =  nil,  ivX      =  nil,  ivY      =  nil,  -- ItemViewer Window & objs
                  mmBtnOBJ =  nil,  mmBtnX   =  nil,  mmBtnY   =  nil,  -- MiniMapButton
                  ttOBJ    =  nil,  ttX      =  nil,  ttY      =  nil,  -- Generic ToolTip Window & objs

               }
-- loot Tables
cD.sLTids      =  {}
cD.sLTnames    =  {}
cD.sLTcnts     =  {}
cD.sLTprcnts   =  {}
cD.sLThdrs     =  {}
cD.sLTFrames   =  {}
cD.sLTtextOBJs =  {}
cD.sLTcntsOBJs =  {}
cD.sLTfullOBJs =  {}
cD.sLTprcntOBJs=  {}
cD.sLTrarity   =  {}
-- totals Tables
cD.sTOzoneIDs  =  {}
cD.sTOFrame    =  {}
cD.sTOznOBJs   =  {}
cD.sTOcntOBJs  =  {}

-- pole Table
cD.poleTBL     =  {}

-- pole Timer
cD.poleTimer   =  nil

-- ItemViewer Tables
cD.sIVFrames   =  {}
cD.ivOBJ       =  {}

-- GUI
cD.borders     =  {  left=4, top=4, right=4, bottom=4 }
-- cD.text        =  {  base_font_size=12,
cD.text        =  {  base_font_size=14,
-- cD.text        =  {  base_font_size=16,
                     base_font_name="fonts/MonospaceTypewriter.ttf"
                  }
cD.sizes          =  {}
cD.sizes.info     =  {}
cD.sizes.info[12] =  { iconsize=26, winwidth=257 }
cD.sizes.info[14] =  { iconsize=32, winwidth=300 }
cD.sizes.info[16] =  { iconsize=36, winwidth=342 }
cD.sizes.loot     =  {}
cD.sizes.loot[12] =  {  lootnamesize=172  }
cD.sizes.loot[14] =  {  lootnamesize=172  }
cD.sizes.loot[16] =  {  lootnamesize=196  }
cD.sizes.toca     =  {}
cD.sizes.toca[12] =  { winwidth=464, winheight=236, maxstringsize=26, znlistwidth=136, sbwidth=7, lootnamesize=148, visibleitems=7, ivnamesize=17 }
cD.sizes.toca[14] =  { winwidth=540, winheight=276, maxstringsize=30, znlistwidth=158, sbwidth=8, lootnamesize=172, visibleitems=9, ivnamesize=20 }
cD.sizes.toca[16] =  { winwidth=618, winheight=316, maxstringsize=34, znlistwidth=180, sbwidth=9, lootnamesize=196, visibleitems=10, ivnamesize=23 }
--
local white =  "#FFFFFF"
local blue  =  "#00AAFF"
local yellow=  "#FFFF00"
local cyan  =  "#00FFFF"
--
cD.fiuTITLE    =  "<font color=\'"..blue.."\'>Fish</font><font color=\'"..cyan.."\'>It</font><font color=\'"..white.."\'>Up</font><font color=\'"..yellow.."\'>!</font>"
cD.timeStart   =  nil
cD.time2Wait   =  .5             -- wait .2 more second
cD.waitingForTheSunRunning =  false
cD.timeRStart  =  0
cD.history     =  {}
cD.today       =  {  casts=0, }
cD.time        =  {  hour=0, mins=0, secs=0 }
cD.infoOBJ     =  nil
cD.buttonOBJ   =  nil
cD.addon       =  addon.toc.Identifier

-- Junk
cD.junkOBJ     =  nil
cD.totJunkMoney=  0
cD.Stock       =  {}
cD.itemCache   =  {}
cD.eventBuffer =  {}

--
-- Logs affected by the RESET button
--
cD.lastZoneLootOBJs  =  {}    -- array of objs ID of last looted items indexed by ZoneID: [zoneID] = {objID_1, objID_2, ...}
--
-- Logs that are permanent
--
cD.zoneTotalCnts     =  {}
cD.charScore         =  {}
cD.charScorebyName   =  {}


function cD.fiuLoadVariables(_, addonName)
   if addon.name == addonName then
--       cD = _init()

      if guilog then
         cD.window            =  guilog
         cD.window.infoOBJ    =  nil
         cD.window.buttonOBJ  =  nil
         cD.window.totalsOBJ  =  nil
         cD.window.cacheOBJ   =  nil
         cD.window.ivOBJ      =  nil
         cD.window.mmBtnOBJ   =  nil
         cD.window.ttOBJ      =  nil
      end

      if lastZoneLootOBJs ~= nil and next(lastZoneLootOBJs) ~= nil then
         cD.lastZoneLootOBJs  =  lastZoneLootOBJs
      end

      if zoneTotalCnts    ~= nil then
         if next(zoneTotalCnts)    ~= nil then
            cD.zoneTotalCnts        =  zoneTotalCnts
         end
      end
      if   itemCache   ~= nil then
         if next(itemCache)~= nil then
            cD.itemCache    = itemCache
         end
      end
      if charScore ~= nil then

         -- charScore (by itemID)
         cD.charScore   =  charScore

         --
         -- End   -  build cD.charScorebyName based on cD.charScore
         --
         -- Item Ids aren't unique, so i need to
         -- re-aggregate the "base" list by item
         -- name.
         --
         local zoneID   =  nil
         local tbl      =  {}
         for zoneID, tbl in pairs(cD.charScore) do

            for k, v in pairs(tbl) do

               if cD.charScorebyName[zoneID] then

                  local name = cD.itemCache[k].name
--[[
                  print("*** name=["..name.."]")
]]
                  if cD.charScorebyName[zoneID][name] then
--                      print(string.format("prima %s", cD.charScorebyName[zoneID][name].score))
                     cD.charScorebyName[zoneID][name] = { id=k, score=(cD.charScorebyName[zoneID][name].score + v) }
--                      print(string.format("poi   %s", cD.charScorebyName[zoneID][name].score))
                  else
                     cD.charScorebyName[zoneID][name] = { id=k, score=v }
                  end
               else
                  cD.charScorebyName[zoneID] =  { [cD.itemCache[k].name] = { id=k, score=v } }
               end
            end
         end
         --
         -- End   -  build cD.charScorebyName based on cD.charScore
         --

      end
   end

   if cD.text.base_font_name ~= nil then
      cD.text.base_font_name = "fonts/MonospaceTypewriter.ttf"
   end

   return
end

function cD.fiuSaveVariables(_, addonName)
   if addon.name == addonName then
      --
      -- we don't want to save the OBJECT,
      -- just coordinates and sizes
      --
      local a = cD.window
      a.infoOBJ   =  nil
      a.lootOBJ   =  nil
      a.buttonOBJ =  nil
      a.totalsOBJ =  nil
      a.ivOBJ     =  nil
      a.mmBtnOBJ  =  nil
      a.ttOBJ     =  nil

      guilog            =  a
      itemCache         =  cD.itemCache
      charScore         =  cD.charScore
      --
      lastZoneLootOBJs  =  cD.lastZoneLootOBJs
      zoneTotalCnts     =  cD.zoneTotalCnts


   end

   return
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cD.fiuLoadVariables,    "Load FIU Session Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cD.fiuSaveVariables,    "Save FIU Session Variables")
