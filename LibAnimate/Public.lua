local Addon, private = ...

LibAnimate = {
	CreateAnimation = private.CreateAnimation,
	CreateEmptyAnimation = private.CreateEmptyAnimation,
	CreateTemplate = private.CreateTemplate,
	
	-- Predefined interpolation functions
	Interpolation = private.Interpolation,
	
	-- Predefined native animations
	AnimateAlpha = AnimateAlpha,
	AnimateBackgroundColor = AnimateBackgroundColor,
	AnimateFontColor = AnimateFontColor,
	AnimateHeight = AnimateHeight,
	AnimatePoint = AnimatePoint,
	AnimateWidth = AnimateWidth,
}
