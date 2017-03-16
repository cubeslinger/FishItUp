local Addon, private = ...

local asin = math.asin
local cos = math.cos
local exp = math.exp
local sin = math.sin
local π = math.pi
local sqrt = math.sqrt

setfenv(1, private)

--- Simple linear interpolation.
-- //f(t) = t//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function linear(t)
	return t
end

--- Cubic Hermite spline interpolation.
-- //f(t) = 3t^^2^^ - 2t^^3^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function smoothstep(t)
	return t * t * (3 - 2 * t)
end

--- Quadratic easing in interpolation.
-- //f(t) = t^^2^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInQuad(t)
	return t * t
end

--- Quadratic easing out interpolation.
-- //f(t) = 1 - (1 - t)^^2^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutQuad(t)
	return -t * (t - 2)
end

--- Cubic easing in interpolation.
-- //f(t) = t^^3^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInCubic(t)
	return t * t * t
end

--- Cubic easing out interpolation.
-- //f(t) = 1 - (1 - t)^^3^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutCubic(t)
	return t * ((t - 3) * t + 3)
end

--- Quartic easing in interpolation.
-- //f(t) = t^^4^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInQuart(t)
	t = t * t
	return t * t
end

--- Quartic easing out interpolation.
-- //f(t) = 1 - (1 - t)^^4^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutQuart(t)
	t = t - 1
	t = t * t
	return -(t * t) + 1
end

--- Quintic easing in interpolation.
-- //f(t) = t^^5^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInQuintic(t)
	local t2 = t * t
	return t2 * t2 * t
end

--- Quintic easing out interpolation.
-- //f(t) = 1 - (1 - t)^^5^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutQuintic(t)
	t = t - 1
	local t2 = t * t
	return t2 * t2 * t + 1
end

--- Arbitrarily raised easing in interpolation.
-- //f(t) = t^^n^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param n The power to raise the interpolant to.
-- @return The interpolated value in the range //[0;1]// if //n >= 0// otherwise //[0;+∞]//.
local function easeInPower(t, n)
	return t^n
end

--- Arbitrarily raised easing out interpolation.
-- //f(t) = 1 - (1 - t)^^n^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param n The power to raise the interpolant to.
-- @return The interpolated value in the range //[0;1]// if //n >= 0// otherwise //[0;+∞]//.
local function easeOutPower(t, n)
	return 1 - (1 - t)^n
end

--- Sinusoidal easing in interpolation.
-- //f(t) = 1 - cos(π/2 × t)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInSine(t)
	return 1 - cos(t * π * 0.5)
end

--- Sinusoidal easing out interpolation.
-- //f(t) = sin(π/2 × t)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutSine(t)
	return sin(t * π * 0.5)
end

--- Exponential easing in interpolation.
-- //f(t) = e^^10(t - 1)^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInExp(t)
	return exp(10 * (t - 1))
end

--- Exponential easing out interpolation.
-- //f(t) = 1 - e^^-10t^^//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutExp(t)
	return 1 - exp(-10 * t)
end

--- Circular easing in interpolation.
-- //f(t) = 1 - sqrt(1 - t^^2^^)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInCircular(t)
	return 1 - sqrt(1 - t * t)
end

--- Circular easing out interpolation.
-- //f(t) = sqrt(1 - (t - 1)^^2^^)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutCircular(t)
	t = t - 1
	return sqrt(1 - t * t)
end

--- Elastic (exponentially decaying sine wave) easing in interpolation.
-- //f(t) = -(amplitude × e^^10(t - 1)^^ × sin(2π(t - 1 - period × asin(1 / amplitude) / 2π) / period))//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param amplitude The amplitude of the sine wave (default //1//).
-- @param period The period of the sine wave (default //0.3//).
-- @return The interpolated value. It is **not** guaranteed to lie in the range //[0;1]//.
local function easeInElastic(t, amplitude, period)
	amplitude = amplitude or 1
	period = period or 0.3
	local s = period / (2 * π) * asin(1 / amplitude)
	t = t - 1
	return -(amplitude * exp(10 * t) * sin((t - s) * (2 * π) / period))
end

--- Elastic (exponentially decaying sine wave) easing out interpolation.
-- //f(t) = amplitude × e^^-10t^^ × sin(2π(t - period × asin(1 / amplitude) / 2π) / period) + 1//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param amplitude The amplitude of the sine wave (default //1//).
-- @param period The period of the sine wave (default //0.3//).
-- @return The interpolated value. It is **not** guaranteed to lie in the range //[0;1]//.
local function easeOutElastic(t, amplitude, period)
	amplitude = amplitude or 1
	period = period or 0.3
	local s = period / (2 * π) * asin(1 / amplitude)
	return amplitude * exp(-10 * t) * sin((t - s) * (2 * π) / period) + 1
end

--- Back (overshooting cubic) easing in interpolation.
-- //f(t) = t^^2^^((overshoot + 1)t - overshoot)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param overshoot The overshoot of the cubic polynomial (default //1.70158// equates to about //10%//).
-- @return The interpolated value. It is **not** guaranteed to lie in the range //[0;1]//.
local function easeInBack(t, overshoot)
	overshoot = overshoot or 1.70158
	return t * t * ((overshoot + 1) * t - overshoot)
end

--- Back (overshooting cubic) easing out interpolation.
-- //f(t) = (t - 1)^^2^^((overshoot + 1)(t - 1) - overshoot)//\\
-- @param t The interpolant in the range //[0;1]//.
-- @param overshoot The overshoot of the cubic polynomial (default //1.70158// equates to about //10%//).
-- @return The interpolated value. It is **not** guaranteed to lie in the range //[0;1]//.
local function easeOutBack(t, overshoot)
	overshoot = overshoot or 1.70158
	t = t - 1
	return t * t * ((overshoot + 1) * t + overshoot) + 1
end

--- Bounce (exponentially decaying parabolic bounce) easing out interpolation.
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeOutBounce(t)
	local scale = 7.5625
	local edge = 1 / 2.75
	if(t < edge) then
		return scale * t * t
	elseif(t < 2 * edge) then
		t = t - 1.5 * edge
		return scale * t * t + 0.75
	elseif(t < 2.5 * edge) then
		t = t - 2.25 * edge
		return scale * t * t + 0.9375
	else
		t = t - 2.625 * edge
		return scale * t * t + 0.984375
	end
end

--- Bounce (exponentially decaying parabolic bounce) easing in interpolation.
-- @param t The interpolant in the range //[0;1]//.
-- @return The interpolated value in the range //[0;1]//.
local function easeInBounce(t)
	return 1 - easeOutBounce(1 - t)
end

local function easeInOut(f1, f2, t, ...)
	return t <= 0.5 and (f1(2 * t, ...) * 0.5) or (f2((t - 0.5) * 2, ...) * 0.5 + 0.5)
end

Interpolation = {
	linear = linear,
	smoothstep = smoothstep,
	
	easeInQuad = easeInQuad,
	easeInCubic = easeInCubic,
	easeInQuart = easeInQuart,
	easeInQuint = easeInQuint,
	easeInSine = easeInSine,
	easeInPower = easeInPower,
	easeInExp = easeInExpo,
	easeInCirc = easeInCirc,
	easeInElastic = easeInElastic,
	easeInBack = easeInBack,
	easeInBounce = easeInBounce,
	
	easeOutQuad = easeOutQuad,
	easeOutCubic = easeOutCubic,
	easeOutQuart = easeOutQuart,
	easeOutQuint = easeOutQuint,
	easeOutSine = easeOutSine,
	easeOutPower = easeOutPower,
	easeOutExp = easeOutExp,
	easeOutCirc = easeOutCirc,
	easeOutElastic = easeOutElastic,
	easeOutBack = easeOutBack,
	easeOutBounce = easeOutBounce,
	
	easeInOutQuad = function(t) return easeInOut(easeInQuad, easeOutQuad, t) end,
	easeInOutCubic = function(t) return easeInOut(easeInCubic, easeOutCubic, t) end,
	easeInOutQuart = function(t) return easeInOut(easeInQuart, easeOutQuart, t) end,
	easeInOutQuint = function(t) return easeInOut(easeInQuint, easeOutQuint, t) end,
	easeInOutSine = function(t) return easeInOut(easeInSine, easeOutSine, t) end,
	easeInOutPower = function(t, power) return easeInOut(easeInPower, easeOutPower, t, power) end,
	easeInOutExp = function(t) return easeInOut(easeInExp, easeOutExp, t) end,
	easeInOutCirc = function(t) return easeInOut(easeInCirc, easeOutCirc, t) end,
	easeInOutElastic = function(t, amplitude, period) return easeInOut(easeInElastic, easeOutElastic, t, amplitude, period) end,
	easeInOutBack = function(t, overshoot) return easeInOut(easeInBack, easeOutBack, t, overshoot) end,
	easeInOutBounce = function(t) return easeInOut(easeInBounce, easeOutBounce, t) end,
	
	easeOutInQuad = function(t) return easeInOut(easeOutQuad, easeInQuad, t) end,
	easeOutInCubic = function(t) return easeInOut(easeOutCubic, easeInCubic, t) end,
	easeOutInQuart = function(t) return easeInOut(easeOutQuart, easeInQuart, t) end,
	easeOutInQuint = function(t) return easeInOut(easeOutQuint, easeInQuint, t) end,
	easeOutInSine = function(t) return easeInOut(easeOutSine, easeInSine, t) end,
	easeOutInPower = function(t, power) return easeInOut(easeOutPower, easeInPower, t, power) end,
	easeOutInExp = function(t) return easeInOut(easeOutExp, easeInExp, t) end,
	easeOutInCirc = function(t) return easeInOut(easeOutCirc, easeInCirc, t) end,
	easeOutInElastic = function(t, amplitude, period) return easeInOut(easeOutElastic, easeInElastic, t, amplitude, period) end,
	easeOutInBack = function(t, overshoot) return easeInOut(easeOutBack, easeInBack, t, overshoot) end,
	easeOutInBounce = function(t) return easeInOut(easeOutBounce, easeInBounce, t) end,
}