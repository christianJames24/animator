local TweenService = game:GetService("TweenService")
local SparkleBurst = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("SparkleBurst", {
    duration = 1,
    scale = 1.5,
    intensity = 2,
    colorScheme = "rainbow" -- or "pastel" or "neon"
})
]]

function SparkleBurst.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.colorScheme = self.config.colorScheme or "rainbow"

	local colorSchemes = {
		rainbow = {
			Color3.fromRGB(255, 89, 89),   -- Red
			Color3.fromRGB(255, 189, 89),  -- Orange
			Color3.fromRGB(255, 255, 89),  -- Yellow
			Color3.fromRGB(89, 255, 89),   -- Green
			Color3.fromRGB(89, 189, 255),  -- Blue
			Color3.fromRGB(199, 89, 255)   -- Purple
		},
		pastel = {
			Color3.fromRGB(255, 182, 193), -- Pink
			Color3.fromRGB(255, 218, 185), -- Peach
			Color3.fromRGB(255, 255, 186), -- Light Yellow
			Color3.fromRGB(186, 255, 201), -- Mint
			Color3.fromRGB(186, 225, 255), -- Light Blue
			Color3.fromRGB(223, 186, 255)  -- Lavender
		},
		neon = {
			Color3.fromRGB(255, 0, 128),   -- Hot Pink
			Color3.fromRGB(0, 255, 255),   -- Cyan
			Color3.fromRGB(255, 255, 0),   -- Yellow
			Color3.fromRGB(0, 255, 128),   -- Neon Green
			Color3.fromRGB(128, 0, 255),   -- Purple
			Color3.fromRGB(255, 128, 0)    -- Orange
		}
	}

	local function createSparkleParticle(angle)
		local particle = Instance.new("Frame")
		local innerParticle = Instance.new("Frame")
		local glow = Instance.new("ImageLabel")

		particle.Size = UDim2.new(0, 8 * self.scale, 0, 8 * self.scale)
		particle.BackgroundColor3 = colorSchemes[self.colorScheme][math.random(1, #colorSchemes[self.colorScheme])]
		particle.Position = UDim2.new(0.5, 0, 0.5, 0)
		particle.AnchorPoint = Vector2.new(0.5, 0.5)
		particle.BackgroundTransparency = 0
		particle.BorderSizePixel = 0

		innerParticle.Size = UDim2.new(0.5, 0, 0.5, 0)
		innerParticle.Position = UDim2.new(0.25, 0, 0.25, 0)
		innerParticle.BackgroundColor3 = Color3.new(1, 1, 1)
		innerParticle.BackgroundTransparency = 0.3
		innerParticle.BorderSizePixel = 0
		innerParticle.Parent = particle

		glow.Image = "rbxassetid://12929801991"
		glow.ImageColor3 = particle.BackgroundColor3
		glow.ImageTransparency = 0.5
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.new(2, 0, 2, 0)
		glow.Position = UDim2.new(-0.5, 0, -0.5, 0)
		glow.Parent = particle

		local cornerRadius = Instance.new("UICorner")
		cornerRadius.CornerRadius = UDim.new(1, 0)
		cornerRadius.Parent = particle

		local innerCornerRadius = Instance.new("UICorner")
		innerCornerRadius.CornerRadius = UDim.new(1, 0)
		innerCornerRadius.Parent = innerParticle

		particle.Parent = self.target
		return particle, innerParticle, glow
	end
	
	local function particleTweenOut(particle, inner, glow)
		task.spawn(function()
			local particleTween = TweenService:Create(particle, TweenInfo.new(0.5), {
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(
					particle.Position.X.Scale + (math.random() - 0.5) * 0.2,
					0,
					particle.Position.Y.Scale + (math.random() - 0.5) * 0.2,
					0
				),
				Rotation = particle.Rotation + math.random(-180, 180)
			})
			
			if inner then
				local innerTween = TweenService:Create(inner, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				})
				innerTween:Play()
			end
			
			if glow then
				local glowTween = TweenService:Create(glow, TweenInfo.new(0.5), {
					ImageTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})
				glowTween:Play()
			end
			
			particleTween:Play()

			particleTween.Completed:Wait()
			if particle.Parent then
				particle:Destroy()
			end
		end)
	end

	function self:start()
		if self.running then return end
		self.running = true
		task.spawn(function()
			while self.running do
				for i = 1, 12 do
					local angle = (i / 12) * math.pi * 2
					local particle, inner, glow = createSparkleParticle(angle)
					table.insert(self.particles, {particle = particle, inner = inner, glow = glow})

					task.spawn(function()
						local startTime = tick()
						local duration = 0.8

						while tick() - startTime < duration and self.running do
							local alpha = (tick() - startTime) / duration
							local spiral = 2 * math.pi * 2 * alpha
							local radius = 100 * self.scale * (1 - alpha)

							local posX = math.cos(angle + spiral) * radius
							local posY = math.sin(angle + spiral) * radius

							particle.Position = UDim2.new(0.5, posX, 0.5, posY)
							particle.Rotation = alpha * 360

							local pulse = math.sin(alpha * math.pi * 4)
							glow.ImageTransparency = 0.5 + pulse * 0.3

							task.wait()
						end

						local fadeTween = TweenService:Create(particle, TweenInfo.new(0.2), {
							Size = UDim2.new(2, 0, 2, 0), --crazy idk if this is safe lol
							BackgroundTransparency = 1
						})
						fadeTween:Play()
						fadeTween.Completed:Connect(function()
							particleTweenOut(particle, inner, glow)
							table.remove(self.particles, table.find(self.particles, {particle = particle, inner = inner, glow = glow}))
						end)
					end)
				end
				task.wait(0.8 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, p in ipairs(self.particles) do
			local particle = p.particle
			local inner = p.inner
			local glow = p.glow

			if not particle.Parent then continue end

			particleTweenOut(particle, inner, glow)
		end
		self.particles = {}
	end

	return self
end

return SparkleBurst