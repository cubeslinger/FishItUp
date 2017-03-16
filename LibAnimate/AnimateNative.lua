local Addon, private = ...

-- Builtins
local error = error
local type = type

-- Locals
local defaultFadeDuration = 0.25
local fadingFrames = setmetatable({ }, { __mode = "kv" })
setfenv(1, private)

-- Projection for predefined animations
local singleProjection = GetProjection({ false, true })
local colorProjection_rgb = GetProjection({ false, true, true, true })
local colorProjection_rgba = GetProjection({ false, true, true, true, true })

local positionx = {
	TOPLEFT		= 0,
	TOPCENTER	= 0.5,
	TOPRIGHT	= 1,
	CENTERLEFT	= 0,
	CENTER		= 0.5,
	CENTERRIGHT	= 1,
	BOTTOMLEFT	= 0,
	BOTTOMCENTER= 0.5,
	BOTTOMRIGHT	= 1,
	
	TOP		= nil,
	BOTTOM	= nil,
	LEFT	= 0,
	RIGHT	= 1,
	CENTERX	= 0.5,
	CENTERY	= nil,
}

local positiony = {
	TOPLEFT		= 0,
	TOPCENTER	= 0,
	TOPRIGHT	= 0,
	CENTERLEFT	= 0.5,
	CENTER		= 0.5,
	CENTERRIGHT	= 0.5,
	BOTTOMLEFT	= 1,
	BOTTOMCENTER= 1,
	BOTTOMRIGHT	= 1,
	
	TOP		= 0,
	BOTTOM	= 1,
	LEFT	= nil,
	RIGHT	= nil,
	CENTERX	= nil,
	CENTERY	= 0.5,
}

-- Private methods
-- ============================================================================

local function start(projection, set, from, to, duration, interpolation, finish)
	local template = CreateTemplateWithProjection(projection, interpolation)
	local anim = CreateAnimation(template, set, duration, from, to, finish)
	anim:Start()
	return anim
end

local function startColor(self, duration, interpolation, r, g, b, a, finish, get, set)
	if(type(a) == "number") then
		return start(colorProjection_rgba, set, { self, get(self) }, { self, r, g, b, a }, duration, { false, interpolation, interpolation, interpolation, interpolation }, finish)
	else
		return start(colorProjection_rgb, set, { self, get(self) }, { self, r, g, b }, duration, { false, interpolation, interpolation, interpolation }, a)
	end
end

-- Public methods
-- ============================================================================

function AnimateAlpha(self, duration, interpolation, alpha, finish)
	return start(singleProjection, self.SetAlpha, { self, self:GetAlpha() }, { self, alpha }, duration, { false, interpolation }, finish)
end

function AnimateBackgroundColor(self, duration, interpolation, r, g, b, a, finish)
	return startColor(self, duration, interpolation, r, g, b, a, finish, self.GetBackgroundColor, self.SetBackgroundColor)
end

function AnimateFontColor(self, duration, interpolation, r, g, b, a, finish)
	return startColor(self, duration, interpolation, r, g, b, a, finish, self.GetFontColor, self.SetFontColor)
end

function AnimateHeight(self, duration, interpolation, height, finish)
	return start(singleProjection, self.SetHeight, { self, self:GetHeight() }, { self, height }, duration, { false, interpolation }, finish)
end

function AnimatePoint(self, duration, interpolation, ...)
	local args = { ... }
	local from = { self }
	local to = { self }
	local interpolations = { false }
	
	local i = 1
	local j = 2
	
	local function readPoint()
		local t = type(args[i])
		local x, y
		if(t == "string") then
			x, y = positionx[args[i]], positiony[args[i]]
			i = i + 1
		else
			x = args[i]
			y = args[i + 1]
			i = i + 2
		end
		return x, y
	end
	
	local fromx, fromy, tox, toy, from_dx, from_dy
	
	local x, y = readPoint()
	local target = args[i]
	i = i + 1
	local tox, toy = readPoint()
	
	-- point_on_this_frame
	if(x) then
		local layout, position, offset = self:ReadPoint(x, nil)
		offset = offset or 0
		if(layout == "origin") then
			error("Frame requires at least one SetPoint on x-axis before animating", 2)
		elseif(target ~= layout) then
			local target_x, target_dx = target:GetLeft(), target:GetWidth()
			local self_x, self_dx = self:GetLeft(), self:GetWidth()
			fromx = ((self_x + x * self_dx) - offset - target_x) / target_dx
		else
			fromx = position
		end
		from_dx = offset
	end
	if(y) then
		local layout, position, offset = self:ReadPoint(nil, y)
		offset = offset or 0
		if(layout == "origin") then
			error("Frame requires at least one SetPoint on y-axis before animating", 2)
		elseif(target ~= layout) then
			local target_y, target_dy = target:GetTop(), target:GetHeight()
			local self_y, self_dy = self:GetTop(), self:GetHeight()
			fromy = ((self_y + y * self_dy) - offset - target_y) / target_dy
		else
			fromy = position
		end
		from_dy = offset
	end
	
	from[j] = x
	to[j] = x
	interpolations[j] = false
	j = j + 1
	from[j] = y
	to[j] = y
	interpolations[j] = false
	j = j + 1
	
	-- target_frame
	from[j] = target
	to[j] = target
	interpolations[j] = false
	j = j + 1

	-- point_on_target_frame	
	from[j] = fromx
	to[j] = tox
	interpolations[j] = (fromx and tox) ~= nil and interpolation
	j = j + 1
	from[j] = fromy
	to[j] = toy
	interpolations[j] = (fromy and toy) ~= nil and interpolation
	j = j + 1
	
	-- [x_offset, y_offset]
	if(type(args[i]) == "number" or type(args[i]) == "nil") then
		if(type(args[i + 1]) ~= "number" and type(args[i + 1]) ~= "nil") then
			error("If an x-offset is given there must also be a y-offset present", 2)
		end
		from[j] = from_dx
		to[j] = args[i]
		interpolations[j] = (from_dx and to[j]) ~= nil and interpolation
		j = j + 1
		from[j] = from_dy
		to[j] = args[i + 1]
		interpolations[j] = (from_dy and to[j]) ~= nil and interpolation
		i = i + 2
	end
	
	local template = CreateTemplate(interpolations)
	local anim = CreateAnimation(template, self.SetPoint, duration, from, to, args[i])
	anim:Start()
	return anim
end

function AnimateWidth(self, duration, interpolation, width, finish)
	return start(singleProjection, self.SetWidth, { self, self:GetWidth() }, { self, width }, duration, { false, interpolation }, finish)
end

-- Convenience Methods
-- ============================================================================

local fadeTemplate = CreateTemplateWithProjection(singleProjection, { false, "linear" })
function FadeIn(self, duration)
	duration = duration or defaultFadeDuration
	local alpha = self:GetAlpha()
	if(not self:GetVisible()) then
		self:SetAlpha(0)
	end
	self:SetVisible(true)
	
	local animation = fadingFrames[self]
	if(animation) then
		animation:Stop()
		animation:Start(duration * (1 - self:GetAlpha()), { self, alpha }, { self, 1}, function() end)
	else
		animation = CreateAnimation(fadeTemplate, self.SetAlpha, duration * (1 - self:GetAlpha()), { self, alpha }, { self, 1}, function() end)
		animation:Start()
		fadingFrames[self] = animation
	end
end

function FadeOut(self, duration)
	duration = duration or defaultFadeDuration
	local alpha = self:GetAlpha()
	
	local animation = fadingFrames[self]
	if(animation) then
		animation:Stop()
		animation:Start(duration * self:GetAlpha(), { self, alpha}, { self, 0}, function() self:SetVisible(false) end)
	else
		animation = CreateAnimation(fadeTemplate, self.SetAlpha, duration * self:GetAlpha(), { self, alpha }, { self, 0}, function() self:SetVisible(false) end)
		animation:Start()
		fadingFrames[self] = animation
	end
end

function FadingIn(self)
	local animation = fadingFrames[self]
	return (animation and animation:Running() and animation.startValues[2] == 1) or false
end

function FadingOut(self)
	local animation = fadingFrames[self]
	return (animation and animation:Running() and animation.startValues[2] == 0) or false
end