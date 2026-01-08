local TweenService = game:GetService("TweenService")
local activeBouncers = {}
local Bounce = {}

--[[
EXAMPLE:

Animator:applyEffectWithConfig("Bounce", {
	duration = 4,
	intensity = 1,
	amplitude = 20,
	frequency = 1
})
]]

function Bounce.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.originalPosition = target.Position

	local bounceHeight = self.config.amplitude or 20
	local intensity = self.config.intensity or 1
	local frequency = self.config.frequency or 1

	local tweenDuration = 1 / frequency

	local currentTween
	local returnTween

	local function cleanup()
		if currentTween then
			currentTween:Cancel()
			currentTween = nil
		end
		if returnTween then
			returnTween:Cancel()
			returnTween = nil
		end
		activeBouncers[target] = nil
		self.running = false
	end

	function self:start()
		local existingBouncer = activeBouncers[target]
		if existingBouncer and existingBouncer ~= self then
			existingBouncer:stop()
		end
		if returnTween then
			returnTween:Cancel()
			returnTween = nil
			self.target.Position = self.originalPosition
		end
		cleanup()
		self.running = true
		activeBouncers[target] = self

		local adjustedHeight = bounceHeight * intensity

		currentTween = TweenService:Create(
			self.target,
			TweenInfo.new(
				tweenDuration * 0.5,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out,
				-1,
				true
			),
			{Position = self.originalPosition + UDim2.new(0, 0, 0, -adjustedHeight)}
		)
		currentTween:Play()
	end

	function self:stop()
		if not self.running then return end
		if currentTween then
			currentTween:Cancel()
			returnTween = TweenService:Create(
				self.target,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = self.originalPosition}
			)
			returnTween:Play()
			returnTween.Completed:Connect(function()
				returnTween = nil
			end)
		end
		cleanup()
	end

	target.AncestryChanged:Connect(function(_, parent)
		if not parent and self.running then
			self:stop()
		end
	end)

	return self
end

return Bounce