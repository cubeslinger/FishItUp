do

local symbols = { }

symbols["LibAnimate.CreateTemplate"] = {
	summary = [[
Factory method for animation templates.

]],
	signatures = {
		"template = LibAnimate.CreateTemplate(interpolations) -- Template <- table",
	},
	parameter = {
		["interpolations"] = "An array containing the animation functions. Values which are not intended to be animated are marked with the value false (not nil).",
	},
	result = {
		["template"] = "A new animation template.",
	},
	type = "function",
}

symbols["Template"] = {
	summary = [[
The library is based on two components: templates and animations. A template specifies how values are interpolated and forwarded to the target function, for example "interpolate values #1 and #5 linearly, #2 quadratically and forward #3 and #4 unchanged". Creating templates may be an expensive operation as it may involve multiple calls to loadstring, but they are expected to be created once at Addon startup and then reused. Even though they are cached it is an unnecessary amount of work to recreate templates more often than necessary.

You may have noticed the predefined Frame:AnimateXX methods do not have a template argument. The reasoning behind this design decision is their ease of use. Not having to worry about template management makes the methods very convenient to use, but they incurr a slight performance hit due to the template creation (though this overhead slowly diminishes as templates are cached if the interpolation function stays the same). This will usually not be a problem as long as you do not launch a gazillion animations at once. If you are paranoid about performance then create the templates and animations only when necessary. Remeber you can reuse animations after they finished running.]],
}

symbols["Values"] = {
	summary = [[
The library can animate any values of type T for which the following operations are defined (either implicitly or by metatables):

	T + T
	T - T
	T * number

If you receive errors like "performing arithmetic on XXX value" it means you are providing values for which one of the above conditions is not satisfied. The values in the two tables provided to CreateAnimation and/or Start are mapped based on their index. For the time being only numerically indexed values are supported. The number of values as well as their position must be consistent across CreateTemplate, CreateAnimation and Start or errors might occur.]],
}

symbols["Interpolation"] = {
	summary = [[
The interpolation functions are performing the actual computations. They all receive as first argument the transition factor t in the range [0;1] and optionally additional parameters depending on the type of interpolation. The return value is usually also within the range [0;1], which means the interpolated values do not exceed the interval [start value;end value]. There are however interpolations which do not satisfy this constraint (for example the elastic and back functions) and you need to be prepared to handle these cases.

The library comes shipped with an extensive list of interpolation functions listed below. A page showing their plots can be viewed at http://hosted.zeh.com.br/tweener/docs/en-us/misc/transitions.html (make sure the Complete button is pressed). In addition to those smoothstep and easeInPower, easeOutPower, easeInOutPower, easeOutInPower are provided.]],
	signatures = {
		"factor = f(t) -- number <- number",
	},
	parameter = {
		["t"] = "The interpolation factor. This is a value in the range [0;1] where 0 marks the beginning of the animation transition and 1 the end.",
	},
	result = {
		["factor"] = [[The factor which should be applied to the actual interpolation values. It is usually also in the range [0;1] but is not required to, in which case the function may "overshoot" or "undershoot" the target value.]]
	},
	["Code Usage"] = [[
When LibAnimate functions take an argument of type "Interpolation" they accept either a string or a function. In case of a string it has to name one of the predefined interpolation functions as shown in the table below.

If it is a function it needs to satisfy the signature for "f" as shown above.

Some predefined functions may take additional arguments, for example "easeInPower:n". In that case the argument needs to be embedded in the string, for example "easeInPower:3.567".]],
	["Predefined Interpolations"] = {
		["linear"] = [[
Simple linear interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = t</font>]],
		["smoothstep"] = [[
Cubic Hermite spline interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 3t^2 - 2t^3</font>]],
		["easeInQuad"] = [[
Quadratic easing in interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = t ^2</font>]],
		["easeOutQuad"] = [[
Quadratic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - (1 - t)^2</font>]],
		["easeInCubic"] = [[
Cubic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = t^3</font>]],
		["easeOutCubic"] = [[
Cubic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - (1 - t)^3</font>]],
		["easeInQuartic"] = [[
Quartic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = t^4</font>]],
		["easeOutQuartic"] = [[
Quartic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - (1 - t)^4</font>]],
		["easeInQuintic"] = [[
Quintic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = t^5</font>]],
		["easeOutQuintic"] = [[
Quintic easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - (1 - t)^5</font>]],
		[ [[easeInPower:<font color="#92eaa1">n</font>]] ] = [[
Arbitrarily raised easing in interpolation.
	<font color="#ff9730">n &gt;= 0 then [0;1] else [0;+inf]</font>
	<font color="#92eaa1">f(t) = t^n</font>]],
		[ [[easeOutPower:<font color="#92eaa1">n</font>]] ] = [[
Arbitrarily raised easing out interpolation.
	<font color="#ff9730">n &gt;= 0 then [0;1] else [0;+inf]</font>
	<font color="#92eaa1">f(t) = 1 - (1 - t)^n</font>]],
		["easeInSine"] = [[
Sinusoidal easing in interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - cos(pi/2 * t)</font>]],
		["easeOutSine"] = [[
Sinusoidal easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = sin(pi/2 * t)</font>]],
		["easeInExp"] = [[
Exponential easing in interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = exp(10(t - 1))</font>]],
		["easeOutExp"] = [[
Exponential easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - exp(-10t)</font>]],
		["easeInCircular"] = [[
Circular easing in interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = 1 - sqrt(1 - t^2)</font>]],
		["easeOutCircular"] = [[
Circular easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = sqrt(1 - (t - 1)^2)</font>]],
		[ [[easeInElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]] ] = [[
Elastic (exponentially decaying sine wave) easing in interpolation. <font color="#ff9730">[-inf;1]</font>
	<font color="#92eaa1">f(t) = -(amplitude * exp(10(t - 1)) *
		sin(2pi(t - 1 - period * asin(1 / amplitude) / 2pi) /
			period))</font>
Default values:
	amplitude = 1
	period= 0.3]],
		[ [[easeOutElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]] ] = [[
Elastic (exponentially decaying sine wave) easing out interpolation. <font color="#ff9730">[0;+inf]</font>
	<font color="#92eaa1">f(t) = amplitude * exp(-10t) *
		sin(2pi(t - period * asin(1 / amplitude) / 2pi) /
			period) + 1</font>
Default values:
	amplitude = 1
	period= 0.3]],
		[ [[easeInBack:<font color="#92eaa1">overshoot</font>]] ] = [[
Back (overshooting cubic) easing in interpolation. <font color="#ff9730">[-inf;1]</font>
	<font color="#92eaa1">f(t) = t^2 * ((overshoot + 1)t - overshoot)</font>
Default values:
	overshoot = 1.70158 (about 10%)]],
		[ [[easeOutBack:<font color="#92eaa1">overshoot</font>]] ] = [[
Back (overshooting cubic) easing out interpolation. <font color="#ff9730">[0;+inf]</font>
	<font color="#92eaa1">f(t) = (t - 1)^2 * ((overshoot + 1)(t - 1) - overshoot)</font>
Default values:
	overshoot = 1.70158 (about 10%)]],
		["easeInBounce"] = [[
Circular easing in interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = complicated</font>]],
		["easeOutBounce"] = [[
Circular easing out interpolation. <font color="#ff9730">[0;1]</font>
	<font color="#92eaa1">f(t) = complicated</font>]],
		
		["easeInOutQuad"] = "easeInQuad, easeOutQuad",
		["easeInOutCubic"] = "easeInCubic, easeOutCubic",
		["easeInOutQuart"] = "easeInQuart, easeOutQuart",
		["easeInOutQuint"] = "easeInQuint, easeOutQuint",
		["easeInOutSine"] = "easeInSine, easeOutSine",
		[ [[easeInOutPower:<font color="#92eaa1">n</font>]] ] = [[easeInPower:<font color="#92eaa1">n</font>, easeOutPower:<font color="#92eaa1">n</font>]],
		["easeInOutExp"] = "easeInExp, easeOutExp",
		["easeInOutCirc"] = "easeInCirc, easeOutCirc",
		[ [[easeInOutElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]] ] = [[easeInElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>, easeOutElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]],
		[ [[easeInOutBack:<font color="#92eaa1">overshoot</font>]] ] = [[easeInBack:<font color="#92eaa1">overshoot</font>, easeOutBack:<font color="#92eaa1">overshoot</font>]],
		["easeInOutBounce"] = "easeInBounce, easeOutBounce",
		
		["easeOutInQuad"] = "easeOutQuad, easeInQuad",
		["easeOutInCubic"] = "easeOutCubic, easeInCubic",
		["easeOutInQuart"] = "easeOutQuart, easeInQuart",
		["easeOutInQuint"] = "easeOutQuint, easeInQuint",
		["easeOutInSine"] = "easeOutSine, easeInSine",
		[ [[easeOutInPower:<font color="#92eaa1">n</font>]] ] = [[easeOutPower:<font color="#92eaa1">n</font>, easeInPower:<font color="#92eaa1">n</font>]],
		["easeOutInExp"] = "easeOutExp, easeInExp",
		["easeOutInCirc"] = "easeOutCirc, easeInCirc",
		[ [[easeOutInElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]] ] = [[easeOutElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>, easeInElastic:<font color="#92eaa1">amplitude</font>:<font color="#92eaa1">period</font>]],
		[ [[easeOutInBack:<font color="#92eaa1">overshoot</font>]] ] = [[easeOutBack:<font color="#92eaa1">overshoot</font>, easeInBack:<font color="#92eaa1">overshoot</font>]],
		["easeOutInBounce"] = "easeOutBounce, easeInBounce",
	},
}

symbols["Animation"] = {
	summary = [[
Animation is the kind of object used to control a single animation. The object is used to start, stop, pause and resume an animation. Animation objects can be reused once they stopped their animation. Simply calling :Start() again repeats the animation. It is also possible to override the animation values for each subsequent execution by providing those values in :Start(), however they are only used for one run.

Reusing animations is prefered to recreating them each time. An Animation instance is only tied to the template and target function it was created with. All other values can be changed. That means: only because you created an animation to move frame A doesn't mean you cannot use the very same animation to move frame B, as long as you don't try to run the animation twice in parallel, which doesn't work. This allows you to cache unused animations to reduce pressure on the garbage collector.]],
	type = "type",
}

symbols["LibAnimate.CreateAnimation"] = {
	summary = [[
Factory method for Animation objects. It is the only way to create a new animation from an animation template.]],
	signatures = {
		"animation = LibAnimate.CreateAnimation(template, target, duration, startValues, endValues) -- Animation <- Template, function, number, table, table",
		"animation = LibAnimate.CreateAnimation(template, target, duration, startValues, endValues[, finish]) -- Animation <- Template, function, number, table, table, function",
	},
	parameter = {
		["template"] = "The animation template from which to instantiate the animation. The template defines animation curves and value projection.",
		["target"] = "The Lua function which is called each time the animation is evaluated.",
		["duration"] = "The animation duration in seconds.",
		["startValues"] = "An arrray containing the starting values. The types of values must match the expected values defined by the template. Values which are not interpolated (i.e. their template interpolant is false) always equal to those in startValues.",
		["endValues"] = "An array containing the end values. The types must be compatible with startValues.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "A new independent animation.",
	},
	type = "function",
}

symbols["LibAnimate.CreateEmptyAnimation"] = {
	summary = [[
Create an empty animation which does nothing.

Empty animations are useful to avoid needless and confusing if-tests for nil. Instead of assigning your animation variables nil when they should be disabled and having to test it every time you want to access a member, simply assign the result from CreateEmptyAnimation() and you can pass it to your remaining animation using code without having to fear errors.]],
	signatures = {
		"animation = LibAnimate.CreateEmptyAnimation() -- Animation <- void",
	},
	parameter = {
	},
	result = {
		["animation"] = "An empty animation which does nothing. All its methods are dummies without any function and all query methods return false.",
	},
	type = "function",
}

symbols["Animation:Start"] = {
	summary = [[
Start the animation if it is not already running or paused, optionally overriding animation properties it was created with (for this run only).]],
	signatures = {
		"Animation:Start(duration, startValues, endValues, finish) -- number/nil, table/nil, table/nil, function/nil",
	},
	parameter = {
		["duration"] = "Same meaning as the duration parameter in LibAnimate.CreateAnimation(). If it is present and non-nil it overrides the duration parameter the animation was created with for this single execution.",
		["startValues"] = "Same meaning as the startValues parameter in LibAnimate.CreateAnimation(). If it is present and non-nil it overrides the startValues parameter the animation was created with for this single execution.",
		["endValues"] = "Same meaning as the endValues parameter in LibAnimate.CreateAnimation(). If it is present and non-nil it overrides the endValues parameter the animation was created with for this single execution.",
		["finish"] = "Same meaning as the finish parameter in LibAnimate.CreateAnimation(). If it is present and non-nil it overrides the finish parameter the animation was created with for this single execution.",
	},
	result = {
	},
	type = "function",
}

symbols["Animation:Stop"] = {
	summary = [[
Stop the animation if it is currently running or paused. Does <b>not</b> call the finish callback.

Has no effect if the animation is neither paused nor running.]],
	signatures = {
		"Animation:Stop()",
	},
	parameter = {
	},
	result = {
	},
	type = "function",
}

symbols["Animation:Pause"] = {
	summary = [[
Pause the animation if it is currently running.

Has no effect if the animation is either not running or already paused.]],
	signatures = {
		"Animation:Pause()",
	},
	parameter = {
	},
	result = {
	},
	type = "function",
}

symbols["Animation:Paused"] = {
	summary = [[
Pause the animation if it is currently running.

Has no effect if the animation is either not running or already paused.]],
	signatures = {
		"paused = Animation:Paused() -- boolean <- void",
	},
	parameter = {
	},
	result = {
		["paused"] = "true if the animation is currently in the paused state, otherwise false."
	},
	type = "function",
}

symbols["Animation:Resume"] = {
	summary = [[
Resume the animation if it is currently paused.

Has no effect if the animation is not paused.]],
	signatures = {
		"Animation:Resume()",
	},
	parameter = {
	},
	result = {
	},
	type = "function",
}

symbols["Animation:Running"] = {
	summary = [[
Determine whether the animation is currently running and not paused.]],
	signatures = {
		"running = Animation:Running() -- boolean <- void",
	},
	parameter = {
	},
	result = {
		["running"] = "true if the animation is currently running and not paused, false otherwise."
	},
	type = "function",
}

symbols["Frame:AnimateAlpha"] = {
	summary = [[
Animate the frame's alpha value using Frame:SetAlpha(alpha) over the specified duration and interpolation function.

The animation is started immediately.]],
	signatures = {
		"animation = Frame:AnimateAlpha(duration, interpolation, alpha) -- Animation <- number, Interpolation, number",
		"animation = Frame:AnimateAlpha(duration, interpolation, alpha, finish) -- Animation <- number, Interpolation, number, function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["alpha"] = "The target alpha to interpolate to. The starting value is the frame's current alpha.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Frame:AnimateBackgroundColor"] = {
	summary = [[
Animate the frame's background color using Frame:SetBackgroundColor(r, g, b[, a]) over the specified duration and interpolation function.

The animation is started immediately.]],
	signatures = {
		"animation = Frame:AnimateBackgroundColor(duration, interpolation, r, g, b, a) -- Animation <- number, Interpolation, number, number, number, number/nil",
		"animation = Frame:AnimateBackgroundColor(duration, interpolation, r, g, b, a, finish) -- Animation <- number, Interpolation, number, number, number, number/nil, function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["r"] = "The background color red channel to interpolate to. The starting value is the frame's current background color red channel.",
		["g"] = "The background color green channel to interpolate to. The starting value is the frame's current background color green channel.",
		["b"] = "The background color blue channel to interpolate to. The starting value is the frame's current background color blue channel.",
		["a"] = "The background color alpha channel to interpolate to. The starting value is the frame's current background color alpha channel. If nil the frame's background alpha is not changed.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Frame:AnimateHeight"] = {
	summary = [[
Animate the frame's height using Frame:SetHeight(height) over the specified duration and interpolation function.

The animation is started immediately.]],
	signatures = {
		"animation = Frame:AnimateHeight(duration, interpolation, height) -- Animation <- number, Interpolation, number",
		"animation = Frame:AnimateHeight(duration, interpolation, height, finish) -- Animation <- number, Interpolation, number, function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["height"] = "The target height to interpolate to. The starting value is the frame's current height.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Frame:AnimatePoint"] = {
	summary = [[
Animate the frame's given point using Frame:SetPoint(...) over the given duration and interpolation function.

To quote the documentation for Frame:SetPoint():
	"This function's parameters are complicated."

And so are the parameters of Frame:AnimatePoint().

The ... part matches the arguments accepted by Frame:SetPoint(). This variety of argument combinations gives the function a big drawback: Every time it is called it must analyze all parameters and create a proper animation template for the given combination. This can result in quite some overhead if you're attempting to trigger lots of point animations at once.

Additionally, under the hood tags like "TOPLEFT" or "RIGHT" are translated to their respective (x, y) pairs. Using this approach it is possible to interpolate a point, for example, from "TOPLEFT" to "TOPRIGHT" without having to deal with the underlying numeric coordinates.

Lastly, the interpolation function is applied to all animatable arguments (i.e. the points and any offsets if given), so if you need finer control over each parameter's animation curve you cannot solve that with this method.

For the points mentioned above it is highly advisable to use this function rather rarely, or for rapid prototyping only. In the latter case, once you know how you want your frame to be animated, create your own animation template and spawn animations from it. That will speed things up alot if you need to move many frames at once, reducing the risk of performance warnings (talking about starting 100+ animations at once). However, if you only move a frame here and there, the function should do it's job just fine. If at all possible try to keep the number of argument combinations as low as possible.

One last thing to note: the target frame need not be the same the frame is currently anchored to. That means you can :SetPoint() to frame A and then :AnimatePoint() to frame B. The function does the necessary coordinate space transformations to make it work as expected.]],
	signatures = {
		"animation = Frame:AnimatePoint(duration, interpolation, ...) -- Animation <- number, Interpolation, ...",
		"animation = Frame:AnimatePoint(duration, interpolation, ..., finish) -- Animation <- number, Interpolation, ..., function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["..."] = "The same argument combinations as are accepted by Frame:SetPoint().",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Frame:AnimateWidth"] = {
	summary = [[
Animate the frame's width using Frame:SetWidth(width) over the specified duration and interpolation function.

The animation is started immediately.]],
	signatures = {
		"animation = Frame:AnimateWidth(duration, interpolation, width) -- Animation <- number, Interpolation, number",
		"animation = Frame:AnimateWidth(duration, interpolation, width, finish) -- Animation <- number, Interpolation, number, function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["width"] = "The target width to interpolate to. The starting value is the frame's current width.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Text:AnimateFontColor"] = {
	summary = [[
Animate the frame's font color using Text:SetFontColor(r, g, b[, a]) over the specified duration and interpolation function.

The animation is started immediately.]],
	signatures = {
		"animation = Text:AnimateFontColor(duration, interpolation, r, g, b, a) -- Animation <- number, Interpolation, number, number, number, number/nil",
		"animation = Text:AnimateFontColor(duration, interpolation, r, g, b, a, finish) -- Animation <- number, Interpolation, number, number, number, number/nil, function",
	},
	parameter = {
		["duration"] = "The animation duration in seconds.",
		["interpolation"] = "The interpolation function to be used.",
		["r"] = "The font color red channel to interpolate to. The starting value is the frame's current font color red channel.",
		["g"] = "The font color green channel to interpolate to. The starting value is the frame's current font color green channel.",
		["b"] = "The font color blue channel to interpolate to. The starting value is the frame's current font color blue channel.",
		["a"] = "The font color alpha channel to interpolate to. The starting value is the frame's current font color alpha channel. If nil the font color alpha value is not changed.",
		["finish"] = "An optional Lua function to be executed after the animation finished.",
	},
	result = {
		["animation"] = "The Animation object associated with the animation which you can use to control it.",
	},
	type = "function",
}

symbols["Frame:FadeIn"] = {
	summary = [[
Make the frame visible and animate it's alpha linearly to 1.

The duration is mapped to the [0;1] range, so if the frame is currently at alpha=0.5 it will take only half the time to fade in.]],
	signatures = {
		"Frame:FadeIn()",
		"Frame:FadeIn(duration) -- number",
	},
	parameter = {
		["duration"] = "The animation duration in seconds. Defaults to 0.25 seconds.",
	},
	result = {
	},
	type = "function",
}

symbols["Frame:FadeOut"] = {
	summary = [[
Animate the frame's alpha linearly to 0 and hide it afterwards.

The duration is mapped to the [0;1] range, so if the frame is currently at alpha=0.5 it will take only half the time to fade out.]],
	signatures = {
		"Frame:FadeOut()",
		"Frame:FadeOut(duration) -- number",
	},
	parameter = {
		["duration"] = "The animation duration in seconds. Defaults to 0.25 seconds.",
	},
	result = {
	},
	type = "function",
}

symbols["Frame:FadingIn"] = {
	summary = [[
Determine whether the frame is currently fading in.]],
	signatures = {
		"fading = Frame:FadingIn() -- boolean <- void",
	},
	parameter = {
	},
	result = {
		["fading"] = "true if the frame is currently fading in, otherwise false.",
	},
	type = "function",
}

symbols["Frame:FadingOut"] = {
	summary = [[
Determine whether the frame is currently fading out.]],
	signatures = {
		"fading = Frame:FadingOut() -- boolean <- void",
	},
	parameter = {
	},
	result = {
		["fading"] = "true if the frame is currently fading out, otherwise false.",
	},
	type = "function",
}

LibAnimate.ApiBrowserIndex = symbols
LibAnimate.ApiBrowserInspect = function(path) return symbols[path] end
LibAnimate.ApiBrowserSummary = [[
LibAnimate is a library for performing time-based interpolation of values.

It gives you the ability to animate properties of Rift frames out-of-the-box with very little code. It has a comprehensive set of interpolation functions for a high variety of animation curves. All you need to provide are starting values, end values, a duration and the name the of interpolation function, and the rest is handled behind the scenes for you.

The library comes shipped with predefined convenience functions to remove the boilerplate code for animating predefined frame properties. They are added to the metatables of Frame, Mask, RiftButton, RiftCheckbox, RiftScrollbar, RiftSlider, RiftTextfield, RiftWindow, Text and Texture.]]

end