--
-- Addon       _fiu_gui_Info2.lua
-- Author      marcob@marcob.org
-- StartDate   25/05/2017
--
      
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


--- Pads str to length len with char from right
local function lpad(str, len, char)
   if char == nil then char = ' ' end
   --    return str .. string.rep(char, len - #str)
   return string.rep(char, len - #str) .. str
end

local function reverseTable(t)
   local reversedTable = {}
   local itemCount = #t
   for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
   end
   return reversedTable
end

