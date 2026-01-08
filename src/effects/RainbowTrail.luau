local TweenService = game:GetService("TweenService")
local RainbowTrail = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("RainbowTrail", {
    duration = 2,
    scale = 1,
    intensity = 2,
    speed = 1
})
]]

function RainbowTrail.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.speed = self.config.speed or 1
	self.time = 0

	local colors = {
		Color3.fromRGB(255, 183, 255), -- Pink
		Color3.fromRGB(255, 183, 222), -- Light Pink
		Color3.fromRGB(255, 183, 183), -- Peach
		Color3.fromRGB(255, 222, 183), -- Light Orange
		Color3.fromRGB(255, 255, 183), -- Light Yellow
		Color3.fromRGB(183, 255, 183), -- Light Green
		Color3.fromRGB(183, 255, 255)  -- Light Blue
	}

	local function createParticle(position)
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, 15 * self.scale, 0, 15 * self.scale)
		particle.Position = position
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.BackgroundColor3 = colors[math.random(#colors)]
		particle.BackgroundTransparency = 0.1
		particle.Parent = self.target

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = particle

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://12929801991"
		glow.ImageColor3 = particle.BackgroundColor3
		glow.ImageTransparency = 0.5
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.new(2, 0, 2, 0)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = particle

		local shimmer = Instance.new("Frame")
		shimmer.Size = UDim2.new(0.4, 0, 0.4, 0)
		shimmer.Position = UDim2.new(0.3, 0, 0.3, 0)
		shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
		shimmer.BackgroundTransparency = 0.3
		shimmer.Parent = particle

		local shimmerCorner = Instance.new("UICorner")
		shimmerCorner.CornerRadius = UDim.new(1, 0)
		shimmerCorner.Parent = shimmer

		return particle
	end
	
	local function particleTweenOut(particle, glow, shimmer)
		task.spawn(function()
			local particleTween = TweenService:Create(particle, TweenInfo.new(0.5), {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 0)
			})
			
			if glow then
				local glowTween = TweenService:Create(glow, TweenInfo.new(0.5), {
					ImageTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})
				glowTween:Play()
			end
			
			if shimmer then
				local shimmerTween = TweenService:Create(shimmer, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})
				shimmerTween:Play()
			end
			
			particleTween:Play()

			task.wait(0.5)
			particle:Destroy()
		end)
	end

	function self:start()
		if self.running then return end
		self.running = true

		local lastPos = UDim2.new(0.5, 0, 0.5, 0)

		task.spawn(function()
			while self.running do
				self.time += 0.1

				local xOffset = math.sin(self.time * self.speed) * 0.3
				local yOffset = math.cos(self.time * self.speed * 0.5) * 0.2

				local newPos = UDim2.new(
					0.5 + xOffset,
					0,
					0.5 + yOffset,
					0
				)

				local particle = createParticle(newPos)
				table.insert(self.particles, particle)

				local fadeTween = TweenService:Create(particle, TweenInfo.new(0.8), {
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				})

				fadeTween:Play()
				fadeTween.Completed:Connect(function()
					particleTweenOut(particle)
					table.remove(self.particles, table.find(self.particles, particle))
				end)

				lastPos = newPos
				task.wait(0.05 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, particle in ipairs(self.particles) do
			local glow = particle:FindFirstChild("ImageLabel")
			local shimmer = particle:FindFirstChild("Frame")

			particleTweenOut(particle, glow, shimmer)
		end
		self.particles = {}
	end

	return self
end

return RainbowTrail