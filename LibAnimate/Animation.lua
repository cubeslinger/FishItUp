local Addon, private = ...

-- Upvalues
local Command = Command
local Event = Event
local InspectAddonCurrent = Inspect.Addon.Current
local InspectTimeFrame = Inspect.Time.Frame
local min = math.min
local pairs = pairs
local UtilityDispatch = Utility.Dispatch

-- Locals
local running = {
	-- [identifier] = { animations }
}
local pendingStarts = {
	-- [identifier] = { animations }
}
local paused = {
	-- [animation] = { data }
}
local animationsRunning = false

do
	local addons = Inspect.Addon.List()
	for name in pairs(addons) do
		running[name] = { }
		pendingStarts[name] = { }
	end
end

setfenv(1, private)

-- Private methods
-- ============================================================================

local function nop()
end

local function falsify()
	return false
end

local function animate()
	animationsRunning = true
	local now = InspectTimeFrame()
	for identifier, animations in pairs(running) do
		UtilityDispatch(function()
			for k, v in pairs(animations) do
				v[2] = v[2] + now - v[1] -- elapsed = elapsed + now - last update
				v[1] = now
				if(v[2] >= v[5]) then
					k.target(k.projection(v[3], v[4], 1, k.interpolants))
					animations[k] = nil
					v[6]()
				else
					local t = min(1, v[2] / v[5]) -- t = elapsed / duration
					k.target(k.projection(v[3], v[4], t, k.interpolants))
				end
			end
		end, identifier, "run animations")
	end
	animationsRunning = false
	
	for identifier, animations in pairs(pendingStarts) do
		local target = running[identifier]
		
		for k, v in pairs(animations) do
			if(not target[k]) then
				target[k] = v
			end
			animations[k] = nil
		end
	end
end

Command.Event.Attach(Event.System.Update.Begin, animate, "animate")

-- Public methods
-- ============================================================================

local function Pause(self)
	local addon = InspectAddonCurrent()

	local anim = running[addon][self]
	if(anim) then
		running[addon][self] = nil
	else
		anim = pendingStarts[addon][self]
		if(anim) then
			pendingStarts[addon][self] = nil
		end
	end
	if(anim) then
		paused[self] = anim
		local now = InspectTimeFrame()
		anim[2] = anim[2] + now - anim[1]
		anim[1] = now
	end
end

local function Paused(self)
	return paused[self] ~= nil
end

local function Resume(self)
	local addon = InspectAddonCurrent()

	local anim = paused[self]
	if(anim) then
		local t = animationsRunning and pendingStarts or running
		t[addon][self] = anim
		anim[1] = InspectTimeFrame()
	end
end

local function Running(self)
	local addon = InspectAddonCurrent()
	return running[addon][self] ~= nil
end

local function Start(self, duration, startValues, endValues, finish)
	local t = animationsRunning and pendingStarts or running
	
	local addon = InspectAddonCurrent()
	
	if(t[addon][self] or paused[self]) then
		return
	end
	
	t[addon][self] = {
		InspectTimeFrame(), -- last update
		0, -- elapsed
		startValues or self.startValues,
		endValues or self.endValues,
		duration or self.duration or 0,
		finish or self.finish,
	}
end

local function Stop(self)
	local addon = InspectAddonCurrent()
	running[addon][self] = nil
	paused[self] = nil
	pendingStarts[addon][self] = nil
end

function CreateAnimation(template, target, duration, startValues, endValues, finish)
	return {
		target = target,
		startValues = startValues,
		endValues = endValues,
		duration = duration or 0,
		finish = finish or nop,
		
		projection = template.projection,
		interpolants = template.interpolants,
		
		Pause = Pause,
		Paused = Paused,
		Resume = Resume,
		Running = Running,
		Start = Start,
		Stop = Stop,
	}
end

function CreateEmptyAnimation()
	return {
		Pause = nop,
		Resume = nop,
		Start = nop,
		Stop = nop,
		Paused = falsify,
		Running = falsify,
	}
end
