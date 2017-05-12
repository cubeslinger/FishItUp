--
-- Addon       FishItUp.lua
-- Author      marcob@marcob.org
-- StartDate   04/02/2017
--

local addon, cD = ...

cD.addon =  Inspect.Addon.Detail(Inspect.Addon.Current())["name"]
table.insert(Command.Slash.Register("fiu"), {function (params) cD.doThings(params)   end, cD.addon, "getpole command"})
-- Command.Event.Attach(Event.Unit.Availability.Full,  function(params) cD.doThings(params)  end,  "FIU AutoStart")
-- Command.Event.Attach(Event.Addon.Startup.End, cD.createMiniMapButton(), "FIU AutoStart")
Command.Event.Attach(Event.Addon.Load.End, function() cD.createMiniMapButton() end, "FIU AutoStart")

