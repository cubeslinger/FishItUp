local Addon, private = ...

local sharedMethods = {
	"AnimateAlpha",
	"AnimateBackgroundColor",
	"AnimateHeight",
	"AnimatePoint",
	"AnimateWidth",
	"FadeIn",
	"FadeOut",
	"FadingIn",
	"FadingOut",
}
local specialMethods = {
	Frame =			{ },
	Mask =			{ },
	RiftButton =	{ },
	RiftCheckbox =	{ },
	RiftScrollbar =	{ },
	RiftSlider =	{ },
	RiftTextfield =	{ },
	RiftWindow =	{ },
	Text =			{ "AnimateFontColor" },
	Texture =		{ },
}

private.Context = UI.CreateContext(Addon.identifier)
for k, v in pairs(specialMethods) do
	local frame = UI.CreateFrame(k, "", private.Context)
	frame:SetVisible(false)
	
	local meta = getmetatable(frame).__index
	for i = 1, #sharedMethods do
		meta[sharedMethods[i]] = private[sharedMethods[i]]
	end
	for i = 1, #v do
		meta[v[i]] = private[v[i]]
	end
end