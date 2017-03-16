local Addon, private = ...

-- Builtins
local concat = table.concat
local format = string.format
local loadstring = loadstring
local setfenv = setfenv
local split = string.split
local tostring = tostring
local type = type

-- Globals

-- Locals
local interpolants = setmetatable({
	-- [key] = f
}, { __mode = "v" })

local projections = setmetatable({
	-- [key] = f
}, { __mode = "v" })

setfenv(1, private)

-- Private methods
-- ============================================================================

local function makeProjectionKey(interpolations)
	local t = { }
	for i = 1, #interpolations do
		t[i] = interpolations[i] and "1" or "0"
	end
	return concat(t)
end

local function getProjection(interpolations)
	local key = makeProjectionKey(interpolations)
	if(projections[key]) then
		return projections[key]
	end
	
	local t = { }
	for i = 1, #interpolations do
		if(interpolations[i]) then
			t[#t + 1] = format("a[%i]+(b[%i]-a[%i])*f[%i](t)", i, i, i, i)
		else
			t[#t + 1] = format("a[%i]", i)
		end
	end
	
	local f = loadstring("local a,b,t,f=... return " .. concat(t, ",\n"), "projection " .. key)
	projections[key] = f
	return f
end

local function makeInterpolantKey(interpolations)
	local t = { }
	for i = 1, #interpolations do
		t[i] = tostring(interpolations[i])
	end
	return concat(t)
end

local function getInterpolants(interpolations)
	local key = makeInterpolantKey(interpolations)
	if(interpolants[key]) then
		return interpolants[key]
	end

	local env = { }
	for i = 1, #interpolations do
		local int = interpolations[i]
		local type = type(int)
		if(type == "string") then
			local strings = split(int, ":")
			if(#strings > 1) then
				for i = 2, #strings do
					strings[i] = strings[i] == "" and "nil" or strings[i]
				end
				env[i] = setfenv(loadstring(format("local t=... return %s(t,%s)", strings[1], concat(strings, ",", 2))), Interpolation)
			else
				env[i] = Interpolation[strings[1]] or Interpolation.linear
			end
		elseif(type == "function") then
			env[i] = int
		end
	end
	interpolants[key] = env
	return env
end

-- Public methods
-- ============================================================================

GetProjection = getProjection

GetInterpolants = getInterpolants

function CreateTemplateWithProjection(projection, interpolations)
	return {
		projection = projection,
		interpolants = getInterpolants(interpolations),
	}
end

function CreateTemplate(interpolations)
	return CreateTemplateWithProjection(getProjection(interpolations), interpolations)
end

