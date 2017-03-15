--
-- Addon       _fiu_init.lua
-- Version     0.8
-- Author      marcob@marcob.org
-- StartDate   27/02/2017
-- StartDate   13/03/2017
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

function cD.mapZoneId2Name()
   local zoneId2Name =  {  z000000069C1F0227 = "Shimmersand",              -- Mathosia
                           z0000000CB7B53FD7 = "Silverwood",               -- Mathosia
                           z00000013CAF21BE3 = "Freemarch",                -- Mathosia
                           z000000142C649218 = "Scarwood Reach",           -- Mathosia
                           z00000016EB9ECBA5 = "Iron Pine Peak",           -- Mathosia
                           z0000001804F56C61 = "Moonshade Highlands",      -- Mathosia
                           z0000001A4AF8CD7A = "Stillmoor",                -- Mathosia
                           z0000001B2BB9E10E = "Gloamwood",                -- Mathosia
                           z019595DB11E70F58 = "Scarlet Gorge",            -- Mathosia
                           z1416248E485F6684 = "Droughtlands",             -- Mathosia
                           z487C9102D2EA79BE = "Sanctum",                  -- Mathosia
                           z585230E5F68EA919 = "Stonefield",               -- Mathosia
                           z0000001CE3FE8B2C = "Planetouched Wilds",       -- Planetouched Wilds
                           z11173F9D259DAADE = "Tempest Bay",              -- Nightmare Tides
                           z1C938C07F41C83CC = "Kingdom of Pelladane",     -- Nightmare Tides: Dusken
                           z59124F7DD7F15825 = "Seratos",                  -- Nightmare Tides: Dusken
                           z2F9C9E1FF91F9293 = "Steppes of Infinity",      -- Nightmare Tides: Dusken
                           z39095BA75AD7DC03 = "Morban",                   -- Nightmare Tides: Dusken
                           z48530386ED2EA5AD = "Eastern Holdings",         -- Nightmare Tides: Brevane
                           z563CB77E4A32233F = "Ardent Domain",            -- Nightmare Tides: Brevane
                           z698CB7B72B3D69E9 = "Cape Jule",                -- Nightmare Tides: Brevane
                           z6BA3E574E9564149 = "Meridian",                 -- Nightmare Tides: Brevane
                           z754553DD46F46371 = "City Core",                -- Nightmare Tides: Brevane
                           z10D7E74AB6D7B293 = "The Dendrome",             -- Nightmare Tides: Dendrome
                           z2F1E4708BEC6A608 = "Ashora",                   -- Nightmare Tides: Ashora
                           z6FEC49CAE466B014 = "Alittu",                   -- Starfall Profecy
                           z0000012D6EEBB377 = "Goboro Reef"

                        }

   return   zoneId2Name
end

function cD.getZoneMinSkill(zoneID)
   local retval   =  "n/a"
   local zMinLvls =  {  z0000000CB7B53FD7 = 1,     -- "Silverwood"
                        z00000013CAF21BE3 = 1,     -- "Freemarch"
                        z0000001B2BB9E10E = 40,    -- "Gloamwood"
                        z585230E5F68EA919 = 40,    -- "Stonefield"
                        z019595DB11E70F58 = 90,    -- "Scarlet Gorge"
                        z000000142C649218 = 90,    -- "Scarwood Reach"
                        z00000016EB9ECBA5 = 120,   -- "Iron Pine Peak"
                        z11173F9D259DAADE = 270,   -- "Tempest Bay"
                        z0000001804F56C61 = 150,   -- "Moonshade Highlands"
                        z1416248E485F6684 = 180,   -- "Droughtlands"
                        z000000069C1F0227 = 210,   -- "Shimmersand"
                        z0000001A4AF8CD7A = 210,   -- "Stillmoor"
                        z59124F7DD7F15825 = 318,   -- "Seratos"
                        z11173F9D259DAADE = 270,   -- "Tempest Bay",
                        z1C938C07F41C83CC = 270,   -- "Kingdom of Pelladane",
                        z59124F7DD7F15825 = 270,   -- "Seratos",
                        z2F9C9E1FF91F9293 = 270,   -- "Steppes of Infinity",
                        z39095BA75AD7DC03 = 270,   -- "Morban",
                        z48530386ED2EA5AD = 270,   -- "Eastern Holdings",
                        z563CB77E4A32233F = 270,   -- "Ardent Domain",
                        z698CB7B72B3D69E9 = 270,   -- "Cape Jule",
                        z6BA3E574E9564149 = 270,   -- "Meridian",
                        z754553DD46F46371 = 270,   -- "City Core",
                        z10D7E74AB6D7B293 = 270,   -- "The Dendrome",
                        z2F1E4708BEC6A608 = 270,   -- "Ashora",
                        -- xxx       =  120,    -- "Lake of Solace"
                        -- xxx       =  240,    -- "Ember Isle"
                        -- xxx       =  405,    -- "Scaterrhan Forest"
                     }

   if zMinLvls[zoneID]  ~= nil   then  retval   =  zMinLvls[zoneID]  end

   return   retval
end



local function _init()

   cD.window   =  {  width=300,     height=60,
                     infoObj=nil,   infoX=nil,     infoY=nil,
                     buttonObj=nil, buttonX=nil,   buttonY=nil,
                     lootObj=nil,   lootX=nil,     lootY=nil,
                     totalsObj=nil, totalsX=nil,   totalsY=nil
                  }
   -- loot Tables
   cD.sLTids      =  {}
   cD.sLTcnts     =  {}
   cD.sLTprcnts   =  {}
   cD.sLThdrs     =  {}
   cD.sLTFrames   =  {}
   cD.sLTtextObjs =  {}
   cD.sLTcntsObjs =  {}
   cD.sLTfullObjs =  {}
   cD.sLTprcntObjs=  {}
   cD.sLTrarity   =  {}
   -- totals Tables
   cD.sTOzoneIDs  =  {}
   cD.sTOFrame    =  {}
   cD.sTOznObjs   =  {}
   cD.sTOcntObjs  =  {}
   -- pole Table
   cD.poleTBL     =  {}
   -- pole Timer
   cD.poleTimer   =  nil

   cD.borders     =  {  left=4, top=4, right=4, bottom=4 }
--    cD.text        =  {  base_font_size=16 }
   cD.text        =  {  base_font_size=13 }
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
   cD.junkOBJ     =  nil
   cD.Stock       =  {}
   cD.itemCache   =  {}
   --
   -- Logs affected by the RESET button
   --
   cD.lastZoneLootObjs  =  {}    -- array of objs ID of last looted items indexed by ZoneID: [zoneID] = {objID_1, objID_2, ...}
   --
   -- Logs that are permanent
   --
   cD.zoneTotalCnts  =  {}
   --
   -- Log Debug
   --
   cD.zoneIDs  =  {}

   return cD
end

function cD.fiuLoadVariables(_, addonName)
   if addon.name == addonName then
      cD = _init()

      if guilog then
         cD.window            =  guilog
         cD.window.infoOBJ    =  nil
         cD.window.buttonOBJ  =  nil
         cD.window.totalsObj  =  nil
      end

      if lastZoneLootObjs ~= nil and next(lastZoneLootObjs) ~= nil then
         cD.lastZoneLootObjs  =  lastZoneLootObjs
      end

      if zoneTotalCnts    ~= nil then
         if next(zoneTotalCnts)    ~= nil then
            cD.zoneTotalCnts        =  zoneTotalCnts
         end
      end
      if waterlog         ~= nil then
         if next(waterlog)~= nil then
            cD.history     =  waterlog
         end
      end
      if zoneids          ~= nil then
         if next(zoneids) ~= nil then
            cD.zoneIDs     =  zoneids
         end
      end
      if itemCache         ~= nil then
         if next(itemCache)~= nil then
            cD.itemCache    = itemCache
         end
      end
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
      a.infoObj   =  nil
      a.lootObj   =  nil
      a.buttonObj =  nil
      a.totalsObj =  nil
      guilog      =  a

      waterlog          =  cD.history
      itemCache         =  cD.itemCache
      zoneids           =  cD.zoneIDs
      --
      lastZoneLootObjs  =  cD.lastZoneLootObjs
      zoneTotalCnts     =  cD.zoneTotalCnts


   end

   return
end


Command.Event.Attach(Event.Addon.SavedVariables.Load.End,   cD.fiuLoadVariables,    "Load FIU Session Variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, cD.fiuSaveVariables,    "Save FIU Session Variables")