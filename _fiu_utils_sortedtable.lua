--
-- Addon       _fiu_utils.lua
-- Source      http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
-- StartDate   04/05/2017
--
local addon, cD = ...

function cD.spairs(t, order)
   -- collect the keys
   local keys = {}
   for k in pairs(t) do keys[#keys+1] = k end

      -- if order function given, sort by it by passing the table and keys a, b,
      -- otherwise just sort the keys
      if order then
         table.sort(keys, function(a,b) return order(t, a, b) end)
      else
         table.sort(keys)
      end

      -- return the iterator function
      local i = 0
      return   function()
                  i = i + 1
                  if keys[i] then
                     return keys[i], t[keys[i]]
                  end
               end
end



--    Here is an example of use of such function:
--
--    HighScore = { Robin = 8, Jon = 10, Max = 11 }
--
--    -- basic usage, just sort by the keys
--    for k,v in spairs(HighScore) do
--       print(k,v)
--    end
--    --> Jon     10
--    --> Max     11
--    --> Robin   8
--
--    -- this uses an custom sorting function ordering by score descending
--    for k,v in spairs(HighScore, function(t,a,b) return t[b] < t[a] end) do
--       print(k,v)
--    end
--    --> Max     11
--    --> Jon     10
--    --> Robin   8

