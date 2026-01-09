local TweenService = game:GetService("TweenService")
local Fireflies = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Fireflies", {
    duration = 5,
    scale = 1,
    intensity = 1,
    color = Color3.fromRGB(255, 255, 150)
})
]]

function Fireflies.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 255, 150)

	local function createFirefly()
		local firefly = Instance.new("Frame")
		firefly.Size = UDim2.fromOffset(6 * self.scale, 6 * self.scale)
		firefly.Position = UDim2.new(math.random(), 0, math.random(), 0)
		firefly.AnchorPoint = Vector2.new(0.5, 0.5)
		firefly.BackgroundColor3 = self.color
		firefly.BackgroundTransparency = 0
		firefly.BorderSizePixel = 0
		firefly.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = firefly

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://7331234161"
		glow.ImageColor3 = self.color
		glow.ImageTransparency = 0.3
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.fromScale(4, 4)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = firefly

		return firefly, glow
	end

	function self:start()
		if self.running then return end
		self.running = true

		for i = 1, 8 * self.intensity do
			local firefly, glow = createFirefly()
			table.insert(self.particles, {firefly = firefly, glow = glow})

			local baseX = firefly.Position.X.Scale
			local baseY = firefly.Position.Y.Scale
			local phaseX = math.random() * math.pi * 2
			local phaseY = math.random() * math.pi * 2
			local speedX = 0.5 + math.random() * 0.5
			local speedY = 0.3 + math.random() * 0.4
			local blinkPhase = math.random() * math.pi * 2

			task.spawn(function()
				local startTime = tick()
				while self.running and firefly.Parent do
					local elapsed = tick() - startTime

					local x = baseX + math.sin(elapsed * speedX + phaseX) * 0.15
					local y = baseY + math.sin(elapsed * speedY + phaseY) * 0.1

					firefly.Position = UDim2.new(x, 0, y, 0)

					local blink = (math.sin(elapsed * 2 + blinkPhase) + 1) / 2
					firefly.BackgroundTransparency = 0.3 + blink * 0.5
					glow.ImageTransparency = 0.2 + blink * 0.6
					glow.Size = UDim2.fromScale(3 + blink * 2, 3 + blink * 2)

					task.wait()
				end
			end)
		end
	end

	function self:stop()
		self.running = false
		for _, data in ipairs(self.particles) do
			local fadeTween = TweenService:Create(data.firefly, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			})
			local glowTween = TweenService:Create(data.glow, TweenInfo.new(0.5), {
				ImageTransparency = 1
			})
			fadeTween:Play()
			glowTween:Play()
			fadeTween.Completed:Connect(function()
				data.firefly:Destroy()
			end)
		end
		self.particles = {}
	end

	return self
end

return Fireflies