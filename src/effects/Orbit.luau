local TweenService = game:GetService("TweenService")
local Orbit = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Orbit", {
    duration = 3,
    scale = 1,
    speed = 1,
    particleCount = 6
})
]]

function Orbit.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.speed = self.config.speed or 1
	self.particleCount = self.config.particleCount or 6

	local colors = {
		Color3.fromRGB(255, 182, 255),
		Color3.fromRGB(182, 255, 255),
		Color3.fromRGB(255, 255, 182),
		Color3.fromRGB(255, 182, 222),
		Color3.fromRGB(182, 222, 255),
		Color3.fromRGB(222, 182, 255)
	}

	function self:start()
		if self.running then return end
		self.running = true

		for i = 1, self.particleCount do
			local particle = Instance.new("Frame")
			particle.Size = UDim2.fromOffset(12 * self.scale, 12 * self.scale)
			particle.AnchorPoint = Vector2.new(0.5, 0.5)
			particle.BackgroundColor3 = colors[(i - 1) % #colors + 1]
			particle.BackgroundTransparency = 0.2
			particle.BorderSizePixel = 0
			particle.Parent = self.target

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = particle

			local glow = Instance.new("ImageLabel")
			glow.Image = "rbxassetid://7331234161"
			glow.ImageColor3 = particle.BackgroundColor3
			glow.ImageTransparency = 0.5
			glow.BackgroundTransparency = 1
			glow.Size = UDim2.fromScale(2.5, 2.5)
			glow.Position = UDim2.fromScale(0.5, 0.5)
			glow.AnchorPoint = Vector2.new(0.5, 0.5)
			glow.Parent = particle

			local trail = Instance.new("Frame")
			trail.Size = UDim2.fromOffset(20 * self.scale, 4 * self.scale)
			trail.AnchorPoint = Vector2.new(1, 0.5)
			trail.Position = UDim2.fromScale(0.5, 0.5)
			trail.BackgroundColor3 = particle.BackgroundColor3
			trail.BackgroundTransparency = 0.5
			trail.BorderSizePixel = 0
			trail.Parent = particle

			local trailCorner = Instance.new("UICorner")
			trailCorner.CornerRadius = UDim.new(1, 0)
			trailCorner.Parent = trail

			table.insert(self.particles, {particle = particle, glow = glow, trail = trail, offset = (i / self.particleCount) * math.pi * 2})
		end

		task.spawn(function()
			local startTime = tick()
			while self.running do
				local elapsed = (tick() - startTime) * self.speed

				for _, data in ipairs(self.particles) do
					local angle = elapsed * 2 + data.offset
					local radius = 60 * self.scale
					local x = math.cos(angle) * radius
					local y = math.sin(angle) * radius * 0.4

					data.particle.Position = UDim2.new(0.5, x, 0.5, y)
					data.trail.Rotation = math.deg(angle) + 180

					local pulse = math.sin(elapsed * 3 + data.offset)
					data.glow.ImageTransparency = 0.4 + pulse * 0.2
				end

				task.wait()
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, data in ipairs(self.particles) do
			local fadeTween = TweenService:Create(data.particle, TweenInfo.new(0.4), {
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 0)
			})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				data.particle:Destroy()
			end)
		end
		self.particles = {}
	end

	return self
end

return Orbit