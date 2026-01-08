local TweenService = game:GetService("TweenService")
local Wave = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Wave", {
    duration = 2,
    intensity = 1,
    colorA = Color3.fromRGB(255, 182, 255), -- Pink
    colorB = Color3.fromRGB(182, 255, 255)  -- Cyan
})
]]

function Wave.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.intensity = self.config.intensity or 1
	self.colorA = self.config.colorA or Color3.fromRGB(255, 182, 255)
	self.colorB = self.config.colorB or Color3.fromRGB(182, 255, 255)
	
	self.fadeDuration = self.config.fadeDuration or 0.5
	function self:start()
		if self.running then return end
		self.running = true
		
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.colorA),
			ColorSequenceKeypoint.new(0.5, self.colorB),
			ColorSequenceKeypoint.new(1, self.colorA)
		})
		gradient.Parent = self.target
		
		task.spawn(function()
			local startTime = tick()
			while self.running do
				local elapsed = (tick() - startTime) * self.intensity
				gradient.Rotation = elapsed * 30
				gradient.Offset = Vector2.new(math.sin(elapsed) * 0.3, 0)
				task.wait()
			end
			local neutralColor = Color3.new(1, 1, 1)
			local fadeStart = tick()
			while tick() - fadeStart < self.fadeDuration do
				local alpha = (tick() - fadeStart) / self.fadeDuration
				local lerpedA = self.colorA:Lerp(neutralColor, alpha)
				local lerpedB = self.colorB:Lerp(neutralColor, alpha)
				gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpedA),
					ColorSequenceKeypoint.new(0.5, lerpedB),
					ColorSequenceKeypoint.new(1, lerpedA)
				})
				task.wait()
			end
			gradient:Destroy()
		end)
	end
	
	function self:stop()
		self.running = false
	end
	
	return self
end

return Wave