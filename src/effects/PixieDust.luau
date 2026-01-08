local TweenService = game:GetService("TweenService")
local PixieDust = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("PixieDust", {
    duration = 1.5,
    scale = 1,
    intensity = 2,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function PixieDust.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 223, 255)
	self.time = 0

	local function createSparkle()
		local shapes = {"★", "*", "0", "1"}
		local sparkle = Instance.new("TextLabel")
		sparkle.Text = shapes[math.random(#shapes)]
		sparkle.TextScaled = true
		sparkle.BackgroundTransparency = 1
		sparkle.TextColor3 = self.color
		sparkle.Size = UDim2.new(0, 20 * self.scale, 0, 20 * self.scale)
		sparkle.Position = UDim2.new(math.random(), 0, math.random(), 0)
		sparkle.Parent = self.target

		-- Add glow
		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://7331234161"
		glow.ImageColor3 = self.color
		glow.ImageTransparency = 0.7
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.new(2, 0, 2, 0)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = sparkle

		return sparkle
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local sparkle = createSparkle()
				table.insert(self.particles, sparkle)

				local angle = math.random() * math.pi * 2
				local speed = math.random() * 0.5 + 0.5
				local startTime = tick()

				task.spawn(function()
					while sparkle.Parent and self.running do
						local elapsed = tick() - startTime

						local radius = 50 * (1 - elapsed/2)
						local posX = math.cos(angle + elapsed * 3) * radius
						local posY = math.sin(angle + elapsed * 3) * radius

						sparkle.Position = UDim2.new(
							0.5 + posX/sparkle.Parent.AbsoluteSize.X,
							0,
							0.5 + posY/sparkle.Parent.AbsoluteSize.Y,
							0
						)

						sparkle.TextTransparency = math.sin(elapsed * 8) * 0.3

						if elapsed > 2 then
							local fadeTween = TweenService:Create(sparkle, TweenInfo.new(0.3), {
								TextTransparency = 1,
								Size = UDim2.new(0, 0, 0, 0)
							})
							fadeTween:Play()
							fadeTween.Completed:Connect(function()
								sparkle:Destroy()
								table.remove(self.particles, table.find(self.particles, sparkle))
							end)
							break
						end
						task.wait()
					end
				end)

				task.wait(0.1 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, particle in ipairs(self.particles) do
			local glow = particle:FindFirstChild("ImageLabel")
			task.spawn(function()
				local particleTween = TweenService:Create(particle, TweenInfo.new(0.5), {
					TextTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})

				local glowTween = TweenService:Create(glow, TweenInfo.new(0.5), {
					ImageTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})

				particleTween:Play()
				glowTween:Play()

				task.wait(0.5)
				particle:Destroy()
			end)
		end
		self.particles = {}
	end

	return self
end

return PixieDust